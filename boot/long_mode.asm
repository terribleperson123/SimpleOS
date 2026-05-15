[bits 64]

;;CURRENTLY, 41 DISKS ARE LOADED TO SUPPORT UP TO LONG_MODE.ASM
;;I'M GONNA LOAD KERNEL'S DISK SECTOR + a BIT MORE FROM 0x100000 to 0x1fffff so i'll load one mb for kernel
;;should be alot more then enough. 


KERNEL_ENTRY equ 0x100000 ;;KERNEL_ENTRY


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
   
   ;;load 1 mib worth of disk, from sector S
    mov eax, 42              ; lba starting, since we've loaded up to 41th disk starting from 0, we now load next from 42
    mov rdi, KERNEL_ENTRY    ; destination = 0x100000
    mov ecx, 0x800           ; 2048 sectors = 1 mb.

.load_sector:
    push rax
    push rcx
    push rdi
    call ata_read_sector     ; eax is laba, rdi is destination
    pop rdi
    pop rcx
    pop rax
    inc eax                  ; next LBA
    add rdi, 512             ; n
    dec ecx
    jnz .load_sector
    mov rax, KERNEL_ENTRY ;;not kernel main yet, but its an assembly stub which links to main.c
    jmp rax

.hlt:
   hlt ;;appatenrly this is an actual ins and i never knew
   jmp .hlt


;ngl this is copy paste but fine for now.

; ata_read_sector
; input:
;   EAX = LBA sector number
;   RDI = destination buffer address
;
; clobbers:
;   RAX, RBX, RCX, RDX
ata_read_sector:
    push rax
    push rdi

    ; Save LBA in EBX
    mov ebx, eax

.wait_bsy_1:
    mov dx, 0x1F7
    in al, dx
    test al, 0x80              ; BSY bit
    jnz .wait_bsy_1

    ; Select drive, LBA mode, high 4 bits of LBA
    mov dx, 0x1F6
    mov eax, ebx
    shr eax, 24
    and al, 0x0F
    or al, 0xE0                ; 1110_0000 = master drive + LBA mode
    out dx, al

    ; Sector count = 1
    mov dx, 0x1F2
    mov al, 1
    out dx, al

    ; LBA bits 0..7
    mov dx, 0x1F3
    mov eax, ebx
    out dx, al

    ; LBA bits 8..15
    mov dx, 0x1F4
    mov eax, ebx
    shr eax, 8
    out dx, al

    ; LBA bits 16..23
    mov dx, 0x1F5
    mov eax, ebx
    shr eax, 16
    out dx, al

    ; Command: READ SECTORS = 0x20
    mov dx, 0x1F7
    mov al, 0x20
    out dx, al

.wait_bsy_2:
    mov dx, 0x1F7
    in al, dx
    test al, 0x80              ; wait while BSY
    jnz .wait_bsy_2

.wait_drq:
    mov dx, 0x1F7
    in al, dx
    test al, 0x08              ; DRQ = data ready
    jz .wait_drq

    ; Read 256 words = 512 bytes from port 0x1F0
    pop rdi
    mov dx, 0x1F0
    mov rcx, 256
.read_words:
    in ax, dx
    mov [rdi], ax
    add rdi, 2
    loop .read_words

    pop rax
    ret
