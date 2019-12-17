section .text
    global _start

putchar:
    mov QWORD [rbp+8], rbx
    lea rbx, [rbp+8]
    mov rax, 1
    mov rdi, 1
    mov rsi, rbx
    mov rdx, 1
    syscall

    ret

_start:
    enter 8, 0

    mov rbx, 65
my_loop:
    push rbx
    call putchar

    pop rbx
    cmp rbx, 90
    je end
    inc rbx
    jmp my_loop
end:
    mov rbx, 0x0a
    call putchar
    mov rax, 60
    mov rdi, 1
    syscall
