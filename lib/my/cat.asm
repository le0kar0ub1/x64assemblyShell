section .data
    fd dw 0
    buff times 2048 db 1

section .text
    global _start

_close_file:
    mov rax, 3
    mov rdi, fd
    syscall
    ret

;
;
;

_open_file:
    mov rax, 2
    mov rsi, 0
    syscall
    cmp rax, -1
    je end_prog
    mov [fd], rax
    mov rdi, rax
    ret

;
;
;

_read_file:
    mov rax, 0
    mov rdi, [fd]
    mov rsi, buff
    mov rdx, 2048
    syscall
    ret

;
;
;

_write_buffer:
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    mov rsi, buff
    syscall
    ret

;
;
;

_start:
    add rsp, BYTE 10h
    pop rdi
    test rdi, rdi
    jz end_prog
    call _open_file
    call _read_file
    call _write_buffer
    call _close_file
    jmp end_prog

end_prog:
    mov rax, 60
    mov rdi, 0
    syscall
