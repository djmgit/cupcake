%include 'macros.asm'
%include 'util.asm'

; subroutine to read content from desired resource file
; Usage: call generate_response_from_file
;        expected the file path in eax
generate_response_from_file:
    push edx                                                ; save required registers on stack
    push ecx
    push ebx
    push eax

.read_file:
    mov ecx, 0                                              ; O_RDONLY file access mode in ecx
    mov ebx, eax                                            ; move file path to ebx
    mov eax, 5                                              ; move sys_open syscall number to eax
    int 80h                                                 ; invoke kernel
    cmp eax, 0                                              ; check for errors
    jl .finished_response_generation                        ; if there is an error, that is, eax value is less than 0 then quit
    mov [fd_in], eax                                        ; if no error then we have the fd in eax, move it to dedicated memory location
    mov dword [bytecount], dword 0h                         ; move 0 to our offset counter

.set_seek_offset:
    mov edx, 0                                              ; we want to set the offset from the beginning of the file hence 0
    mov ecx, [bytecount]                                    ; the offset value in ecx
    mov ebx, [fd_in]                                        ; fd in ebx
    mov eax, 19                                             ; sys_lseek syscall number in eax
    int 80h                                                 ; invoke kernel

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
    mov ebx, [fd_in]
    mov eax, 6
    int 80h
    mov eax, ecx
    mov ebx, content_length
    call itoa

.finished_response_generation:
    pop eax
    pop ebx
    pop ecx
    pop edx
    ret
