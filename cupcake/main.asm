

%include 'macros.asm'
%include 'http_handler.asm'

SECTION .text
global  _start
 
_start:

pop eax                                                                             ; pop eax, this number of cmdline args
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

.fork:
    mov esi, eax
    mov eax, 2
    int 80h

    cmp eax, 0
    jz .read

    jmp .accept

.read:
    call read_from_client_socket

.quit:
    sys_quit

SECTION .data
boot_up_message     db      'Starting cupcake on port 9001 ...', 0Ah, 0     ; assign msg variable with your message string
boot_up_message_len equ $-boot_up_message
socket_creation_message     db      'Creating socket ...', 0Ah, 0
socket_creation_message_len     equ     $-socket_creation_message
socket_bind_message     db      'Binding socket to 0.0.0.0:9001 ...', 0Ah, 0
socket_bind_message_len     equ     $-socket_bind_message
socket_listen_attempt_message       db      'Attempting to listen ...', 0Ah, 0
socket_listen_attempt_message_len       equ     $-socket_listen_attempt_message
socket_listening_message        db      'Cupcake is listenning for new connections ...', 0Ah, 0
socket_listening_message_len        equ     $-socket_listening_message
response_http_ok db 'HTTP/1.1 200 OK', 0Dh, 0Ah, 'Content-Type: text/html', 0Dh, 0Ah, 'Content-Length: 40', 0Dh, 0Ah, 0Dh, 0Ah, '<html><head><h1>Hello</h1></head></html>', 0Dh, 0Ah, 0
response_http_prefix db 'HTTP/1.1 200 OK', 0Dh, 0Ah, 'Content-Type: text/html', 0Dh, 0Ah, 0
content_length_header_prefix db 'Content-Length: ', 0
response_http_not_found db 'HTTP/1.1 404 NOT FOUND', 0Dh, 0Ah, 'Content-Type: text/html', 0Dh, 0Ah, 'Content-Length: 106', 0Dh, 0Ah, 0Dh, 0Ah, '<html><head><h1>Not Found</h1></head><body><p>Requested content not found on this server</p></body></html>', 0Dh, 0Ah, 0
response_http_prefix_len equ $-response_http_prefix
test_msg db 'test test', 0Ah, 0
test_msg_len equ $-test_msg

SECTION .bss
http_method resb 10
http_path resb 255
http_protocol resb 10
http_version resb 3
request_buffer resb 255
response_buffer resb 2048
file_content_buffer resb 1024
fd_in resd 1                                ; varibale from file descriptor
content resb 1                              ; variable from content
bytecount resd 1                            ; variable for bytecount
content_length resb 4
docroot resb 255
content_path resb 512
