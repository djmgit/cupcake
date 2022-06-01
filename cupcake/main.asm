

%include 'macros.asm'
%include 'util.asm'

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
    jl quit

.bind_socket:
    sys_write_string socket_bind_message, socket_bind_message_len
    mov edi, eax
    mov dword, 0x00000000
    push word,  0x2923
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
    jl quit

.listen:
    sys_write_string socket_listen_attempt_message socket_listen_attempt_message_len
    push byte 1
    push edi
    mov ecx, esp
    mov ebx, 4
    mov eax, 102
    int 80h
    cmp eax, 0
    jl quit

_quit:
    quit



SECTION .data
boot_up_message     db      'Starting cupcake on port 9200 ...', 0Ah, 0     ; assign msg variable with your message string
boot_up_message_len equ $-boot_up_message
socket_creation_message     db      'Creating socket ...', 0Ah, 0
socket_creation_message_len     equ     $-socket_creation_message
socket_bind_message     db      'Binding socket to IP:PORT ...', 0Ah, 0
socket_bind_message_len     equ     $-socket_bind_message
socket_listen_attempt_message       db      'Attempting to listen ...', 0Ah, 0
socket_listen_attempt_message_len       equ     $-socket_listen_attempt_message
socket_listening_message        db      'Cupcake is listenning for new connections ...'
socket_listening_message_len        equ     $-socket_listening_message

SECTION .bss
response_buffer resb 512
file_content_buffer 255

