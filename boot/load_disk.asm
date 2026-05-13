load_disk:
   mov bx, dx ;;load location
   mov ax, si ;; load amount of sectors into al
   mov ah, 0x02 ;;BIOS read sector
   mov ch, 0 ;;cylinder 0
   mov cl, 2 ;;starting from sector 2
   mov dx, di ;;boot drive into dl
   mov dh, 0
   int 0x13 
   
   jc .disk_error

.disk_error:
   mov ah, 0x02
   mov al, 'D'
   mov bh, 0
   int 0x10
   jmp .exit

.exit:
   ret
