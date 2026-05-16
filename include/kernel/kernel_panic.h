#ifndef KERNEL_PANIC_H
#define KERNEL_PANIC_H

#include "kernel_attrs.h"

KERNEL_NORETURN void kernel_panic(const char *msg);
KERNEL_NORETURN void kernel_halt(void);

#endif
