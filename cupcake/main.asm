

%include 'macros.asm'
;%include 'util.asm'
%include 'http_handler.asm'

SECTION .text
global  _start
 
_start:
 
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
response_http_ok db 'HTTP/1.1 200 OK', 0Dh, 0Ah, 'Content-Type: text/html', 0Dh, 0Ah, 'Content-Length: 14', 0Dh, 0Ah, 0Dh, 0Ah, 'Hello World!', 0Dh, 0Ah, 0h
response_http_prefix db 'HTTP/1.1 200 OK', 0Dh, 0Ah, 'Content-Type: text/html', 0Dh, 0Ah, 'Content-Length: 14', 0Dh, 0Ah, 0Dh, 0Ah
response_http_prefix_len equ $-response_http_prefix
test_msg db 'test test', 0Ah, 0
test_msg_len equ $-test_msg
