section .text
global myprintf

myprintf:
    ;mov rax, 0x01      ; write64 (rdi, rsi, rdx) ... r10, r8, r9
    ;mov rdi, 1         ; stdout
    ;pop rsi
    ;mov rdx, 10        ; strlen (Msg)
    ;syscall

    mov rax, 0x01
    mov rdi, 1
    push rbp                            ; save rbp
    mov rbp, rsp                        ; rbp - counter for stack

    add rbp, 16
    lea rdx, [rbp]                      ; get rdi
    mov rsi, [rdx]

    pop rbp
    mov rdx, 20
    syscall

    ;xor rdi, rdi
    ;syscall
    ;mov rax, 0x3C      ; exit64 (rdi)

    ret



section .data

Msg:        db "__Hllwrld", 0x0a
MsgLen      equ $ - Msg
