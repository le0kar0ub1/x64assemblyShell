section .text
    global _start

_rindex:
    xor rax, rax
    xor rbx, rbx
    test rsi, rsi
    jz end_rindex
    test rdi, rdi
    jz end_rindex
    mov ah, [rsi]

while:
    mov al, [rdi]
    cmp al, 0x0
    je end_rindex
    cmp al, ah
    je change_pointeur
after_pointer:
    inc rdi
    jmp while

change_pointeur:
    mov rbx, rdi
    jmp after_pointer

end_rindex:
    mov rax, 60
    mov rdi, 1
    syscall
