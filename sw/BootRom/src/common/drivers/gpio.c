#include "mips/io.h"
#include "drivers/gpio.h"

#define GPIO_REG_BASE 0xB8000400

void gpio_set_out(int num)
{
    int addr = num/16*4 + GPIO_REG_BASE;
    int offset = num % 16;
    int data = in_long(addr);
    data |= (1 << (offset*2));
    out_long(addr, data);
}
void gpio_set_in(int num)
{
    int addr = num/16*4 + GPIO_REG_BASE;
    int offset = num % 16;
    int data = in_long(addr);
    data &= ~(1 << (offset*2));
    out_long(addr, data);

}

void gpio_set(int num)
{
    int addr = num/16*4 + GPIO_REG_BASE;
    int offset = num % 16;
    int data = in_long(addr);
    data |= (1 << (offset*2+1));
    out_long(addr, data);

}
 
void gpio_clear(int num)
{
    int addr = num/16*4 + GPIO_REG_BASE;
    int offset = num % 16;
    int data = in_long(addr);
    data &= ~(1 << (offset*2+1));
    out_long(addr, data);
}
 
int gpio_get(int num)
{
    int addr = num/16*4 + GPIO_REG_BASE;
    int offset = num % 16;
    int data = in_long(addr);
    data &= (1 << (offset*2+1));
    return (data != 0);
}
