[bits 16]
[org 0x8000]

jmp s2start ;;assume this would go right at 0x8000

STRING_s2msg db "YAY! SECTOR 2!!!", 0xa, 0x0

s2start:
   mov sp, 0x8000 ;;just cuz we can lol
   
   lea di, [STRING_s2msg]
   call print_string

.hlt:
   jmp .hlt


%INCLUDE "boot/load_disk.asm"
%INCLUDE "boot/print.asm"
