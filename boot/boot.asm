[bits 16] ;;16 bit encoding
[org 0x7c00]

jmp 0x0000:start ;set Cs to 0 and ip to start

%INCLUDE "boot/print.asm"
%INCLUDE "boot/load_disk.asm"

STRING_startmsg db 0xa, "Hello World!", 0xa, 0
bootdrive resb 0


start:
   cli ;disable/clear all interrupts
   xor ax, ax
   mov ds, ax ;data
   mov es, ax ;extra
   mov ss, ax ;stack
   mov sp, 0x7c00 ;start of this current physical address 
   sti ;enable interrupts 
     
   ;;save boot drive
   mov byte [bootdrive], dl
   ;;char print test
   mov di, 'S' 
   call print_char 

   ;;string print test
   mov di, STRING_startmsg
   call print_string
   
   mov al, [bootdrive]
   mov dx, 0x8000 ;;load address
   mov si, 64 ;;amount of sectors to load   
   mov di, word [bootdrive] ;;bootdrive
   call load_disk   


   jmp 0x8000   
   
.hlt:
   jmp .hlt
   



;;boot signature
times 510-($-$$) db 0
dw 0xaa55 ;actually 0x55aa but endianness
