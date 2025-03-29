;%define DEBUG 1
extern myprintf


section .data
    format1  db  "%d"
             db  '%x'
             db  '%s'
             db    0
    format3  db  '%o'
    format4  db  '%p'
    format5  db  '%%'
    format6  db  '%string%ceal&stroke'
    format7  db  '%b'
    format8  db  "printing such strings in that particular way is so '%d' and, to be %x, ill do it %s years", 0x0a
    eofor8   db  0
    dec8     equ  10000
    hex8     equ  0xdead
    string8  db  "boring", 0
    string1  db  'string', 0
    oct1    equ 888
    hex1    equ 0xface
    dec1    equ 1000
    bin1    equ 0b11011001

section .text

%ifdef DEBUG
global _start

_start:
%else
global _start_printf

_start_printf:
%endif
    pop r10

%ifdef DEBUG
    mov rdi, format8
    mov rsi, dec8
    mov rdx, hex8
    mov rcx, string8
    mov r8,  hex1
    mov r9,  dec1
%endif

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

%ifdef DEBUG
    mov rax, 0x3C      ; exit64 (rdi)
    xor rdi, rdi
    syscall
%endif

    ret
