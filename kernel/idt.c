#include "kernel/stdint.h"
#include "kernel/idt.h"
#include "kernel/vga.h"
#include "kernel/kernel_panic.h"
#include "kernel/kernel_attrs.h"

#define IDT_MAX_ENTRIES 256
#define IDT_KERNEL_CODE_SELECTOR 0x08
#define IDT_INTERRUPT_GATE 0x8E

struct idt_entry {
    uint16_t offset_low;
    uint16_t selector;
    uint8_t  ist;
    uint8_t  type_attr;
    uint16_t offset_mid;
    uint32_t offset_high;
    uint32_t zero;
} ATTR(packed);

struct idt_ptr {
    uint16_t limit;
    uint64_t base;
} ATTR(packed);

static struct idt_entry g_idt[IDT_MAX_ENTRIES];

extern void idt_load(struct idt_ptr *idtr);

extern void isr0(void);
extern void isr3(void);
extern void isr13(void);
extern void isr14(void);

static KERNEL_FUNCTION void idt_set_gate(uint8_t vector, void *handler)
{
    uint64_t addr = (uint64_t)handler;

    g_idt[vector].offset_low  = addr & 0xFFFF;
    g_idt[vector].selector    = IDT_KERNEL_CODE_SELECTOR;
    g_idt[vector].ist         = 0;
    g_idt[vector].type_attr   = IDT_INTERRUPT_GATE;
    g_idt[vector].offset_mid  = (addr >> 16) & 0xFFFF;
    g_idt[vector].offset_high = (addr >> 32) & 0xFFFFFFFF;
    g_idt[vector].zero        = 0;
}
KERNEL_FUNCTION void idt_init(void)
{
    struct idt_ptr idtr;

    for (int i = 0; i < IDT_MAX_ENTRIES; i++) {
        idt_set_gate(i, isr3);
    }

    idt_set_gate(0, isr0);
    idt_set_gate(3, isr3);
    idt_set_gate(13, isr13);
    idt_set_gate(14, isr14);

    idtr.limit = sizeof(g_idt) - 1;
    idtr.base = (uint64_t)&g_idt;

    idt_load(&idtr);
}

void idt_exception_handler(uint64_t vector, uint64_t error_code)
{
    vga_write("INTERRUPT: ");

    if (vector == 0) {
        vga_write("divide by zero\n");
    } else if (vector == 3) {
        vga_write("breakpoint\n");
    } else if (vector == 13) {
        vga_write("general protection fault\n");
    } else if (vector == 14) {
        vga_write("page fault\n");
    } else {
        vga_write("unknown\n");
    }

    vga_write("Halting.\n");
    kernel_halt();
}
