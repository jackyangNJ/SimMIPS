#ifndef __MIPS_CPU_H__
#define __MIPS_CPU_H__

#include "types.h"
#include "cp0.h"

#define IE_MASK 0x1
#define EXL_MASK 0x2
#define ERL_MASK 0x4

struct Cause {
    uint32_t pad0 : 2;
    uint32_t exc_code : 5;
    uint32_t pad1 : 1;
    uint32_t ip : 8;
    uint32_t pad2 : 6;
    uint32_t wp : 1;
    uint32_t iv : 1;
    uint32_t pad3 : 4;
    uint32_t ce : 2;
    uint32_t pad4 : 1;
    uint32_t bd : 1;
};

struct TrapFrame {
    uint32_t magic;
    union {
        uint32_t all[32];
        struct {
            uint32_t r0, at, v0, v1, a0, a1, a2, a3,
                     t0, t1, t2, t3, t4, t5, t6, t7,
                     s0, s1, s2, s3, s4, s5, s6, s7,
                     t8, t9, k0, k1, gp, sp, s8, ra;
        };
    }gpr;
    uint32_t hi, lo;
    uint32_t epc;
    struct Cause cause;
    uint32_t status;
    uint32_t user_sp;
};

static inline void disable_interrupt() {
    write_status(read_status() & ~IE_MASK);
}

static inline void enable_interrupt() {
    // only set SR[IE], interrupts may be still disabled due to SR[EXL] == 1 or SR[ERL] == 1
    write_status(read_status() | IE_MASK);
}

static inline void idle_cpu() {
    asm volatile ("wait");
}

static inline void cpu_jump(uint32_t addr) {
    void (*routine)(void);
    routine = (void*)addr;
    routine();
}

#endif
