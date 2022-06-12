

%include 'macros.asm'
%include 'http_handler.asm'

SECTION .text
global  _start
 
_start:

pop eax
pop eax
pop eax
call parse_docroot
sys_write_string boot_up_message, boot_up_message_len

; setup listener socket
_setup_listener_socket:

sys_write_string socket_creation_message, socket_bind_message_len

.create_socket:
    push byte 6
    push byte 1
    push byte 2
    mov ecx, esp
    mov ebx, 1
    mov eax, 102
    int 80h
    cmp eax, 0
    jl .quit

.bind_socket:
    sys_write_string socket_bind_message, socket_bind_message_len
    mov edi, eax
    push dword 0x00000000
    push word 0x2923
    push word 2
    mov ecx, esp
    push byte 16
    push ecx
    push edi
    mov ecx, esp
    mov ebx, 2
    mov eax, 102
    int 80h
    cmp eax, 0
    jl .quit

.listen:
    sys_write_string socket_listen_attempt_message, socket_listen_attempt_message_len
    push byte 1
    push edi
    mov ecx, esp
    mov ebx, 4
    mov eax, 102
    int 80h
    cmp eax, 0
    jl .quit
    sys_write_string socket_listening_message, socket_listening_message_len

.accept:
    push byte 0
    push byte 0
    push edi
    mov ecx, esp
    mov ebx, 5
    mov eax, 102
    int 80h
    cmp eax, 0
    jl .quit

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
socket_bind_message     db      'Binding socket to IP:PORT ...', 0Ah, 0
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
