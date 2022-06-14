%include 'macros.asm'
%include 'http_request_parser.asm'
%include 'file_handler.asm'

; Subroutine to read request data from accepted connection socket
; and then generate response
; Usage: call read_from_client_socket
;        expects accpeted client connection in esi
read_from_client_socket:
    sys_read esi, request_buffer, 255                               ; read request data from socket fd in esi. As of now we are only interested in the first line of the request. So randomly 255 has been hardcoded.
                                                                    ; This might not be ideal way since we path exceeds 255 bytes we might not be able to parse properly but dont want to
                                                                    ; make this more complicated as of now.

_handle_request:
    mov eax, request_buffer                                         ; move memory location of request data into eax
    call process_http_request                                       ; process the request's first line to extract required parameters

_generate_response:
    mov eax, http_path
    inc eax                             ; this is done to avoid the starting '/'
    call generate_content_path
    mov eax, content_path
    call generate_response_from_file

_check_for_content_not_found:
    mov eax, file_content_buffer
    cmp byte [eax], 0
    jnz _generate_http_response_string

.return_404:
    sys_write_string_fd response_http_not_found, esi, 2048
    jmp _close

_generate_http_response_string:
    mov eax, response_http_prefix
    push edi
    mov edi, response_buffer
.copy_prefix:
    cmp byte [eax], 0
    jz .load_content_length_header_prefix
    mov bl, byte[eax]
    mov byte[edi], bl
    inc eax
    inc edi
    jmp .copy_prefix

.load_content_length_header_prefix:
    mov eax, content_length_header_prefix

.copy_content_length_header_prefix:
    cmp byte [eax], 0
    jz .load_content_length
    mov bl, byte [eax]
    mov byte [edi], bl
    inc eax
    inc edi
    jmp .copy_content_length_header_prefix

.load_content_length:
    mov eax, content_length

.copy_content_length:
    cmp byte [eax], 0
    jz .load_content
    mov bl, byte [eax]
    mov byte [edi], bl
    inc eax
    inc edi
    jmp .copy_content_length

.load_content:
    mov byte [edi], 0Dh
    inc edi
    mov byte [edi], 0Ah
    inc edi
    mov byte [edi], 0Dh
    inc edi
    mov byte [edi], 0Ah
    inc edi
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

_send_response:
    sys_write_string_fd response_buffer, esi, 2048

_close:
    mov ebx, esi
    mov eax, 6
    int 80h
    ret