#ifndef __MIPS_CP0_H__
#define __MIPS_CP0_H__
#include "types.h"

#define CP0_ENTRYLO0 2
#define CP0_ENTRYLO1 3
#define CP0_ENTRYHI 10
#define CP0_STATUS 12
#define CP0_CAUSE 13
#define CP0_EPC 14
#define CP0_PRID 15
#define CP0_CONFIG 16
#define CP0_TAGLO 28
#define CP0_DATALO 28

static inline uint32_t read_cp0(uint8_t index) {
	uint32_t result;
	asm volatile ("mfc0 %0, $%1" : "=r"(result) : "i"(index));
	return result;
}

static inline void write_cp0(uint8_t index, uint32_t data) {
	asm volatile ("mtc0 %0, $%1" : : "r"(data), "i"(index));
}

static inline uint32_t read_cp0_sel1(uint8_t index) {
	uint32_t result;
	asm volatile ("mfc0 %0, $%1, 1" : "=r"(result) : "i"(index));
	return result;
}

static inline uint32_t read_cause() {
	return read_cp0(CP0_CAUSE);
}

static inline void write_cause(uint32_t data) {
	write_cp0(CP0_CAUSE, data);
}

static inline uint32_t read_epc() {
	return read_cp0(CP0_EPC);
}

static inline void write_epc(uint32_t data) {
	write_cp0(CP0_EPC, data);
}


static inline uint32_t read_status() {
	return read_cp0(CP0_STATUS);
}

static inline void write_status(uint32_t data) {
	write_cp0(CP0_STATUS, data);
}

#endif
