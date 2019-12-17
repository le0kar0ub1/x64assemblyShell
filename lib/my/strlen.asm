section .text
    global _start

strlen:
    xor rax, rax
    test rdi, rdi
    jz end_strlen

loop_strlen:
    cmp BYTE [rdi], 0x0
    je end_strlen
    inc rdi
    inc rax
    jmp loop_strlen
end_strlen:
    ret
