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
    mov edx, 1                                              ; we want to read 1 byte, since we are reading byte by byte
    mov ecx, content                                        ; move memory location of content to ecx
    mov ebx, [fd_in]                                        ; move fd to ebx
    mov eax, 3                                              ; move sys_read syscall number to eax
    int 80h                                                 ; invoke kernel

.eof_check:
    cmp eax, 0                                              ; check we are at the end
    je .close_file                                          ; if we are at the end then close the file

.copy_byte_to_destination:
    mov ecx, dword [bytecount]                              ; move bytecount counter to ecx
    mov bl, byte [content]                                  ; move the byte we just read to bl
    mov byte [file_content_buffer + ecx], bl                ; move the byte read from bl to correct position in the file_content_buffer memory which can be calculated using ecx as offset
    add dword [bytecount], eax                              ; add value at eax, which is the number of bytes read (1) to bytecount to increase our counter aka offset
    jmp .set_seek_offset                                    ; loop

.close_file:
    mov ecx, dword [bytecount]
    mov byte [file_content_buffer + ecx], 0                 ; we now null terminate our file content
    mov ebx, [fd_in]                                        ; move fd to ebx
    mov eax, 6                                              ; mov sys_close syscall number to eax
    int 80h                                                 ; invoke kernel
    mov eax, ecx                                            ; move ecx to eax
    mov ebx, content_length                                 ; move content_length memory location to ebx
    call itoa                                               ; we convert content_length from int to string (ascii string) and store it in content_length memory location

.finished_response_generation:
    pop eax                                                 ; restore all the save resgisters
    pop ebx
    pop ecx
    pop edx
    ret                                                     ; return
