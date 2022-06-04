%include 'macros.asm'

_read_from_client_socket:
    sys_read esi, file_content_buffer, 255
    sys_write_string file_content_buffer, 255

_handle_request:
    mov eax, file_content_buffer

.process_http_request:
    mov edx, http_method

.parse_http_method:
    cmp byte [eax], 20h
    jz .process_http_path
    mov cl, byte [eax]
    mov byte [edx], cl
    inc edx
    inc eax

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

.process_http_protocol:
    mov byte [edx], 0
    mov edx, http_protocol
    inc eax

.parse_http_protocol:
    cmp byte [eax], 20h
    jz .process_http_version
    mov cl, byte [eax]
    mov byte [edx], cl
    inc edx
    inc eax

.process_http_version:
    mov byte [edx], 0
    mov edx, http_version
    inc eax

.parse_http_version:
    cmp byte [eax], 0Ah
    jz _send_response
    mov cl, byte [eax]
    mov byte [edx], cl
    inc edx
    inc eax


_send_response:
    sys_write_string_fd response_http_ok, esi, 78

.close:
    mov ebx, esi
    mov eax, 6
    int 80h
    ret

SECTION .bss:
http_method resb 10
http_path resb 255
http_protocol resb 10
http_version resb 3
