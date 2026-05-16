#include "kernel/kernel_attrs.h"
#include "kernel/vga.h"

KERNEL_FUNCTION int main(void)
{

   vga_clear();
   vga_write("HELLO there!\n");
   vga_write("From kernel main!\n");

   __asm__ volatile ("hlt");
   return 1;
}
