

%include 'macros.asm'

SECTION .text
global  _start
 
_start:
 
; setup listener socket
_setup_socket:



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

