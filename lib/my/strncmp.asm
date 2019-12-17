section .text
    global _start

_strncmp:
    test rdi, rdi
    jz no_nmatch
    test rsi, rsi
    jz no_nmatch
    cmp rdx, 0
    jle nmatch

while_strncmp:
    mov al, [rdi]
    mov ah, [rsi]
    test al, al
    jz no_nmatch
    test ah, ah
    jz no_nmatch
    cmp al, ah
    jne no_nmatch
    inc rdi
    inc rsi
    dec rdx
    cmp rdx, 0
    je nmatch
    jmp while_strncmp

end_strncmp:
    nmatch:
        mov rax, 1
        ret

    no_nmatch:
        cmp al, ah
        je nmatch
        mov rax, 0
        ret
