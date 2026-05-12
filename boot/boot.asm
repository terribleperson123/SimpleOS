[bits 16] ;;16 bit encoding
[org 0x7c00]

jmp 0x0000:start ;set Cs to 0 and ip to start


start:
   cli ;disable/clear all interrupts
   xor ax, ax
   mov ds, ax ;data
   mov es, ax ;extra
   mov ss, ax ;stack
   
   mov sp, 0x7c00 ;start of this current physical address
   
   sti ;enable interrupts 

.hlt:
   jmp .hlt

;;boot signature
times 510-($-$$) db 0
dw 0xaa55 ;actually 0x55aa but endianness
