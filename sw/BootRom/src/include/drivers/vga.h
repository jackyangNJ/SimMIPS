#ifndef VGA_H
#define	VGA_H

#include "types.h"

#define VGA_HIGH 60
#define VGA_WIDTH 80

#define VGA_BASEADDR 0xB8010000
#define VGA_CURSOR_EN_ADDR 0xB80112C0
#define VGA_CURSOR_X_ADDR 0xB80112C1
#define VGA_CURSOR_Y_ADDR 0xB80112C2

void vga_init();
void vga_printc(int x, int y, char ch);
void vga_prints(int x, int y, char* str);

#endif	
/* VGA_H */

