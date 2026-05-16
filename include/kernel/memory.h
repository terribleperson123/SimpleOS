#ifndef MEMORY_H
#define MEMORY_H

#include "kernel/stdint.h"
#include "kernel/kernel_attrs.h"

KERNEL_FUNCTION void memcpy(void* dest, uint64_t size, void* src);
KERNEL_FUNCTION uint64_t strlen(const char* str);
KERNEL_FUNCTION void memset(void* dest, uint64_t size, uint8_t byte);

#endif
