#include "kernel/kernel_panic.h"
#include "kernel/vga.h"
#include "kernel/kernel_attrs.h" //will remove later, only for
                                 //godbolt compiler 
                                 //right now
KERNEL_NORETURN void kernel_halt(void)
{
    for (;;) {
        __asm__ volatile ("hlt");
    }
}

KERNEL_NORETURN void kernel_panic(const char *msg)
{
    vga_write("KERNEL PANIC: ");
    vga_write(msg);
    vga_writec('\n');

    kernel_halt();
}
