#include "kernel/vga.h"
#include "kernel/idt.h"
KERNEL_FUNCTION int main(void)
{
   idt_init();
   vga_clear();
   vga_write("HELLO there!\n");
   vga_write("From kernel main!\n");

   //hlt test
   volatile int* h = (volatile int*) 0x200000;
   *h = 0;
   __asm__ volatile ("hlt");
   return 1;
}
