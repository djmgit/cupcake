

; subroutine is responsible for converting integer to ascii and store it in given memory
; Usage: call itoa
;        Expects int in eax and the memory location to hold ascii string in ebx
itoa:
    push eax                                                ; save regosters on stack
    push ebx
    push edx
    push esi
    mov ecx, 0                                              ; mov 0 to ecx

.divloop:
    inc ecx                                                 ; ecx is our couter to track number of digits we are pushing onto the stack
    mov edx, 0                                              ; mov 0 to edx
    mov esi, 10                                             ; move 10 to esi, we are going to divide our int in eax by 10 repeatedly to extract digits until 0
    idiv esi                                                ; divide eax by esi
    add edx, 48                                             ; add 48 to the remainder in edx. 48 is the ascii for character 0 or '0'
    push edx                                                ; push the ascii of the digit to stack
    cmp eax, 0                                              ; check if eax is 0
    jnz .divloop                                            ; if not 0 then loop

.copy_content:                                              ; Start with copying the aciis from stack to given memory location
    dec ecx                                                 ; decrement our counter
    pop eax                                                 ; pop the top ascii digit from stack to eax
    mov byte [ebx], byte al                                 ; move al to byte pointed by ebx
    inc ebx                                                 ; increment ebx, our memory pointer
    cmp ecx, 0                                              ; compare ecx to 0
    jnz .copy_content                                       ; if not 0 then loop

.finsih:
    mov byte [ebx], 0                                       ; null terminate the content_length
    pop esi                                                 ; restore all the saved registers
    pop edx
    pop ebx
    pop eax
    ret                                                     ; return

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
