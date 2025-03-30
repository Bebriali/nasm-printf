
section .text
global c_exit
c_exit:
    mov rax, 0x3C      ; exit64 (rdi)
    xor rdi, rdi
    syscall