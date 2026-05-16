#include "stdint.h"
#include "kernel_attrs.h"


#define VGA_LEN 4000
//vga
KERNEL_FUNCTION void vga_clear(void);
KERNEL_FUNCTION void vga_writec(char c);
KERNEL_FUNCTION void vga_write(const char* str);
