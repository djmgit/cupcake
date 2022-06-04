%include 'macros.asm'

_read_from_client_socket:
    sys_read esi, file_content_buffer, 255
    sys_write_string file_content_buffer, 255

.handle_request:
    sys_write_string_fd response_http_ok, esi, 78

.close:
    mov ebx, esi
    mov eax, 6
    int 80h
    ret
