
extern myprintf

section .data
    format  db  '%s%o%%%%%%x%d%string%ceal&stroke', '\0'
    string1 db  'string', '\0'
    oct1    equ 888
    hex1    equ 0xface
    dec1    equ 1000

section .text

global _start_printf

_start_printf:
    pop r10

    ;mov rsi, format
    ;mov rdx, string1
    ;mov rcx, oct1
    ;mov r8,  hex1
    ;mov r9,  dec1

    push r9
    push r8
    push rcx
    push rdx
    push rsi
    push rdi

    ;mov rax, rdi
    call myprintf

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop r8
    pop r9

    push r10

    ;mov rax, 0x3C      ; exit64 (rdi)
    ;xor rdi, rdi
    ;syscall

    ret
