section .text
    global _start

_strcspn:
    xor rax, rax
    xor rcx, rcx
    test rdi, rdi
    jz end_strcspn
    test rsi, rsi
    jz end_strcspn

while_strcspn:
    mov dh, BYTE [rdi]
    cmp dh, 0x0
    je end_strcspn
    call check_nochar
    cmp rax, 1
    je end_strcspn
    inc rdi
    inc rcx
    jmp while_strcspn

end_strcspn:
    mov rax, rcx
    ret

;
;
;

check_nochar:
    mov rbx, rsi

while_check_nochar:
    cmp BYTE [rbx], 0x0
    je end_check_nochar_false
    cmp BYTE [rbx], dh
    je end_check_nochar_true
    inc rbx
    jmp while_check_nochar

end_check_nochar_false:
    mov rax, 0
    ret
end_check_nochar_true:
    mov rax, 1
    ret
