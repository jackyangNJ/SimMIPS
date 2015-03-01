#include "mips/io.h"
#include "drivers/gpio.h"

#define GPIO_REG_BASE 0xB8000400
#define GPIO_REG_CTRL 0xB8000404
#define GPIO_REG_DATA 0xB8000400

void gpio_set_out(int num)
{
    int data = in_long(GPIO_REG_CTRL);
    data |= (1 << num);
    out_long(GPIO_REG_CTRL, data);
}
void gpio_set_in(int num)
{
    int data = in_long(GPIO_REG_CTRL);
    data &= ~(1 << num);
    out_long(GPIO_REG_CTRL, data);

}

void gpio_set(int num)
{
    int data = in_long(GPIO_REG_DATA);
    data |= (1 << num);
    out_long(GPIO_REG_DATA, data);

}
 
void gpio_clear(int num)
{
    int data = in_long(GPIO_REG_DATA);
    data &= ~(1 << num);
    out_long(GPIO_REG_DATA, data);
}
 
int gpio_get(int num)
{
    int data = in_long(GPIO_REG_DATA);
    data &= (1 << num);
    return (data != 0);
}