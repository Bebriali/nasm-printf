global myprintf

section .bss
        buffer  resb BUF_SIZE

section .rodata

align 8

table:
        dq def_case      ;'a'
        dq b_op
        dq c_op
        dq d_op
        times 'n' - 'e' dq def_case

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
        dq def_case      ;'t'
        dq def_case
        dq def_case
        dq def_case      ;'w'
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
        ;pop r10
;
        ;mov rsi, format
        ;mov rdx, string1
        ;mov rcx, oct1
        ;mov r8,  hex1
        ;mov r9,  dec1
;
        ;push r9
        ;push r8
        ;push rcx
        ;push rdx
        ;push rsi
;
;
        ;pop rax
        ;mov rdi, rax
;
        ;mov rsi, buffer

.HANDLING:
        mov rax, [rdi]

        push rbp                            ; save rbp
        mov rbp, rsp                        ; rbp - counter for stack
        add rbp, 8                          ; go to the first argument

        call _switch_ops

        cmp rax, '\0'
        jne .HANDLING

        ;stream buffer using syscall
        call _buffer_stdout

        ;mov rax, 0x3C       ;END OF PROGRAM
        ;xor rdi, rdi
        ;syscall

        ret

_switch_ops:
        cmp rax, '%'
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

        jmp def_case
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
        mov [rsi], ax
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

_binfit_to_buf:
        pop rdx             ;mask for 1 digit
        pop rbx             ;slip
        pop rcx             ;nums quantity
        pop rax             ;number
        ;push rcx
        ;mov rcx, 4         ;for %b - 8 ; %d - ? ; %o - 5

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

        mov [rsi], bx
        inc rsi

        test rax, rax
        jnz .LOOP_D

        ret

_char_to_buf:
        and rax, 11111111b

        mov [rsi], eax
        inc rsi

        ret

_str_to_buf:
        push rdi
        mov rdi, rax

.STR_OUT:
        cmp word [rdi], '\0'
        je .END_STR_OUT

        mov ax, [rdi]
        mov [rsi], ax
        inc rsi
        inc rdi

        jmp .STR_OUT

.END_STR_OUT:
        pop rax
        mov rdi, rax
        ret

_buffer_stdout:
        ;string from buffer to console
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, buffer
        mov rdx, BUF_SIZE
        syscall

        ;clear buffer
        mov rdi, buffer
        mov rcx, 128
        xor rax, rax
        rep stosb

        ret
