

; function is responsible for invoking sys_exit
quit:
    mov     ebx, 0
    mov     eax, 1
    int     80h
