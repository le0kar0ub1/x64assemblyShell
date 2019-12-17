section .data
    line: db 10, '$'

section .text
    global _start


print_char:
    mov rax, 0x1
    mov rdi, 0x1
    xor rsi, rsi
    mov rsi, line
    mov rdx, 0x1
    syscall

    add rsp, 8
    ret

;
;
;
;

putstr:
    xor rdx, rdx
    mov rbx, rsi

while:
    mov al, [rbx]
    test al, al
    jz end
    inc rbx
    inc rdx
    jmp while

end:
    mov rax, 0x1
    mov rdi, 0x1
    syscall
    call print_char
    leave
    ret

;
;
;
;

_start:
    pop rsi

while_arg:
    pop rsi
    test rsi, rsi
    jz end_prog
    call putstr
    jmp while_arg

end_prog:
    mov rax, 60
    mov rdi, 0
    syscall
