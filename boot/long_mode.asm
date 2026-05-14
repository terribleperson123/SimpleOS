[bits 64]

long_mode_start:
   mov ax, KERNEL_DATA_SEL
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov fs, ax
   mov gs, ax

   mov ax, TSS_SEL
   ltr ax
;clear direction flag

   cld
   mov rsp, 0x7000

   mov ecx, 0xC0000080 ; some EFER MSR shit to check long mode enabled
   rdmsr
   test eax, 1 << 10 ; bit 10 = LMA, long mode active
   jz .hlt ;;dont do anything now lol
 
   call kernel_main_temp  ;;ELSE CALL KMAIN!!! YAY!!! WE'LL MOVE IT TO C LATER YESS!!!

.hlt:
   hlt ;;appatenrly this is an actual ins and i never knew
   jmp .hlt


msg db "Hello World! "
    db "From the kernel.", 0xa, 0x00

;;gonna write in c, but we are here now!
kernel_main_temp:
   ;;yay
   call vga_clear64
   lea rdi, [msg]
   call vga_print64


.hlt:
   hlt
   jmp .hlt

vga_putc64:
   push rbx
   cmp dil, 0xa ;;apparently dil and dih also exist, so nice
   je .newline
;;0xb8000 + ([vga_cursor_row] * 80 + [vga_cursor_col]) * 2, times 2 because it will move 2 bytes 
   mov ebx, dword [vga_cursor_row]
   imul ebx, ebx, 80
   add ebx, dword [vga_cursor_col]
   shl ebx, 1
   add ebx, 0xB8000
    
   mov ax, di ;al gets lower byte
   mov ah, 0x0f
   mov word [rbx], ax

   inc dword [vga_cursor_col]
   cmp dword [vga_cursor_col], 80
   je .newline
   xor rax, rax
   pop rbx   
   ret

.newline:
   mov dword [vga_cursor_col], 0
   inc dword [vga_cursor_row]
   xor rax, rax
   pop rbx
   ret
   

vga_print64:
   mov rsi, rdi
.loop:
   xor rax, rax
   lodsb
   test al, al
   jz .done
   mov di, ax
   call vga_putc64

   jmp .loop
.done:
   xor rax, rax
   ret


vga_clear64:   
   mov rax, 0xB8000
.loop   
   mov qword [rax], 0x0 ;8 bytes at a time
   add rax, 8
   cmp rax, 0xB8000 + 4000 ;cuz its 4000 bytes of character in vga
   jne .loop
   xor rax, rax
   mov dword [vga_cursor_col], eax
   mov dword [vga_cursor_row], eax
   ret



