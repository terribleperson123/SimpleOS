print_char:
   mov ax, di
   mov ah, 0x0e
   mov bh, 0x0
   int 0x10
   ret

print_string:
   push si
   mov si, di
.loop:
   mov al, byte [si] 
   test al, al
   jz .done
   mov di, ax
   call print_char
   add si, 0x1
   jmp .loop
.done:
   mov al, 0x1
   pop si
   ret
   
