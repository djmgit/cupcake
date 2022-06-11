%include 'macros.asm'

generate_response_from_file:
    push edx
    push ecx
    push ebx
    push eax

.read_file:
    mov ecx, 0
    mov ebx, eax
    mov eax, 5
    int 80h
    mov [fd_in], eax
    mov dword [bytecount], dword 0h

.set_seek_offset:
    mov edx, 0
    mov ecx, [bytecount]
    mov ebx, [fd_in]
    mov eax, 19
    int 80h

.read_byte:
    mov edx, 1
    mov ecx, content
    mov ebx, [fd_in]
    mov eax, 3
    int 80h

.eof_check:
    cmp eax, 0
    je .close_file

.copy_byte_to_destination:
    mov ecx, dword [bytecount]
    mov bl, byte [content]
    mov byte [file_content_buffer + ecx], bl
    add dword [bytecount], eax
    jmp .set_seek_offset

.close_file:
    mov ecx, dword [bytecount]
    mov byte [file_content_buffer + ecx], 0
    sys_write_string file_content_buffer, 255
    mov ebx, [fd_in]
    mov eax, 6
    int 80h

.finished_response_generation:
    pop eax
    pop ebx
    pop ecx
    pop edx
    ret

;SECTION .bss
