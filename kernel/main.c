#include "stdint.h"
#include "kernel_attrs.h"
#define VGA_LEN 4000

//vga
volatile char* vga_memory = (volatile char*)0xb8000;
uint16_t g_vgacurrent_pointer = 0;

//noinline ONLY for now
KERNEL_NO_INLINE KERNEL_FUNCTION void vga_clear();
KERNEL_NO_INLINE KERNEL_FUNCTION void vga_print(const char* str);
KERNEL_SLOW_FUNCTION void _t_wait(uint64_t); //temperory

//KERNEL MAIN
KERNEL_FUNCTION int main()
{

   vga_clear();
   vga_print("HELLO there!\n");
   vga_print("From kernel main!\n");

   __asm__ volatile ("hlt");
   return 1;
}

//CLEAR SCREEN
KERNEL_NO_INLINE KERNEL_FUNCTION void vga_clear()
{
   for(int i = 0; i < VGA_LEN; i++)
      vga_memory[i] = 0x00;
   g_vgacurrent_pointer = 0;
}
//PRINT SCREEN
KERNEL_NO_INLINE KERNEL_FUNCTION void vga_print(const char* str)
{
   for(; *str != '\0'; str++)
   {
      if(*str == '\n')
      {
         g_vgacurrent_pointer += 80 - (g_vgacurrent_pointer % 80);
      }
      else
      {
         vga_memory[g_vgacurrent_pointer * 2] = *str;
         vga_memory[g_vgacurrent_pointer * 2 + 1] = 0x0f; //white
         g_vgacurrent_pointer++;
      }
   }
}

