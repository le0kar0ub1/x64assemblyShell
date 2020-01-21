%include "shell.inc"
%include "src/fork_exec.asm"
%include "src/builtin_cd.asm"
%include "src/create_arg_exec.asm"

extern memset

section .rodata
    exit DB 'exit', 0x0

section .text
    global _start

;
; read on standart input
;

read_standard:
    push rbp
    mov rbp, rsp
    sub rsp, 0x8
    mov QWORD [rbp - 0x8], rdi

    mov rax, 0x0
    mov rdi, 0x0
    mov rsi, QWORD [rbp - 0x8]
    mov rdx, 0x40
    syscall
    cmp rsi, 0x0
    je end_prog
    cmp rax, 0x0
    jle end_prog
    cmp BYTE [rsi], 0xA
    je main_loop
    mov rdi, [rbp-0x8]
    delete_retline:
        cmp BYTE [rdi], 0x0
        je stop_retline
        cmp BYTE [rdi], 0xA
        je stop_retline
        inc rdi
        jmp delete_retline
    stop_retline:
        mov BYTE [rdi], 0x0
        add rsp, 0x8
        leave
        ret

;
; check if buffer == "exit"
;

check_exit:
    lea rdi, [rbp-512]
    mov rsi, exit
    call strcmp
    cmp rax, 0x1
    je end_prog

    mov rax, QWORD [rbp-0x8]
    mov rdi, [rax]
    cmp rdi, 0x0
    je end_prog
    ret

;
; check if buffer == 'cd'
;

check_cd:
    lea rdi, [rbp-512]
    test rdi, rdi
    jz nopcd
    cmp_str:
        cmp BYTE [rdi], 99
        jne nopcd
        inc rdi
        cmp BYTE [rdi], 100
        jne nopcd
        inc rdi
        cmp BYTE [rdi], 0x20
        jne nopcd
    lea rdi, [rbp-512]  ; @buffer
    lea rsi, [rbp-0x8]    ; @env
    call buitlin_cd
    mov rax, 0x1
    ret
    nopcd:
        mov rax, 0x0
        ret

;
; display prompt
;

disp_prompt:
    push rbp
    mov rbp, rsp
    mov rax, 0x1
    mov rdi, 0x1
    mov rsi, PROMPT
    mov rdx, 0x12
    syscall

    leave
    ret


;
; main function with the main loop
;

_start:
    push rbp
    mov rbp, rsp
    sub rsp, 512

    mov rax, [rbp+0x8]
    lea rdi, [rbp+rax*0x8+24]
    mov QWORD [rbp-0x8], rdi       ; env
    mov QWORD [rbp-0x10], 0x0      ; tab
    mov QWORD [rbp-512], 0x0      ; buffer

    lea rdi, [rbp-512]
    mov rsi, 0x0
    mov rdx, 496
    call memset
main_loop:
    call disp_prompt
    lea rdi, [rbp-512]
    call read_standard

    call check_exit

    call check_cd
    cmp rax, 0x1
    je main_loop

    lea rsi, [rbp-512]
    lea rdi, [rbp-0x10]
    mov dl, 0x20
    call buffer_to_tab
    mov QWORD [rbp-0x10], rax
    mov rdi, QWORD [rbp-0x10]

    lea rdi, [rbp-0x8] ; en
    lea rdx, [rbp-0x10]
    mov rax, [rdx] ; tab[0]
    mov rsi, QWORD [rax]
    lea rdx, [rbp-512] ; buffer
    call create_arg_exec

    cmp rax, 0x1
    jne main_loop

    lea rdi, [rbp-0x8]
    lea rsi, [rbp-0x10]
    call execve

    jmp main_loop

end_prog:
    leave
    mov rax, 0x3C
    mov rdi, 0x0
    syscall

[section .rodata]
    PROMPT DB '[asmshell@alive]$ '
