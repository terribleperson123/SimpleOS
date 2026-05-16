#ifndef KERNEL_IO_H
#define KERNEL_IO_H

#include "stdint.h"
#include "kernel_attrs.h"

KERNEL_STATIC KERNEL_INLINE KERNEL_FUNCTION void outb(uint16_t port, uint8_t value)
{
    __asm__ volatile ("outb %0, %1":: "a"(value), "Nd"(port));
}

KERNEL_STATIC KERNEL_INLINE KERNEL_FUNCTION uint8_t inb(uint16_t port)
{
    uint8_t ret;

    __asm__ volatile ( "inb %1, %0" : "=a"(ret): "Nd"(port));

    return ret;
}

KERNEL_STATIC KERNEL_INLINE KERNEL_FUNCTION io_wait(void)
{
    outb(0x80, 0);
}

KERNEL_STATIC KERNEL_FUNCTION enable_interrupts(void)
{
    __asm__ volatile ("sti" ::: "memory");
}

KERNEL_STATIC KERNEL_INLINE KERNEL_FUNCTION disable_interrupts(void)
{
    __asm__ volatile ("cli" ::: "memory");
}

KERNEL_STATIC KERNEL_INLINE KERNEL_FUNCTION cpu_halt(void)
{
    __asm__ volatile ("hlt");
}

#endif
