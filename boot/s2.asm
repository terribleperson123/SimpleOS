[bits 16]
[org 0x8000]

jmp s2start ;;assume this would go right at 0x8000

STRING_s2msg db "YAY! SECTOR 2!!!", 0xa, 0x0
%INCLUDE "boot/load_disk.asm"
%INCLUDE "boot/print.asm"




s2start:
   mov sp, 0x7c00 ;;just cuz we can lol
   
   lea di, [STRING_s2msg]
   call print_string


;;enable a20
    in al, 0x92
    or al, 00000010b     ; set bit 1 = A20 enable
    and al, 11111110b    ; clear bit 0 = don't reset CPU
    out 0x92, al
;;enter protected mode
   cli
   lgdt [gdt_descriptor32]
   
   mov eax, cr0
   or eax, 1 ;PE bit
   mov cr0, eax    
   jmp CODE32_SEL:protected_mode_entry
.hlt:
   jmp .hlt



;;HERE WILL BE PAGING SETUP


;;HERE WILL BE TSS BS:
align 16
tss_start:
    times 104 db 0
tss_end:

TSS_BASE  equ 0x8000 + (tss_start - $$) ;;cuz nasm complaining
TSS_LIMIT equ tss_end - tss_start - 1

;;below is gdt bs 32 bit
CODE32_SEL  equ 0x08
DATA32_SEL  equ 0x10

;;long mode gdt
KERNEL_CODE_SEL equ 0x08
KERNEL_DATA_SEL equ 0x10

USER_DATA_SEL   equ 0x18 | 3 ;; the | 3 required because the bottom 2 bits are privllage level of selector.
USER_CODE_SEL   equ 0x20 | 3

TSS_SEL         equ 0x28
align 8
gdt_start32:
gdt_null32: dq 0x0
gdt_code32:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

gdt_data32:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

   gdt_end32:
gdt_descriptor32:
    dw gdt_end32 - gdt_start32 - 1
    dd gdt_start32

;;64bit gdt

align 8
gdt_start64:
gdt_null64: dq 0x0

gdt_kernel_code:
   dw 0x0000 ;limit low
   dw 0x0000 ;base low
   db 0x00 ;base middle
   db 10011010b ; access: P = 1, present. DPL = 00, ring 0. S = 1, code/data. Type = 1010 execute,read.
   db 00100000b ;flag, limit high. flag: 10b = 0x2 = Granualirity = 0; D = 0, 64 bit. L = 1, 64 bit cs. AVL = 0
   db 0x00 ;base high
gdt_kernel_data:
   dw 0x0000 ;limit low
   dw 0x0000 ;base low
   db 0x00 ;base middle
   db 10010010b ; access: P = 1, present. DPL = 00, ring 0. S = 1, code/data. Type = 0010 read/write.
   db 00000000b ;flag = 0, limit high = 0, flag = 0 = DS/ES/SS limits ignored
   db 0x00 ; base high
gdt_user_data:
   dw 0x0000 ;limit low
   dw 0x0000 ;base low
   db 0x00 ;base middle
   db 11110010b ; access: P = 1, present. DPL = 11, ring 3. S = 1, code/data. Type = 0010 read/write.
   db 00000000b ;flag, limit high. 0, ds/es/ss limits ignored in long mode
   db 0x00 ;base high
gdt_user_code:
   dw 0x0000 ;limit low
   dw 0x0000 ;base low
   db 0x00 ;base middle
   db 11111010b ; access: P = 1, present. DPL = 11, ring 3. S = 1, code/data. Type = 1010 execute,read.
   db 00100000b ;flag, limit high. flag: 10b = 0x2 = Granualirity = 0; D = 0, 64 bit. L = 1, 64 bit cs. AVL = 0
   db 0x00 ;base high
gdt_tss:
    dw TSS_LIMIT & 0xFFFF
    dw TSS_BASE & 0xFFFF
    db (TSS_BASE >> 16) & 0xFF
    db 10001001b
    db ((TSS_LIMIT >> 16) & 0x0F)
    db (TSS_BASE >> 24) & 0xFF
    dd 0x00000000        ; base bits 32..63, okay because bootloader is under 4 GiB
    dd 0x00000000        ; reserved
gdt_end64:
gdt_descriptor64:
    dw gdt_end64 - gdt_start64 - 1
    dq gdt_start64 



;;HERE GOES 32 bit Protected mode code:
[bits 32]
%INCLUDE "boot/protected_mode.asm"





