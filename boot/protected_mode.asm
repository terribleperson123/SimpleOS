[bits 32]

protected32msg 
   db "HAHA FINALLY!! THIS SHOULD BE STRAIGHT TO VIDEO MEMORY", 0xa
   db "AND LINE 2!!! YAAYY", 0xa, 0x0

no_cpuidmsg db "No cpuid found, halting.", 0xa, 0x0
no_longmodemsg db "Long-mode not possible.", 0xa, 0x0
vga_cursor_row dd 0
vga_cursor_col dd 0


protected_mode_entry:
;;reload. no need to cli since interrupts are disabled rn in protected mode
   mov ax, DATA32_SEL
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov fs, ax
   mov gs, ax
   
   mov sp, 0x7c00  ;because we still need some previous things, such as maybe the disk  


   lea edi, dword [protected32msg]
   call vga_print  
   
   call check_cpuid
   call check_longmode

   call setup_page_tables
   call enable_longmodeandyeet
.hlt:
   jmp .hlt


enable_longmodeandyeet:
   lgdt [gdt_descriptor64]

   lea eax, [PML4_TABLE]
   mov cr3, eax

   mov eax, cr4
   or eax, 1 << 5 ;;enable PAE
   mov cr4, eax

   ;;enable long mode with this voodoo
   ;;todo_: look into those voodoo ins
   mov ecx, 0xC0000080
   rdmsr
   or eax, 1 << 8
   wrmsr   
   
   mov eax, cr0
   or eax, 1 << 31 ;;;enable paging bit
   mov cr0, eax

   jmp KERNEL_CODE_SEL:long_mode_start 

setup_page_tables:
   lea eax, [PDPT_TABLE]
   or eax, 0b11 ;;present = 1, writable =1;
   mov dword [PML4_TABLE], eax
   mov dword [PML4_TABLE + 4], 0x00000000
   
   lea eax, [PD_TABLE]
   or eax, 0b11 ;;present = 1, writable =1;
   mov dword [PDPT_TABLE], eax
   mov dword [PDPT_TABLE + 4], 0x00000000
   
   lea eax, [PT_TABLE0]
   or eax, 0b11 ;;present = 1, writable =1;
   mov dword [PD_TABLE], eax
   mov dword [PD_TABLE + 4], 0x00000000
   
   xor ecx, ecx
;;map FIRST 2 MIB, identify mapping: from 0x00 to 0x001fffff
.map_pt:
   mov eax, ecx
   shl eax, 12
   or eax, 0b11 ;;present writable
   
   mov dword [PT_TABLE0 + ecx * 8 + 0], eax
   mov dword [PT_TABLE0 + ecx * 8 + 4], 0
   inc ecx
   cmp ecx, 512
   jne .map_pt
   ret




;;page tables
align 4096

PML4_TABLE:
   times 4096 db 0
PDPT_TABLE:
   times 4096 db 0
PD_TABLE:
   times 4096 db 0
PT_TABLE0:
   times 4096 db 0


check_cpuid:
   pushfd
   pop eax
   mov ecx, eax
   xor eax, 1 << 21 ;;id bit
   push eax
   popfd
   pushfd
   pop eax
   push ecx
   popfd
   
   cmp eax, ecx
   je .no_cpuid
   ret
.no_cpuid:
   lea edi, dword [no_cpuidmsg]
   call vga_print
   jmp protected_mode_entry.hlt

check_longmode:
   mov eax, 0x80000000
   cpuid
   cmp eax, 0x80000001
   jb .no_longmode
   
   mov eax, 0x80000001
   cpuid
   test edx, 1 << 29
   jz .no_longmode
   ret
.no_longmode:
   lea edi, dword [no_longmodemsg]
   call vga_print
   jmp protected_mode_entry.hlt




vga_putc:
    cmp di, 0xa
    je .newline
;;0xb8000 + ([vga_cursor_row] * 80 + [vga_cursor_col]) * 2, times 2 because it will move 2 bytes 
    mov ebx, [vga_cursor_row]
    imul ebx, ebx, 80
    add ebx, [vga_cursor_col]
    shl ebx, 1
    add ebx, 0xB8000
    
    mov ax, di ;al gets lower byte
    mov ah, 0x0f
    mov [ebx], ax

    inc dword [vga_cursor_col]
    cmp dword [vga_cursor_col], 80
    je .newline

    ret

.newline:
    mov dword [vga_cursor_col], 0
    inc dword [vga_cursor_row]
    ret
   

vga_print:
   sub esp, 4
   mov esi, edi
.loop:
   xor eax, eax
   lodsb
   test al, al
   jz .done
   mov di, ax
   call vga_putc

   jmp .loop
.done:
   mov eax, 0
   add esp, 4
   ret


%INCLUDE "boot/long_mode.asm"
