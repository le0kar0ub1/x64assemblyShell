section .text
    global _start

_strcasecmp:
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
    call case_insensitive
    cmp rdx, 0
    je no_match
    inc rdi
    inc rsi
    jmp while

end:
    cmp al, ah
    jne no_match
    mov rax, 1
    ret

no_match:
    mov rax, 0
    ret

case_insensitive:
    cmp al, ah
    je match
    mov dl, al
    sub dl, ah
    cmp dl, 32
    je match
    cmp dl, -32
    je match
    mov dl, ah
    sub dl, al
    cmp dl, 32
    je match
    cmp dl, -32
    je match
    mov rdx, 0
    ret
match:
    mov rdx, 1
    ret
