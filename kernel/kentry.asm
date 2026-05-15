[bits 64]

global kernel_entry

extern main

section .text
kernel_entry:
   call main
.pause:
   hlt
   jmp .pause
