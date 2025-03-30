global myprintf

section .bss
        buffer  resb BUF_SIZE
        out_mes resb BUF_SIZE
        num_buf resb MAX_NUM_LEN

section .rodata

align 8

table:
        dq def_case      ;'a'
        dq b_op
        dq c_op
        dq d_op

        times 'n' - 'e' + 1 dq def_case

        dq o_op
        dq p_op
        dq def_case      ;'q'
        dq def_case      ;'r'
        dq s_op

        times 'w' - 't' + 1 dq def_case

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

        MAX_NUM_LEN equ 20
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
        ;push r10
        push rbp                            ; save rbp
        mov rbp, rsp                        ; rbp - counter for stack
        add rbp, 16                          ; go to the first argument


        mov rdi, [rbp]
        add rbp, 8

        mov rsi, buffer

        mov rax, [rdi]
        inc rdi

.HANDLING:

        call _switch_ops

        mov rax, [rdi]
        inc rdi
        cmp al, 0
        jne .HANDLING

        ;stream buffer using syscall
        call _buffer_stdout

        pop rbp
        ;pop r10

        ret

_switch_ops:
        cmp al, '%'
        je .OP_CHECK
        jmp def_case

.OP_CHECK:
        mov rax, [rdi]
        inc rdi

        cmp al, '%'
        je prc_op


        mov rbx, 'a'
        sub rax, rbx
        and rax, 11111111b


        mov rax, [table + rax * 8]
        jmp rax

        dec rdi
        jmp def_case

s_op:
        mov rax, [rbp]
        add rbp, 8

        ;put string to bufer
        call _str_to_buf

        jmp EOT
c_op:
        mov rax, [rbp]
        add rbp, 8

        jmp def_case
d_op:
        ;push 4          ;nums_quantity
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
        mov rax, [rbp]
        add rbp, 8
        ;get ptr translation
        jmp def_case
prc_op:
        jmp def_case
def_case:
        mov [rsi], al
        inc rsi
EOT:

        ret

_binfit_to_buf:
        pop r9             ;ret ptr

        pop rdx             ;mask for 1 digit
        pop rbx             ;slip
        pop rcx             ;nums quantity

        mov rax, [rbp]      ;pop rax
        add rbp, 8

        add rsi, rcx
        push rsi
        dec rsi

.LOOP_X:
        push rax
        and rax, rdx

        cmp al, 9h
        ja  .LITERA
        jmp .DIGIT

.LITERA:
        add al, 57h
        jmp .EO_TRNSLTN
.DIGIT:
        add al, 30h
        jmp .EO_TRNSLTN

.EO_TRNSLTN:
        mov [rsi], al
        dec rsi
        ;call _debug_output

        pop rax
        push cx
        mov cl, bl
        shr rax, cl        ;for %b - 1 ; %d - ? ; %o - 3
        pop cx
        loop .LOOP_X

        pop rsi
        push r9
        ret

_dec_to_buf:
        pop r9             ;ret ptr
        pop rbx             ;radix

        xor rcx, rcx
        push rdi
        mov rdi, num_buf
        mov rax, [rbp]      ;pop rax
        add rbp, 8

.LOOP_D:
        xor edx, edx
        inc rcx
        push rcx
        mov rcx, rbx
        div ecx             ; rax <- quotient & rbx <- reminder
        mov rbx, rcx
        pop rcx

        cmp dl, 9h
        ja  .LITERA
        jmp .DIGIT

.LITERA:
        add dl, 57h
        jmp .EO_TRNSLTN
.DIGIT:
        add dl, 30h
        jmp .EO_TRNSLTN

.EO_TRNSLTN:

        mov [rdi], dl         ;put in num_buf
        inc rdi

        test rax, rax
        jnz .LOOP_D

        dec rdi
        ;dec rsi
.REFL:
        mov al, [rdi]
        mov [rsi], al
        dec rdi
        inc rsi

        loop .REFL

        pop rdi
        ;inc rdi
        ;mov rax, [rdi]
        ;inc rdi
        push r9
        ret

_char_to_buf:
        ;call _debug_output
        and rax, 11111111b

        mov [rsi], al
        inc rsi

        ret

_str_to_buf:
        push rdi
        mov rdi, rax

.STR_OUT:
        mov ax, [rdi]
        cmp al, 0
        je .END_STR_OUT

        mov rax, [rdi]
        ;call _debug_output
        mov [rsi], al
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

        call _clear_buffer

        ret

_clear_buffer:
        mov rdi, buffer
        mov rcx, 128
        xor rax, rax
        rep stosb

        ret

_debug_output:
        add al, 30h
        mov [out_mes], al
        sub al, 30h
        push rax
        mov rax, 0x03
        mov [out_mes + 1], al
        ;mov [out_mes + 2], al
        push rdi
        push rsi
        push rdx


        mov rax, 0x01      ; write64 (rdi, rsi, rdx) ... r10, r8, r9
        mov rdi, 1         ; stdout
        mov rsi, out_mes
        mov rdx, 3       ; strlen (Msg)
        syscall

        pop rdx
        pop rsi
        pop rdi
        pop rax

        ret
