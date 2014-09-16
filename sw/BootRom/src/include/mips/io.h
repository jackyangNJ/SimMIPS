#ifndef __MIPS_IO_H__
#define __MIPS_IO_H__

#include "types.h"
// we cannot put the base to 0x98000000, since kseg0 is cached by default
#define MEM_MAP_IO_BASE 0xB8000000


static inline uint8_t
in_byte(uint32_t port) {
	return *(uint8_t volatile*)(port);
}

static inline uint16_t
in_word(uint32_t port) {
	return *(uint16_t volatile*)(port);
}

static inline int 
in_long(uint32_t port) {
	return *(uint32_t volatile*)(port);
}

static inline void
out_byte(uint32_t port, uint8_t data) {
	*(uint8_t volatile*)(port) = data;
}

static inline void
out_word(uint32_t port, uint16_t data) {
	*(uint16_t volatile*)(port) = data;
}

static inline void
out_long(uint32_t port, uint32_t data) {
	*(int volatile*)(port) = data;
}

#endif
