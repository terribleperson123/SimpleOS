#include "kernel/vga.h"
#include "kernel/kernel_attrs.h"


volatile char* vga_memory = (volatile char*)0xb8000;
uint16_t g_vgacurrent_pointer = 0;



//CLEAR SCREEN
KERNEL_FUNCTION void vga_clear(void)
{
   for(int i = 0; i < VGA_LEN; i++)
      vga_memory[i] = 0x00;
   g_vgacurrent_pointer = 0;
}
KERNEL_FUNCTION void vga_writec(char c)
{
   vga_memory[g_vgacurrent_pointer * 2] = c;
   vga_memory[g_vgacurrent_pointer * 2 + 1] = 0x0f; //white
   g_vgacurrent_pointer++;
}
//PRINT SCREEN
KERNEL_FUNCTION void vga_write(const char* str)
{
   for(; *str != '\0'; str++)
   {
      if(*str == '\n')
      {
         g_vgacurrent_pointer += 80 - (g_vgacurrent_pointer % 80);
      }
      else
      {
         vga_writec(*str);  
      }
   }
}
