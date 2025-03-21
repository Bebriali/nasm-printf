section .bss

buffer  resb 128

section .text

global _main

_main: pop rdi

        mov rcx, MsgLen
        mov rsi, buffer

HANDLING:
        mov rax, [rdi]
        call _switch_ops




        mov rax, 0x3C       ;END OF PROGRAM
        xor rdi, rdi
        syscall

_switch_ops:
    cmp rax, '%'
    je OP_CHECK:

OP_CHECK:
    inc rdi
    mov rax, [rdi]
    inc rdi

    cmp rax, 's'
    je .table(, rdi, 8)

    cmp rax, 'c'
    je .table(, rdi, 16)

    cmp rax, 'd'
    je .table(, rdi, 24)

    cmp rax, 'x'
    je .table(, rdi, 32)

    cmp rax, 'o'
    je .table(, rdi, 40)

    cmp rax, 'b'
    je .table(, rdi, 48)

    cmp rax, '%'
    je .table(, rdi, 56)

    cmp rax, 'p'
    je .table(, rdi, 64)

    dec rdi
    jmp .default

.s_op:
    pop rax
    ;put string to bufer
    jmp .default
.c_op:
    pop rax
    ;put char to the bufer
    jmp .default
.d_op:
    pop rax
    ;put digit to the bufer
    jmp .default
.x_op:
    pop rax
    ;call _reg_to_x
    jmp .default
.o_op:
    pop rax
    ;call reg_to_oct
    jmp .default
.b_op:
    pop rax
    ;call reg_to_b           ;(buffer addr in rsi)
    jmp .default
.prc_op:
    pop rax
    mov [rsi], '%'
    jmp .default
.p_op:
    pop rax
    ;get ptr translation
    jmp .default
.default:
    mov [rsi], rdi
    ;skip   ;push rdi
            ;push rsi

            ;mov rax, 0x01
            ;mov rdi, 1
            ;mov rsi, ErrDef
            ;mov rdx, ErrDefLen
            ;syscall

            ;pop rsi
            ;pop rdi

ret

_reg_to_x:
    push rcx
    mov rcx, 4      ;for %b - 8 ; %d - ? ; %o - 5

.LOOP_X:
    push rax
    and rax, 1111b

    mov [rsi], eax
    inc rsi

    pop rax
    shr rax, 4      ;for %b - 1 ; %d - ? ; %o - 3
    loop .LOOP_X

    pop rcx

    ret

reg_to_char:
    and rax, 11111111b

    mov [rsi], eax
    inc rsi

    ret

str_to_buf:
    push rdi
    mov rdi, rax

.STR_OUT:
    cmp [rdi], '\0'
    je .END_STR_OUT

    mov [rsi], [rdi]
    inc rsi
    inc rdi

    jmp .STR_OUT

.END_STR_OUT:
    pop rsi
    ret

section .data

.table:
    dw .s_op
    dw .c_op
    dw .d_op
    dw .x_op
    dw .o_op
    dw .b_op
    dw .prc_op
    dw .p_op
    dw .default

Msg:    db "section %s is for some data %d %%%b", 0x0a
MsgLen  equ $ - Msg

ErrDef: db "error: wrong parameter in my_printf func", 0x0a
ErrDefLen equ $ - ErrDef

var     dw 0ffffaaaah
