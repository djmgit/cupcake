%include 'macros.asm'
%include 'http_request_parser.asm'
%include 'file_handler.asm'

read_from_client_socket:
    sys_read esi, response_buffer, 255
    sys_write_string response_buffer, 255

_handle_request:
    mov eax, response_buffer
    call process_http_request

_generate_response:
    mov eax, http_path
    inc eax                             ; this is done to avoid the starting '/'
    call generate_response_from_file

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
request_buffer resb 255
response_buffer resb 512
file_content_buffer resb 255
fd_in resd 1                                ; varibale from file descriptor
content resb 1                              ; variable from content
bytecount resd 1                            ; variable for bytecount

