

process_http_request:
    push edx
    push ecx
    mov edx, http_method

.parse_http_method:
    cmp byte [eax], 20h
    jz .process_http_path
    mov cl, byte [eax]
    mov byte [edx], cl
    inc edx
    inc eax
    jmp .parse_http_method

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
    pop ecx
    pop edx
    ret
