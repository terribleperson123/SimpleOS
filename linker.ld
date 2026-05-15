ENTRY(kernel_entry)

SECTIONS
{
    /*
     * Your bootloader loads kernel.bin to physical 0x100000.
     * So the linked addresses must also start at 0x100000.
     */
    . = 0x100000;

    .text : ALIGN(4096)
    {
        KEEP(*(.text.kernel_entry))
        *(.text*)
    }

    .rodata : ALIGN(4096)
    {
        *(.rodata*)
    }

    .data : ALIGN(4096)
    {
        *(.data*)
    }

    .bss : ALIGN(4096)
    {
        *(COMMON)
        *(.bss*)
    }
}
