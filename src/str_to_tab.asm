%include "shell.inc"

extern malloc

section .text
    global _start

;
; main function to malloc a tab
;
; Arg 1 = tab address
; Arg 2 = Buffer address
;
; Ret = pointeur on tab
;

buffer_to_tab:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 0x11

    mov BYTE [rbp-0x11], dl        ; @char_cut
    mov QWORD [rbp-0x8], rdi       ; @tab
    mov QWORD [rbp-0x10], rsi      ; @buffer
    mov rdi, 256
    call malloc
    mov QWORD [rbp-0x8], rax
    mov rbx, QWORD [rbp-0x8]

    malloc_tab_loop:
        mov rdi, 50
        call malloc
        mov QWORD [rbx], rax
        mov rdi, rax
        mov rsi, QWORD [rbp-0x10]
        call cut_space
        cmp rax, 1
        je end_malloc_tab
        add rbx, 8
        jmp malloc_tab_loop

    end_malloc_tab:
        add rbx, 8
        mov QWORD [rbx], 0x0

        add rsp, 0x11
        mov rax, QWORD [rbp-0x8]
        pop rbx
        leave
        ret

; args: buffer address
; function cut tab and space and fill in a string in tab while != ' ' || '\t'
; ret: int = ('\0' ? 1 : 0)

cut_space:
    dec rsi
    while_space:
        inc rsi
        mov al, [rsi]
        cmp al, BYTE [rbp-0x11]
        je while_space
        cmp al, 9
        je while_space
        cmp al, 0x0
        je end_buffer

    loop_cut_char:
        mov al, [rsi]
        cmp al, 0x0
        je end_buffer
        cmp al, BYTE [rbp-0x11]
        je space_find
        cmp al, 9
        je space_find
        mov BYTE [rdi], al
        inc rdi
        inc rsi
        jmp loop_cut_char

space_find:
    mov BYTE [rdi], 0x0
    mov QWORD [rbp-0x10], rsi
    mov rax, 0x0
    ret

end_buffer:
    mov BYTE [rdi], 0x0
    mov QWORD [rbp-0x10], rsi
    mov rax, 0x1
    ret
