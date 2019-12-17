section .text
    global _start

_strpbrk:
    enter 8, 0
    xor rax, rax
    test rdi, rdi
    jz end_strpbrk_false
    test rsi, rsi
    jz end_strpbrk_false

while_strpbrk:
    mov dh, BYTE [rdi]
    cmp dh, 0x0
    je end_strpbrk_false
    call check_char
    cmp rax, 1
    je end_strpbrk_true
    inc rdi
    jmp while_strpbrk

end_strpbrk_true:

    mov rdx, [rdi]
    mov QWORD [rbp+8], rdx
    lea rax, [rbp+8]
    leave
    ret

end_strpbrk_false:
    mov QWORD [rbp+8], 0
    lea rax, [rbp+8]
    leave
    ret

;
;
;

check_char:
    mov rbx, rsi

while_check_char:
    cmp BYTE [rbx], 0x0
    je end_check_char_false
    cmp BYTE [rbx], dh
    je end_check_char_true
    inc rbx
    jmp while_check_char

end_check_char_false:
    mov rax, 0
    ret
end_check_char_true:
    mov rax, 1
    ret
