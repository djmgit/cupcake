
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

.process_http_path:
    mov byte [edx], 0
    mov edx, http_path
    inc eax

.parse_http_path:
    cmp byte [eax], 20h
    jz .process_http_protocol
    mov cl, byte [eax]
    mov byte [edx], cl
    inc edx
    inc eax
    jmp .parse_http_path

.process_http_protocol:
    mov byte [edx], 0
    mov edx, http_protocol
    inc eax

.parse_http_protocol:
    cmp byte [eax], 2Fh
    jz .process_http_version
    mov cl, byte [eax]
    mov byte [edx], cl
    inc edx
    inc eax
    jmp .parse_http_protocol

.process_http_version:
    mov byte [edx], 0
    mov edx, http_version
    inc eax

.parse_http_version:
    cmp byte [eax], 0Ah
    jz .http_request_processing_finished
    mov cl, byte [eax]
    mov byte [edx], cl
    inc edx
    inc eax
    jmp .parse_http_version

.http_request_processing_finished:
    pop eax
    pop ecx
    pop edx
    ret
