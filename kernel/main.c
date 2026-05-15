#include "stdint.h"
#include "kernel_attrs.h"
#define VGA_LEN 4000
volatile char* vga_memory = (volatile char*)0xb8000;
uint16_t g_vgacurrent_pointer = 0;

static KERNEL_FUNC void vga_clear();
static KERNEL_FUNC void vga_print(const char* str);



int KERNEL_FUNC main()
{
   vga_clear();
   vga_print("HELLO there\nFrom kernel main!");
   __asm__ volatile ("hlt");
   return 1;
}

static KERNEL_FUNC void vga_clear()
{
   for(int i = 0; i < VGA_LEN; i++)
      vga_memory[i] = 0x00;
}

static KERNEL_FUNC void vga_print(const char* str)
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
