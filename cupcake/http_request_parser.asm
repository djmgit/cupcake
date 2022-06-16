
; Subroutine to process http request and extract http method
; resource path, protocol and version into different memory locations
; Usage: call process_http_request
;        expects memory location of the first list of the http request in eax
process_http_request:
    push edx                                                ; save edx, ecx, and eax on stack
    push ecx
    push eax
    mov edx, http_method                                    ; move memory location of uninitialised http_method to edx

.parse_http_method:
    cmp byte [eax], 20h                                     ; check if we have encountered whitespace
    jz .process_http_path                                   ; if we have, then we can start with processing the http path
    mov cl, byte [eax]                                      ; move byte from request memory location to bl
    mov byte [edx], cl                                      ; move byte from bl to memory location pointed by edx
    inc edx                                                 ; increment edx
    inc eax                                                 ; increment eax
    jmp .parse_http_method                                  ; loop back

.process_http_path:                                         ; start with processing the http path
    mov byte [edx], 0                                       ; null terminate the http method
    mov edx, http_path                                      ; move the http_path uninitialised memory location to edx
    inc eax                                                 ; increment eax to go beyond the whitespace

.parse_http_path:                                           ; start with parsing the http path
    cmp byte [eax], 20h                                     ; check if we have encountered whitespace
    jz .process_http_protocol                               ; if we have then start with protocol processing
    mov cl, byte [eax]                                      ; same as before copy the http_path from the request buffer to its desired memory location
    mov byte [edx], cl
    inc edx
    inc eax
    jmp .parse_http_path                                    ; loop

.process_http_protocol:                                     ; process and parse the http protocol in similar way as above
    mov byte [edx], 0
    mov edx, http_protocol
    inc eax

.parse_http_protocol:
    cmp byte [eax], 2Fh                                     ; this time we look out for 2Fh which is the hex for '/' because the format is protocol/version
    jz .process_http_version
    mov cl, byte [eax]
    mov byte [edx], cl
    inc edx
    inc eax
    jmp .parse_http_protocol                                ; loop

.process_http_version:                                      ; finally we extract the http version into its memory location from the request buffer
    mov byte [edx], 0
    mov edx, http_version
    inc eax

.parse_http_version:
    cmp byte [eax], 0Ah                                     ; For version parsing, we look for 0Ah which is the hex for new line
    jz .http_request_processing_finished
    mov cl, byte [eax]
    mov byte [edx], cl
    inc edx
    inc eax
    jmp .parse_http_version                                 ; loop

.http_request_processing_finished:
    pop eax                                                 ; restore the saved registers
    pop ecx
    pop edx
    ret                                                     ; return
