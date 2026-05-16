#ifndef KERNEL_ATTRS_H
#define KERNEL_ATTRS_H

#if defined(__GNUC__) || defined(__clang__)

#define ATTR(...) __attribute__((__VA_ARGS__))

#define KERNEL_FUNCTION \
    ATTR(target("general-regs-only"), optimize("no-tree-vectorize"))

#define KERNEL_SLOW_FUNCTION \
    ATTR(target("general-regs-only"), optimize("O0,no-tree-vectorize"), noinline)

#define KERNEL_NORETURN   ATTR(noreturn)
#define KERNEL_NO_INLINE  ATTR(noinline)
#define KERNEL_USED       ATTR(used)
#define KERNEL_UNUSED     ATTR(unused)
#define KERNEL_PACKED     ATTR(packed)
#define KERNEL_ALIGNED(x) ATTR(aligned(x))
#define KERNEL_INLINE     inline

#else

#define ATTR(...)
#define KERNEL_FUNCTION
#define KERNEL_SLOW_FUNCTION
#define KERNEL_NORETURN
#define KERNEL_NO_INLINE
#define KERNEL_USED
#define KERNEL_UNUSED
#define KERNEL_PACKED
#define KERNEL_ALIGNED(x)
#define KERNEL_INLINE inline

#endif

#endif
