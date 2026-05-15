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
   _t_wait(4000);

   vga_print("From kernel main!\n");
   _t_wait(5000);

   vga_print("TODO: Make IDT to handle pg faults.\n");
   _t_wait(5000);

   vga_print("Then we page fault on purpose!\n");
   _t_wait(7000);


   vga_clear();

   vga_print("Welp, we halt now!\n");
   _t_wait(5000);
   vga_clear();
   int x = 0;
   while(1)
   {
      for(int i = 0; i < x; i++)
      {
         vga_print(".");
         _t_wait(300 + x);
      }
      vga_clear();
      x++;
   }
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

//TEMPERORY WAIT
//figured out that it takes around 3 seconds 
//so div three and div 1000 to get milisecond worth of
//addition
#define _T_WAIT_UMILLIS 0x00000000FFFFFFFF/3/1000
KERNEL_SLOW_FUNCTION void _t_wait(uint64_t millis)
{
    for(uint64_t i = 0; i < _T_WAIT_UMILLIS * millis; i++)
    {
      
    }
}
