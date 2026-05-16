[bits 64]

global isr0
global isr3
global isr13
global isr14

extern idt_exception_handler

section .text

%macro ISR_NO_ERROR 1
isr%1:
    push 0
    push %1
    jmp isr_common
%endmacro

%macro ISR_ERROR 1
isr%1:
    push %1
    jmp isr_common
%endmacro

ISR_NO_ERROR 0
ISR_NO_ERROR 3
ISR_ERROR 13
ISR_ERROR 14

isr_common:
    push rax
    push rbx
    push rcx
    push rdx
    push rbp
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    mov rdi, [rsp + 15*8]
    mov rsi, [rsp + 16*8]

    call idt_exception_handler

    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rbp
    pop rdx
    pop rcx
    pop rbx
    pop rax

    add rsp, 16

    iretq
