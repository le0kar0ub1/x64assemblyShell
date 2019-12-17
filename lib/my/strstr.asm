section .text
    global _start

_strstr:
    xor rcx, rcx
    test rdi, rdi
    jz end_0strstr
    test rsi, rsi
    jz end_0strstr

while_strstr:
    cmp BYTE [rdi], 0x0
    je end_0strstr
    mov dl, [rsi]
    cmp [rdi], dl
    je equal
    cmp [rdi], dl
    jne nequal
    jmp while_strstr

equal:
    cmp BYTE [rsi+1], 0x0
    je end_1strstr
    inc rdi
    inc rsi
    inc rcx
    jmp while_strstr

nequal:
    sub rsi, rcx
    xor rcx, rcx
    inc rdi
    jmp while_strstr


end_0strstr:
    mov rax, 0x0
    ret

end_1strstr:
    sub rdi, rcx
    mov rax, rdi
    ret
