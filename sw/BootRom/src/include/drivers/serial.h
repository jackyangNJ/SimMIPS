#ifndef _SERIAL_H_
#define _SERIAL_H_

#include "types.h"

	#define SERIAL_PORT  0xB80003F8


	void serial_init();
	inline int serial_idle(void);
	void serial_printc(char ch);
	void serial_prints(const char* str);
	int serial_printf(const char *ctl, ...);
	uint8_t serial_read_byte();
	int serial_read_int();
	void serial_read(uint8_t* str,int length);
	void serial_flush();
	
#endif