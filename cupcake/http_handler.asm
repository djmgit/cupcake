%include 'macros.asm'
%include 'http_request_parser.asm'
%include 'file_handler.asm'

read_from_client_socket:
    sys_read esi, request_buffer, 255
    ;sys_write_string request_buffer, 255

_handle_request:
    mov eax, request_buffer
    call process_http_request

_generate_response:
    mov eax, http_path
    inc eax                             ; this is done to avoid the starting '/'
    call generate_response_from_file

.display:
    ;sys_write_string http_method, 10
    ;sys_write_string http_path, 255
    ;sys_write_string http_protocol, 10
    ;sys_write_string http_version, 3

_generate_http_response_string:
    mov eax, response_http_prefix
    push edi
    mov edi, response_buffer
.copy_prefix:
    cmp byte [eax], 0
    jz .load_file_content_buffer
    mov bl, byte[eax]
    mov byte[edi], bl
    inc eax
    inc edi
    jmp .copy_prefix

.load_file_content_buffer:
    mov eax, file_content_buffer

.copy_content:
    cmp byte [eax], 0
    jz .response_string_generated
    mov bl, byte [eax]
    mov byte [edi], bl
    inc eax
    inc edi
    jmp .copy_content

.response_string_generated:
    mov byte [edi], 0Dh
    inc edi
    mov byte [edi], 0Ah
    pop edi
    sys_write_string response_buffer, 512

_send_response:
    sys_write_string_fd response_http_ok, esi, 512

.close:
    mov ebx, esi
    mov eax, 6
    int 80h
    ret