; This module contains all the macro definitions.

; This macro prints a string to stdout
; Usage : sys_write <memory_location_of_content>, <number_of_bytes_to_print>
%macro sys_write_string 2
    push edx                                ; save edx, ecx, ebx and eax on stack as usual
    push ecx
    push ebx
    push eax
    mov edx, %2                             ; put the second arg that is length of string in edx
    mov ecx, %1                             ; put the memory location of the content in ecx
    mov ebx, 1                              ; stdout
    mov eax, 4                              ; syscall number for write syscall
    int 80h                                 ; invoke the kernel
    pop eax                                 ; restore eax, ebx, ecx, edx
    pop ebx
    pop ecx
    pop edx
%endmacro

%macro sys_read 3
    push edx
    push ecx
    push ebx
    push eax
    mov edx, %3
    mov ecx, %2
    mov ebx, %1
    mov eax, 4
    int 80h
    pop eax
    pop ebx
    pop ecx
    pop edx
