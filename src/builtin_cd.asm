%include "shell.inc"
%include "src/change_directory.asm"
%include "src/str_to_tab.asm"

extern memset
extern strlen
extern malloc

section .rodata
    pwd DB 'PWD=', 0x0
    error_dir DB 'Directory not exist', 0xA, 0x0

section .text
    global _start

;
; arg 1 = new PWD, arg 2 = last PWD, arg 2 = pointeur on PWD
; change PWD value
; ret = pointeur on PWD
;

change_env_pwd:
    push rbp
    mov rbp, rsp
    sub rsp, 24
    mov QWORD [rbp-8], rdi
    mov QWORD [rbp-16], rsi
    mov QWORD [rbp-24], rdx

    call strlen
    mov rdi, rax
    add rdi, 5
    call malloc
    mov QWORD [rbp-24], rax
    mov rdi, rax

    mov BYTE [rdi], 'P'
    inc rdi
    mov BYTE [rdi], 'W'
    inc rdi
    mov BYTE [rdi], 'D'
    inc rdi
    mov BYTE [rdi], '='
    inc rdi
    lea rbx, [rbp-8]
    mov rsi, [rbx]

    loop_change_pwd:
        mov al, BYTE [rsi]
        cmp al, 0x0
        je end_new_pwd
        mov BYTE [rdi], al
        inc rdi
        inc rsi
        jmp loop_change_pwd

    end_new_pwd:
        lea rbx, [rbp-24]
        mov rax, [rbx]
        mov BYTE [rdi], 0x0
        add rsp, 24
        leave
        ret


;
; arg 1 = PWD ENV
; fill in stack PWD
; ret = void
;

fill_in_pwd:
    mov rdi, QWORD [rbp-24]
    add rdi, 4
    lea rsi, [rbp-280]

    loop_pwd_fill_in:
        mov al, BYTE [rdi]
        cmp al, 0x0
        je end_fill_in_pwd
        mov BYTE [rsi], al
        inc rsi
        inc rdi
        jmp loop_pwd_fill_in

    end_fill_in_pwd:
        mov BYTE [rsi], 0x0
        ret

;
;   arg 1 = env
;   find pwd env
;   ret = pointeur on PWD env
;

find_env_pwd:
    push rbp
    mov rbp, rsp
    sub rsp, 0x8
    mov QWORD [rbp-0x8], rdi      ; @env
    mov rbx, [rdi]

loop_pwd:
    cmp rbx, 0x0
    je pwd_nexist
    mov rdi, [rbx]
    mov rsi, pwd
    mov rdx, 0x4
    call _strncmp
    cmp rax, 0x1
    je end_pwd
    add rbx, 0x8
    jmp loop_pwd

end_pwd:
    mov rdi, [rbx] ;rdi get env pwd address
    mov rsi, rbx
    mov rax, 0x1
    add rsp, 0x8
    leave
    ret
    pwd_nexist:
        mov rax, 0x0
        add rsp, 0x8
        leave
        ret

;
;   arg 1 = env, arg 2 = buffer
;   main function builtin cd
;   ret = void
;

buitlin_cd:
    push rbp
    mov rbp, rsp
    sub rsp, 288
    mov QWORD [rbp-8], rdi      ; @ buffer
    mov QWORD [rbp-16], rsi     ; @ env
    mov QWORD [rbp-24], 0x0     ; Pointeur on PWD
    mov QWORD [rbp-280], 0x0    ; @ new path
    mov QWORD [rbp-288], 0x0    ; @ save pointeur on pwd in tab

    lea rdi, [rbp-280]
    mov rsi, 0x0
    mov rdx, 256
    call memset

    mov rdi, QWORD [rbp-16]
    call find_env_pwd
    cmp rax, 0x0
    je no_pwd
    mov QWORD [rbp-24], rdi     ; PWD env
    mov QWORD [rbp-288], rsi    ; pointeur on PWD

    call fill_in_pwd

    lea rdi, [rbp-0x8]
    lea rsi, [rbp-280]
    call change_directory

    mov rax, 80
    lea rdi, [rbp-280]
    syscall
    cmp rax, 0x0
    jne bad_dir

    lea rdi, [rbp-280]  ; @ new PWD
    lea rsi, [rbp-24]   ; @ last PWD in env
    lea rdx, [rbp-288]  ; @ pointeur on PWD
    call change_env_pwd
    lea rdi, [rbp-288]
    mov rsi, [rdi]
    mov [rsi], rax

    add rsp, 280
    leave
    ret

bad_dir:
    mov rax, 0x1
    mov rdi, 0x1
    mov rsi, error_dir
    mov rdx, 21
    syscall
    jmp no_pwd

no_pwd:
    add rsp, 288
    leave
    ret
