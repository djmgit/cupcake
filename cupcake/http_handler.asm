%include 'macros.asm'
%include 'http_request_parser.asm'

read_from_client_socket:
    sys_read esi, file_content_buffer, 255
    sys_write_string file_content_buffer, 255

handle_request:
    mov eax, file_content_buffer
    call process_http_request

.display:
    sys_write_string http_method, 10
    sys_write_string http_path, 255
    sys_write_string http_protocol, 10
    sys_write_string http_version, 3

_send_response:
    sys_write_string_fd response_http_ok, esi, 78

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
response_buffer resb 512
file_content_buffer resb 255
