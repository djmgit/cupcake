
 
SECTION .text
global  _start
 
_start:
 
    mov     edx, 13
    mov     ecx, msg
    mov     ebx, 1
    mov     eax, 4
    int     80h

SECTION .data
boot_up_message     db      'Starting cupcake on port 9200 ...', 0Ah     ; assign msg variable with your message string
boot_up_message_len equ $-boot_up_message
