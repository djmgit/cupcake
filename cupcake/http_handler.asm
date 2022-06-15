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
    inc eax                                                         ; this is done to avoid the starting '/'
    call generate_content_path                                      ; generate the resource location to access
    mov eax, content_path                                           ; move resource location to eax
    call generate_response_from_file                                ; generate response content

_check_for_content_not_found:                                       ; block to check wether resource could be read or not
    mov eax, file_content_buffer
    cmp byte [eax], 0                                               ; check if the read content starts with null. This is the only check we are doing as of now
    jnz _generate_http_response_string                              ; if not null we proceed

.return_404:
    sys_write_string_fd response_http_not_found, esi, 2048          ; write predefined 404 response to socket
    jmp _close                                                      ; close socket, we are done

_generate_http_response_string:                                     ; block to generate the final http response string which will contain the http response. headers and the content read
    mov eax, response_http_prefix                                   ; move the response http prefix to eax. This is typically HTTP/1.1 200 OK
    push edi                                                        ; save edi
    mov edi, response_buffer                                        ; use edi to hold response buffer/memory location
.copy_prefix:                                                       ; block to copy http prefix to response buffer
    cmp byte [eax], 0                                               ; we start with check wether we have reached the end
    jz .load_content_length_header_prefix                           ; if null then we have reached end, start with copying content_length header prefix
    mov bl, byte[eax]                                               ; move byte from eax to bl
    mov byte[edi], bl                                               ; move bl to edi which holds a byte location in response buffer
    inc eax                                                         ; increment eax
    inc edi                                                         ; increment edi
    jmp .copy_prefix                                                ; loop

.load_content_length_header_prefix:
    mov eax, content_length_header_prefix                           ; load content_length header prefix to eax

.copy_content_length_header_prefix:
    cmp byte [eax], 0                                               ; we once again start with comaparing with null
    jz .load_content_length                                         ; if 0 then starting copying the content_length
    mov bl, byte [eax]                                              ; once again the content to response buffer pointed by edi
    mov byte [edi], bl
    inc eax
    inc edi                                                         ; increment the desired registers
    jmp .copy_content_length_header_prefix                          ; loop

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