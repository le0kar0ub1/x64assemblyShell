section .text
    global _start

strcmp:
    xor rax, rax
    test rdi, rdi
    jz no_match
    test rsi, rsi
    jz no_match

while:
    mov al, [rdi]
    mov ah, [rsi]
    test al, al
    jz end
    test ah, ah
    jz end
    cmp al, ah
    jne no_match
    inc rdi
    inc rsi
    jmp while

end:
    cmp BYTE [rdi], 0x0
    jne no_match
    cmp BYTE [rsi], 0x0
    jne no_match
    mov rax, 1
    ret

no_match:
    mov rax, 0
    ret
