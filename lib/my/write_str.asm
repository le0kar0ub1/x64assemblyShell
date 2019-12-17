section .text
    global _start

write_str:
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    syscall
    ret
