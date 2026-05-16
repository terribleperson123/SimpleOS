#ifndef KERNEL_IO_H
#define KERNEL_IO_H

#include "kernel/stdint.h"
#include "kernel/kernel_attrs.h"

static KERNEL_INLINE KERNEL_FUNCTION void outb(uint16_t port, uint8_t value)
{
    __asm__ volatile ("outb %0, %1":: "a"(value), "Nd"(port));
}

static KERNEL_INLINE KERNEL_FUNCTION uint8_t inb(uint16_t port)
{
    uint8_t ret;

    __asm__ volatile ( "inb %1, %0" : "=a"(ret): "Nd"(port));

    return ret;
}

static KERNEL_INLINE KERNEL_FUNCTION io_wait(void)
{
    outb(0x80, 0);
}

static KERNEL_FUNCTION enable_interrupts(void)
{
    __asm__ volatile ("sti" ::: "memory");
}

static KERNEL_INLINE KERNEL_FUNCTION disable_interrupts(void)
{
    __asm__ volatile ("cli" ::: "memory");
}

static KERNEL_INLINE KERNEL_FUNCTION cpu_halt(void)
{
    __asm__ volatile ("hlt");
}

#endif
