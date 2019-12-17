%include "shell.inc"

section .rodata
    previous_last DB '..', 0
    previous_dir DB '../', 0

section .text
    global _start

;
; add a dir on actual path
;

add_dir:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov QWORD [rbp-0x8], rdi      ; PWD path
    mov QWORD [rbp-16], rsi     ; load next / in buffer

    mov BYTE [rdi], '/'
    inc rdi
    loop_add_dir:
        mov al, [rsi]
        cmp al, 0x0
        je end_dir_buffer
        cmp al, '/'
        je end_dir
        mov BYTE [rdi], al
        inc rdi
        inc rsi
        jmp loop_add_dir

    end_dir_buffer:
        mov rax, 0x1
        mov BYTE [rdi], 0x0
        mov QWORD [rbp-0x10], rsi
        add rsp, 0x10
        leave
        ret

    end_dir:
        mov rax, 0x0
        mov BYTE [rdi], 0x0
        mov QWORD [rbp-0x10], rsi
        add rsp, 0x10
        leave
        ret

;
; delete a dir on actual path
;

delete_dir:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov QWORD [rbp-0x8], rdi      ; PWD path
    mov QWORD [rbp-16], rsi     ; load next / in buffer

    loop_delete_dir:
        mov al, BYTE [rdi]
        cmp al, '/'
        je end_delete
        dec rdi
        jmp loop_delete_dir

    end_delete:
        inc rsi
        mov al, BYTE [rsi]
        cmp al, '/'
        je end_delete_slash
        cmp al, 0x0
        je end_delete_buffer
        jmp end_delete

    end_delete_slash:
        mov rax, 0x0
        mov QWORD [rbp-16], rsi
        mov BYTE [rdi], 0x0
        add rsp, 16
        leave
        ret

    end_delete_buffer:
        mov rax, 0x1
        mov QWORD [rbp-16], rsi
        mov BYTE [rdi], 0x0
        add rsp, 16
        leave
        ret

;
; evaluation of a case of tab dir
;

delete_or_add:
    mov rdi, QWORD [rbp-24]
    mov rsi, previous_last
    mov rdx, 0x3
    call _strncmp
    cmp rax, 0x1
    je delete
    mov rdi, QWORD [rbp-24]
    mov rsi, previous_dir
    mov rdx, 0x3
    call _strncmp
    cmp rax, 0x1
    je delete
    mov rax, 0x2
    ret
    delete:
        mov rax, 0x1
        ret

;
; arg 1 = tab of command, arg 2 = PWD env
; main fonction to change dir
; ret = void
;

change_directory:
    push rbp
    mov rbp, rsp
    sub rsp, 24
    mov QWORD [rbp-0x8], rdi     ; @ cd command
    mov QWORD [rbp-16], rsi    ; @ pwd path
    mov QWORD [rbp-24], 0x0    ; keep address (cd comand curent char) on call delete_or_add

    dec rsi
    pointer_on_last_byte_pwd:
        inc rsi
        mov al, BYTE [rsi]
        cmp al, 0x0
        jne pointer_on_last_byte_pwd

    mov QWORD [rbp-16], rsi
    mov rdi, QWORD [rbp-0x8]
    add QWORD [rdi], 0x3
    mov rax, [rdi]
    mov QWORD [rbp-24], rax

    loop_directory:
        mov rdi, QWORD [rbp-24]
        cmp BYTE [rdi], 0x0
        je no_more_dir
        call delete_or_add
        cmp rax, 0x1
        je delete_last_dir
        mov rdi, QWORD [rbp-16]
        mov rsi, QWORD [rbp-24]
        call add_dir
        mov QWORD [rbp-16], rdi
        mov QWORD [rbp-24], rsi
        cmp rax, 0x1
        je no_more_dir
        inc QWORD [rbp-24]
        jmp loop_directory

    delete_last_dir:
        mov rdi, QWORD [rbp-16]
        mov rsi, QWORD [rbp-24]
        call delete_dir
        mov QWORD [rbp-16], rdi
        mov QWORD [rbp-24], rsi
        cmp rax, 1
        je no_more_dir
        inc QWORD [rbp-24]
        jmp loop_directory

    end_h:
        mov rax, 60
        mov rdi, 42
        syscall

no_more_dir:
    add rsp, 24
    leave
    ret
