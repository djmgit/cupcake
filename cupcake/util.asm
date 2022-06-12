

; subroutine is responsible for converting integer to ascii and store it in given memory
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

; subroutine to parse commandline arguments
parse_docroot:
    push eax
    push ebx
    push ecx
    mov ecx, docroot

.copy_docroot:
    cmp byte [eax], 0
    jz .finished
    mov bl, byte [eax]
    mov byte [ecx], bl
    inc eax
    inc ecx
    jmp .copy_docroot

.finished:
    mov byte [ecx], 0
    pop ecx
    pop ebx
    pop eax
    ret

generate_content_path:
    push eax
    push ebx
    push ecx
    push edx
    mov ecx, docroot
    mov edx, content_path

.copy_docroot:
    cmp byte [ecx], 0
    jz .process_file_name
    mov bl, byte [ecx]
    mov byte [edx], bl
    inc ecx
    inc edx
    jmp .copy_docroot

.process_file_name:
    mov byte [edx], 2Fh
    inc edx

.copy_file_name:
    cmp byte [eax], 0
    jz .finished
    mov bl, byte [eax]
    mov byte [edx], bl
    inc eax
    inc edx
    jmp .copy_file_name

.finished:
    mov byte[edx], 0
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
