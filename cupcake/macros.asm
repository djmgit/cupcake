; This module contains all the macro definitions.

; This macro prints a string to stdout
; Usage : sys_write <memory_location_of_content>, <number_of_bytes_to_print>
%ifmacro sys_write_string 2
    %warning "Attempt to redefine sys_write_string macro, ignoring ..."
%else
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
%endif

%ifmacro sys_read 3
    %warning "Attempt to redefine sys_read macro, ignoring ..."
%else
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
    %endmacro
%endif

%ifmacro sys_quit 0
    %warning "Attempt to redefine sys_quit macro, ignoring ..."
%else
    %macro sys_quit 0
        mov     ebx, 0
        mov     eax, 1
        int     80h
    %endmacro
%endif
