%include "shell.inc"

section .rodata
    fork_error DB 'Processus can not be create', 0x0A, 0x0
    exec_error DB 'Can not exec', 0x0A, 0x0

section .text
    global _start

;   arg 1 = env
;   arg 2 = *argv[]
;   fork a processus and execute the binary
;

execve:
    push rbp
    mov rbp, rsp
    sub rsp, 0x10
    mov QWORD [rbp-0x8], rdi  ; @env
    mov QWORD [rbp-0x10], rsi ; @tab

    mov rax, 57
    syscall
    cmp rax, -1
    jle fail_fork
    mov r10, rax

    cmp r10, 0x0
    jne end_exec
    mov rax, 59
    mov rbx, QWORD [rbp-16]
    mov rsi, [rbx]
    mov rdi, [rsi]
    mov rbx, QWORD [rbp-0x8]
    mov rdx, [rbx]
    syscall
    cmp rax, 0x0
    jl execve_error

    mov rax, 61
    mov rdi, r10
    syscall
end_exec:
    add rsp, 16
    leave
    ret

fail_fork:
    mov rax, 28
    mov rsi, fork_error
    call write_str

    add rsp, 16
    leave
    mov rax, 60
    mov rdi, 84
    syscall
    ret

execve_error:
    mov rax, 0xE
    mov rsi, exec_error
    call write_str

    add rsp, 16
    leave
    mov rax, 60
    mov rdi, 84
    syscall
