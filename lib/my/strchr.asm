section .text
    global _start

_strchr:
    test rdi, rdi
    jz end_prog

while:
    mov al, [rdi]
    test al, al
    jz end_prog
    cmp al, sil
    je end_prog
    inc rdi
    jmp while

end_prog:
    mov rax, rdi
    ret
