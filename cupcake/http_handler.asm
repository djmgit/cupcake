%include 'macros.asm'
%include 'http_request_parser.asm'
%include 'file_handler.asm'

read_from_client_socket:
    sys_read esi, request_buffer, 255
    sys_write_string request_buffer, 255

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
    jz .copy_content
    mov bl, byte[eax]
    mov byte[edi], bl
    inc eax
    inc edi
    jmp .copy_prefix
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
    sys_write_string response_buffer, 2048

_send_response:
    sys_write_string_fd response_buffer, esi, 2048

.close:
    mov ebx, esi
    mov eax, 6
    int 80h
    ret

SECTION .bss
http_method resb 10
http_path resb 255
http_protocol resb 10
http_version resb 3
request_buffer resb 255
response_buffer resb 512
file_content_buffer resb 255
fd_in resd 1                                ; varibale from file descriptor
content resb 1                              ; variable from content
bytecount resd 1                            ; variable for bytecount

