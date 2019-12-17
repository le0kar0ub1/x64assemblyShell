section .text
    global _start

_memmove:
    test rdi, rdi
    jz end_memmove
    test rsi, rsi
    jz end_memmove

while_memmove:
    cmp rdx, 0
    je end_memmove
    cmp rdi, 0x0
    je end_memmove
    cmp rsi, 0x0
    je end_memmove
    mov al, BYTE [rsi]
    mov BYTE [rdi], al
    inc rdi
    inc rsi
    dec rdx
    jmp while_memmove

end_memmove:
    ret
