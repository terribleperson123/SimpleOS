#include "kernel/memory.h"
#include "kernel/kernel_attrs.h"

KERNEL_FUNCTION void memcpy(void* dest, uint64_t size, void* src)
{
   char* c_d = (char*) dest;
   char* c_s = (char*) src;

   for(uint64_t i = 0; i < size; i++)
   {
     c_d[i] = c_s[i];
   }
}
KERNEL_FUNCTION void memset(void* dest, uint64_t size, uint8_t byte)
{
   char* c_d = (char*)dest;
   for(uint64_t i = 0; i < size; i++)
   {
      c_d[i] = byte;
   }
}
KERNEL_FUNCTION uint64_t strlen(const char* str)
{
   uint64_t i = 0;
   while(*str != '\0') i++;
   return i;
}
