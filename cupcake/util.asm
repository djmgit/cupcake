

; function is responsible for invoking sys_exit
quit:
    mov     ebx, 0
    mov     eax, 1
    int     80h

itoa:
    push eax
    push ebx
    push edx
    push esi
    mov ecx, 0

.divloop:
    inc ecx
    mov edx, 0
    mov esi, 10
    idiv esi
    add edx, 48
    push edx
    cmp eax, 0
    jnz .divloop

.copy_content:
    dec ecx
    pop eax
    mov byte [ebx], byte al
    inc ebx
    cmp ecx, 0
    jnz .copy_content

.finsih:
    mov byte [ebx], 0
    pop esi
    pop edx
    pop ebx
    pop eax
    ret
