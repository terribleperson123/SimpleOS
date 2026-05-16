#ifndef KERNEL_IDT_H
#define KERNEL_IDT_H

#include "kernel/stdint.h"

void idt_init(void);
void idt_exception_handler(uint64_t vector, uint64_t error_code);

#endif
