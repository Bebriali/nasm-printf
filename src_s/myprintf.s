global myprintf

section .bss
        buffer  resb BUF_SIZE
        out_mes resb BUF_SIZE

section .rodata

align 8

table:
        dq def_case      ;'a'
        dq b_op
        dq c_op
        dq d_op
        times 'n' - 'e' + 1 dq def_case

        ;dq def_case      ;'e'
        ;dq def_case
        ;dq def_case
        ;dq def_case
        ;dq def_case
        ;dq def_case
        ;dq def_case
        ;dq def_case
        ;dq def_case
        ;dq def_case      ;'n'

        dq o_op
        dq p_op
        dq def_case      ;'q'
        dq def_case      ;'r'
        dq s_op

        times 'w' - 't' + 1 dq def_case

        ;dq def_case      ;'t'
        ;dq def_case
        ;dq def_case
        ;dq def_case      ;'w'

        dq x_op
        dq def_case      ;'y'
        dq def_case      ;'z'
        dq prc_op
        dq def_case


section .data
        Msg:        db "section %s is for some data %d %%%b", 0x0a
        MsgLen      equ $ - Msg

        ErrDef:     db "error: wrong parameter in my_printf func", 0x0a
        ErrDefLen   equ $ - ErrDef

        var         dq  0xffffaaaa

        BUF_SIZE    equ 128
        SYS_WRITE   equ 1
        STDOUT      equ 1


        format  db  '%s%o%%%%%%x%d%string%ceal&stroke', '\0'
        string1 db  'string', '\0'
        oct1    equ 888
        hex1    equ 0xface
        dec1    equ 1000


section .text
global def_case

myprintf:
        push rbp                            ; save rbp
        mov rbp, rsp                        ; rbp - counter for stack
        add rbp, 16                          ; go to the first argument


        mov rdi, [rbp]
        add rbp, 8

        mov rsi, buffer
.HANDLING:
        mov rax, [rdi]
        inc rdi

        ;call _debug_output

        call _switch_ops

        cmp rax, '\0'
        jne .HANDLING

        ;stream buffer using syscall
        ;call _buffer_stdout

        pop rbp

        ret

_switch_ops:
        cmp rax, '%'
        call _debug_output
        jne def_case

.OP_CHECK:
        inc rdi
        mov rax, [rdi]
        inc rdi

        cmp rax, '%'
        je prc_op

        sub rax, 'a'

        mov rax, [table + rax * 8]
        jmp rax

        dec rdi
        jmp def_case

s_op:
        add rbp, 8
        mov rax, [rbp]

        ;put string to bufer
        call _str_to_buf

        jmp EOT
c_op:
        add rbp, 8
        mov rax, [rbp]

        ;put char to the bufer
        call _char_to_buf

        jmp def_case
d_op:
        push 4          ;nums_quantity
        push 10         ;radix

        call _dec_to_buf

        jmp def_case
x_op:
        push 4          ;nums_quantity
        push 4          ;slip
        push 1111b      ;mask for 1 digit

        call _binfit_to_buf

        jmp def_case
o_op:
        push 4          ;nums_quantity
        push 3          ;slip
        push 111b       ;mask for 1 digit

        call _binfit_to_buf

        jmp def_case
b_op:
        push 8          ;nums_quantity
        push 1          ;slip
        push 1b         ;mask for 1 digit

        call _binfit_to_buf
                ;(buffer addr in rsi)
        jmp def_case
p_op:
        add rbp, 8
        mov rax, [rbp]
        ;get ptr translation
        jmp def_case
prc_op:
        jmp def_case
def_case:
        mov [rsi], rax
        inc rsi
EOT:

        ret

_binfit_to_buf:
        pop rdx             ;mask for 1 digit
        pop rbx             ;slip
        pop rcx             ;nums quantity
        pop rax             ;number

.LOOP_X:
        push rax
        and rax, rdx

        mov [rsi], ax
        inc rsi

        pop rax
        mov cl, bl
        shr rax, cl        ;for %b - 1 ; %d - ? ; %o - 3
        loop .LOOP_X

        ret

_dec_to_buf:
        pop rbx             ;radix
        pop rcx             ;nums quantity
        pop rax

.LOOP_D:
        div rbx             ; rax <- quotient & rbx <- reminder

        mov [rsi], rbx
        inc rsi

        test rax, rax
        jnz .LOOP_D

        ret

_char_to_buf:
        and rax, 11111111b

        mov [rsi], rax
        inc rsi

        ret

_str_to_buf:
        push rdi
        mov rdi, rax

.STR_OUT:
        cmp word [rdi], '\0'
        je .END_STR_OUT

        mov rax, [rdi]
        mov [rsi], rax
        inc rsi
        inc rdi

        jmp .STR_OUT

.END_STR_OUT:
        pop rdi
        ret

_buffer_stdout:
        ;string from buffer to console
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, buffer
        mov rdx, BUF_SIZE
        syscall

        ;clear buffer
        ;mov rdi, buffer
        ;mov rcx, 128
        ;xor rax, rax
        ;rep stosb

        ret

_debug_output:
        mov [out_mes], rax
        push rax
        mov rax, 0x0A
        mov [out_mes + 1], rax
        push rdi
        push rsi
        push rdx


        mov rax, 0x01      ; write64 (rdi, rsi, rdx) ... r10, r8, r9
        mov rdi, 1         ; stdout
        mov rsi, out_mes
        mov rdx, 1       ; strlen (Msg)
        syscall

        pop rdx
        pop rsi
        pop rdi
        pop rax

        ret
