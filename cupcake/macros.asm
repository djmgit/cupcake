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

; This macro prints a string to a given fd
; Usage: sys_write_string_fd <source_memory_location>, <fd>, <number_of_bytes_to_Write>
%ifmacro sys_write_string_fd 3
    %warning "Attempt to redifine sys_write_string_fd macro, ignoring ..."
%else
    %macro sys_write_string_fd 3
        push edx                                ; save edx, ecx, ebx and eax on stack
        push ecx
        push ebx
        push eax
        mov edx, %3                             ; put third arg that is number of bytes to write in edx
        mov ecx, %1                             ; put source memory location in ecx
        mov ebx, %2                             ; put destination fd in ebx
        mov eax, 4                              ; sys_write syscall
        int 80h                                 ; invoke kernal
        pop eax                                 ; restore eax, ebx, ecx and edx
        pop ebx
        pop ecx
        pop edx
    %endmacro
%endif

; This macro reads bytes from a given source fd to destination memory
; Usage sys_read <source_fd>, <destination_memory_location>, <number_of_bytes_to_read>
%ifmacro sys_read 3
    %warning "Attempt to redefine sys_read macro, ignoring ..."
%else
    %macro sys_read 3
        push edx                                ; save edx, ecx, ebx and eax on stack
        push ecx
        push ebx
        push eax
        mov edx, %3                             ; store number of bytes in edx
        mov ecx, %2                             ; store destination memory location in ecx
        mov ebx, %1                             ; store source fd in ebx
        mov eax, 3                              ; sys_read syscall
        int 80h                                 ; invoke kernel
        pop eax                                 ; restore eax, ebx, ecx, edx
        pop ebx
        pop ecx
        pop edx
    %endmacro
%endif

; This macro exists the running code
; Usage: sys_quit
%ifmacro sys_quit 0
    %warning "Attempt to redefine sys_quit macro, ignoring ..."
%else
    %macro sys_quit 0
        mov     ebx, 0                          ; mov exit status code to ebx
        mov     eax, 1                          ; sys_exit
        int     80h                             ; invoke kernel
    %endmacro
%endif
