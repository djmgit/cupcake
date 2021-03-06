

%include 'macros.asm'
%include 'http_handler.asm'

SECTION .text
global  _start
 
_start:

fetch_cmdline_args:
pop eax                                                                             ; pop eax, this number of cmdline args
cmp eax, 2
jnl .valid_args
sys_write_string invalid_arg_num_message, invalid_arg_num_message_len
sys_quit

.valid_args:
pop eax                                                                             ; pop eax, this is the name of the program
pop eax                                                                             ; pop eax, this is the cmdline arg provided for docroot
call parse_docroot                                                                  ; call parse_docroot to move docroot to dedicated variable
sys_write_string boot_up_message, boot_up_message_len                               ; show booting message

; setup listener socket
_setup_listener_socket:

sys_write_string socket_creation_message, socket_creation_message_len

; create a new socket
.create_socket:
    push byte 6                                                                     ; IPPROTO_TCP
    push byte 1                                                                     ; SOCK_STREAM
    push byte 2                                                                     ; PF_INET
    mov ecx, esp                                                                    ; mov address of argument into ecx
    mov ebx, 1                                                                      ; invoke SOCKET (1)
    mov eax, 102                                                                    ; syscall number for sys_socketcall
    int 80h                                                                         ; invoke kernel
    cmp eax, 0                                                                      ; eax should receive the fd of the created socket.
    jl .quit                                                                        ; if less then 0 means error, quit

.bind_socket:
    sys_write_string socket_bind_message, socket_bind_message_len                   ; show bind message and start with socket binding to IP:PORT
    mov edi, eax                                                                    ; move socket fd to edi
    push dword 0x00000000                                                           ; IP : 0.0.0.0
    push word 0x2923                                                                ; PORT : 9001, in reverse byte order hex
    push word 2                                                                     ; AF_INET
    mov ecx, esp                                                                    ; move address of previous arguments to ecx
    push byte 16                                                                    ; arguments length
    push ecx                                                                        ; push args address
    push edi                                                                        ; push socket fd onto stack
    mov ecx, esp                                                                    ; move address of args to ecx
    mov ebx, 2                                                                      ; invoke BIND (2)
    mov eax, 102                                                                    ; move syscall number sys_socketcall to eax
    int 80h                                                                         ; invoke kernel
    cmp eax, 0                                                                      ; compare eax with 0
    jl .quit                                                                        ; if less than 0, which is error condition, quit

.listen:
    sys_write_string socket_listen_attempt_message, socket_listen_attempt_message_len               ; show listen and start with listenning process
    push byte 1                                                                                     ; queue length : 1
    push edi                                                                                        ; push socket fd on stack
    mov ecx, esp                                                                                    ; move address of arguments to esp
    mov ebx, 4                                                                                      ; invoke LISTEN (4)
    mov eax, 102                                                                                    ; syscall number for sys_socketcall
    int 80h                                                                                         ; invoke kernel
    cmp eax, 0                                                                                      ; check for error
    jl .quit                                                                                        ; if error, quit
    sys_write_string socket_listening_message, socket_listening_message_len                         ; show message to imply socket has started to listen for connections

.accept:                                                                                            ; Now we start with accept call which is a blocking call
    push byte 0                                                                                     ; address length arg
    push byte 0                                                                                     ; address arg
    push edi                                                                                        ; push the socket fd
    mov ecx, esp                                                                                    ; move arg address to ecx just like we did several times earlier
    mov ebx, 5                                                                                      ; invoke ACCEPT (5)
    mov eax, 102                                                                                    ; syscall number for sys_socketcall
    int 80h                                                                                         ; invoke kernel
    cmp eax, 0                                                                                      ; on a successful accept call, we get the incomming connection socket fd in eax
    jl .quit                                                                                        ; if eax is less than 0, it means error, quit

; Whenever we accept a new connection and get a connection socket, we need fork a new process and delegate the
; work of serving the request to this new process. In this way the server does not have to wait for each and
; every connection being served and different connections can get served parallely. Each forked process
; after sering the request, closes the client socket and quits
;
; However this causes an issue as well. In linux when a proces is forked by a parent, the parent must reap the
; process when the child finishes execution. That is the parent must wait for the child's execution to finish
; and then read its exit code. If this is not done the child does not release its kernel resources and continues
; to exist as a zombie process, which is bad for the host on which the server is running. Because with every
; connection the number of zombie processes will increased and stale kernle resource blockage will also increase
;
; How can we see such processes? After running cupcake and send some requests to it, try executing
; ps -aux | grep cupcake , if possibel put it on watch using
; watch ps -aux | grep cupcake
; and then keep sending it requests
; processes marked as [defunct] will start popping up in the ps output.
;
; How parent usually reaps child processes? Using wait or waidpid calls.
;
; TODO: implement child process reaping.
.fork:
    mov esi, eax                                                ; move client socket fd to esi, the forked process will be using this fd to read the request
    mov eax, 2                                                  ; syscall number for sys_fork
    int 80h                                                     ; invoke kernel
    cmp eax, 0                                                  ; compare eax with 0
    jz .read                                                    ; if 0 means we are in child process, jump to read section
    jmp .accept                                                 ; we are in parent, go back to accepting new connections

.read:
    call read_from_client_socket                                ; we are in child, start reading from the client socket, generate response and write back

.quit:
    sys_quit                                                    ; exit process

; initialised variables and constants for the server to function
SECTION .data
boot_up_message db 'Starting cupcake on port 9001 ...', 0Ah, 0     ; assign msg variable with your message string
boot_up_message_len equ $-boot_up_message
socket_creation_message db 'Creating socket ...', 0Ah, 0
socket_creation_message_len equ $-socket_creation_message
socket_bind_message db 'Binding socket to 0.0.0.0:9001 ...', 0Ah, 0
socket_bind_message_len equ $-socket_bind_message
socket_listen_attempt_message db 'Attempting to listen ...', 0Ah, 0
socket_listen_attempt_message_len equ $-socket_listen_attempt_message
socket_listening_message db 'Cupcake is listenning for new connections ...', 0Ah, 0
socket_listening_message_len equ $-socket_listening_message
response_http_prefix db 'HTTP/1.1 200 OK', 0Dh, 0Ah, 'Content-Type: text/html', 0Dh, 0Ah, 0
content_length_header_prefix db 'Content-Length: ', 0
response_http_not_found db 'HTTP/1.1 404 NOT FOUND', 0Dh, 0Ah, 'Content-Type: text/html', 0Dh, 0Ah, 'Content-Length: 106', 0Dh, 0Ah, 0Dh, 0Ah, '<html><head><h1>Not Found</h1></head><body><p>Requested content not found on this server</p></body></html>', 0Dh, 0Ah, 0
response_http_prefix_len equ $-response_http_prefix
invalid_arg_num_message db 'Invalid number of arguments. Atleast 1 argument representing the docroot path is mandatory', 0Ah, 'Usage: cupcake [doctroot]', 0Ah, 0
invalid_arg_num_message_len equ $-invalid_arg_num_message
test_msg db 'test test', 0Ah, 0
test_msg_len equ $-test_msg

; uninitialised variables
SECTION .bss
http_method resb 10
http_path resb 255
http_protocol resb 10
http_version resb 3
request_buffer resb 255
response_buffer resb 2048
file_content_buffer resb 1024
fd_in resd 1
content resb 1
bytecount resd 1
content_length resb 4
docroot resb 255
content_path resb 512
