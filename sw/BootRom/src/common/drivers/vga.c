#include "drivers/vga.h"
#include "mips/io.h"

void vga_init() {
    out_byte(VGA_CURSOR_EN_ADDR, 0);
}

void vga_printc(int x, int y, char ch) {
    if (x < 0 || x > VGA_HIGH) return;
    if (y < 0 || y > VGA_WIDTH) return;
    out_byte(x * VGA_WIDTH + y + VGA_BASEADDR, ch);
}

void vga_prints(int x, int y, char* str) {
    uint32_t addr = x * VGA_WIDTH + y + VGA_BASEADDR;
    while (*str != '\0') {
        out_byte(addr++, *str);
        str++;
    }
}


