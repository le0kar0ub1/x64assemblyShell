section .text
    global _start

_memset:
    test rdi, rdi
    jz end_memset
    test rsi, rsi
    jz end_memset

while_memset:
    cmp rdx, 0x0
    je end_memset
    cmp BYTE [rdi], 0x0
    je end_memset
    mov BYTE [rdi], sil
    inc rdi
    dec rdx
    jmp while_memset

end_memset:
    mov rax, 0x0
    ret
