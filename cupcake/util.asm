

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
; It simply copies the docroot provided to a given memory location
; Usage: call parse_docroot
;        Expects the docroot: string in eax
parse_docroot:
    push eax                                                ; save registers on stack
    push ebx
    push ecx
    mov ecx, docroot                                        ; move docroot memory location to ecx

.copy_docroot:
    cmp byte [eax], 0                                       ; compare eax to 0
    jz .finished                                            ; if 0 then return
    mov bl, byte [eax]                                      ; copy eax to docroot memory location byte by byte
    mov byte [ecx], bl
    inc eax
    inc ecx
    jmp .copy_docroot                                       ; loop

.finished:
    mov byte [ecx], 0                                       ; null terminate the docroot
    pop ecx                                                 ; restore registers
    pop ebx
    pop eax
    ret                                                     ; return

; Subroutine to generate content_path from docroot and http_path variable
; Usage: call generate_content_path
;        expects http_path in eax
generate_content_path:
    push eax                                                ; save registers on stack
    push ebx
    push ecx
    push edx
    mov ecx, docroot                                        ; move docroot memory location to ecx
    mov edx, content_path                                   ; move content_path memory location to edx

.copy_docroot:
    cmp byte [ecx], 0                                       ; compare byte ponted by ecx to 0
    jz .process_file_name                                   ; if 0 then start with copying file nname
    mov bl, byte [ecx]                                      ; move docroot to content_path memory location byte by byte
    mov byte [edx], bl
    inc ecx                                                 ; increment ecx
    inc edx                                                 ; increment edx
    jmp .copy_docroot                                       ; loop

.process_file_name:
    mov byte [edx], 2Fh                                     ; add 2FH hex which is '/' at the end of docroot
    inc edx                                                 ; increment edx to point to next byte

.copy_file_name:
    cmp byte [eax], 0                                       ; compare eax with 0
    jz .finished
    mov bl, byte [eax]                                      ; copy http_path to content_path memory location byte by byte
    mov byte [edx], bl
    inc eax                                                 ; increment eax
    inc edx                                                 ; increment edx
    jmp .copy_file_name                                     ; loop

.finished:
    mov byte[edx], 0                                        ; null terminate the content_path
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret                                                     ; return
