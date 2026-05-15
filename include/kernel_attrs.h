#ifndef KERNEL_ATTRS_H
#define KERNEL_ATTRS_H

#if defined(__GNUC__) || defined(__clang__)
   #define NO_VECTORIZE      __attribute__((optimize("no-tree-vectorize")))
   #define GENERAL_REGS_ONLY __attribute__((target("general-regs-only")))
   #define KERNEL_FUNC       GENERAL_REGS_ONLY NO_VECTORIZE
#else
   #define NO_VECTORIZE
   #define GENERAL_REGS_ONLY
   #define KERNEL_FUNC
#endif

#endif
