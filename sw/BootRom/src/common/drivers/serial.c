#include "drivers/serial.h"
#include "mips/io.h"
#include "vfprintf.h"

void serial_init(void) 
{
	out_byte(SERIAL_PORT + 1, 0x00);
	out_byte(SERIAL_PORT + 3, 0x80);
	out_byte(SERIAL_PORT + 0, 27);
	out_byte(SERIAL_PORT + 1, 0x00);
	out_byte(SERIAL_PORT + 3, 0x03);
	out_byte(SERIAL_PORT + 2, 0xC7);
	out_byte(SERIAL_PORT + 4, 0x0B);
	//enable receive intterrupt
	// out_byte(SERIAL_PORT + 1, 0x01);
}



inline int serial_idle(void) 
{
	return (in_byte(SERIAL_PORT + 5) & 0x20) != 0;
}

static inline int serial_has_data()
{
	return (in_byte(SERIAL_PORT + 5) & 0x01) != 0;
}

void serial_printc(char ch) 
{
	while (serial_idle() != 1);
	out_byte(SERIAL_PORT, ch);
}

void serial_prints(const char* str)
{
    while(*str != '\0') { /* Loop until end of string */
        serial_printc( *str );
        str++;
    }
}

int serial_printf(const char *ctl, ...)
{
	void **args = (void **)&ctl + 1;
	return vfprintf(ctl, args, serial_printc);
}


/**
 * in little endian
 */
int serial_read_int()
{
	int rtn = 0;
	int i;
	for(i=0;i<4;i++){
		uint8_t tmp = serial_read_byte();
		rtn |= tmp << (8*i);
	}
	return rtn;
}

uint8_t serial_read_byte()
{
	while(serial_has_data() == 0);
	return in_byte(SERIAL_PORT);
}

void serial_read(uint8_t* str,int length)
{
	int i;
	for(i=0;i<length;i++)
		str[i] = serial_read_byte();
}

void serial_flush()
{
	while(serial_idle() != 1);
}