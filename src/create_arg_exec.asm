%include "shell.inc"

section .rodata
    path DB 'PATH=', 0x0
    no_bin DB 'Command not found.', 0xA, 0x0

section .text
    global _start

; arg 1 = env
; function for find the var env PATH
; ret = var PATH=

find_env_path:
    push rbp
    mov rbp, rsp
    sub rsp, 0x8
    mov QWORD [rbp-0x8], rdi      ; @env
    mov rbx, [rdi]

loop_path:
    cmp rbx, 0x0
    je path_nexist
    mov rdi, [rbx]
    mov rsi, path
    mov rdx, 0x4
    call _strncmp
    cmp rax, 0x1
    je end_path
    add rbx, 0x8
    jmp loop_path

end_path:
    mov rdi, [rbx] ;rdi get env PATH address
    mov rax, 0x1
    add rsp, 0x8
    leave
    ret
    path_nexist:
        mov rax, 0x0
        add rsp, 0x8
        leave
        ret

;
; function for test the path give in PATH with the command in buffer
;

test_binary:
    inc rbx
    lea rax, [rbp-0x10] ; @first tab case
    mov rdi, [rax]
    mov rsi, rbx   ; # env path
    fill_in_path:
        mov al, BYTE [rsi]
        test al, al
        jz fill_in_buffer
        cmp al, 0x3A
        je fill_in_buffer
        mov BYTE [rdi], al
        inc rdi
        inc rsi
        jmp fill_in_path

    fill_in_buffer:
        mov BYTE [rdi], 47
        inc rdi
        lea rax, [rbp-24]
        mov rsi, [rax]
        loop_fill_in_buffer:
            mov al, BYTE [rsi]
            cmp al, 0x0
            je end_test_binary
            cmp al, 0x20
            je end_test_binary
            mov BYTE [rdi], al
            inc rdi
            inc rsi
            jmp loop_fill_in_buffer

end_test_binary:
    mov BYTE [rdi], 0x0
    mov rax, 0x2
    lea rsi, [rbp-0x10]
    mov rdi, [rsi]
    mov rsi, 0x0
    syscall
    cmp rax, 0x0
    jl binary_doesnt_exist
    mov rax, 0x1
    ret
    binary_doesnt_exist:
        mov rax, 0x0
        ret

;
; main function for find system binary
;

create_arg_exec:
    push rbp
    mov rbp, rsp
    sub rsp, 24
    mov QWORD [rbp-0x8], rdi      ; @env
    mov QWORD [rbp-0x10], rsi     ; @tab[0]
    mov QWORD [rbp-24], rdx     ; @buffer

    mov rdi, QWORD [rbp-0x8]
    call find_env_path
    cmp rax, 0x1
    jne no_binary

    mov rsi, QWORD [rbp-0x10] ; @tab[0]
    mov rdx, QWORD [rbp-24] ; @buffer
    mov rbx, rdi ; # env path
find_binary:
    dec rbx
    run_on_path:
        inc rbx
        cmp BYTE [rbx], 0x0
        je no_binary
        cmp BYTE [rbx], 0x3A
        jne run_on_path

    call test_binary
    cmp rax, 0x1
    jne find_binary

    mov rax, 0x1
    add rsp, 24
    leave
    ret

no_binary:
    mov rax, 0x1
    mov rdi, 0x1
    mov rsi, no_bin
    mov rdx, 20
    syscall

    mov rax, 0x0
    add rsp, 24
    leave
    ret
