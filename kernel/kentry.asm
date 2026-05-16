[bits 64]

global kernel_entry

extern main

section .text.kernel_entry
kernel_entry:                                                                                                        ;bit 0 to bit 7
   mov rsp, 0x200000 ;won't crash because stack, when pushing, subs that amount and writes from addr: eg 8 bytes: 0x1FFFF8 -> 0x1FFFFF
   call main
.pause:
   hlt
   jmp .pause
