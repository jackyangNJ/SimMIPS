#include "mips/io.h"
#include "drivers/gpio.h"

#define GPIO_REG_BASE 0xB8000400

void gpio_configure(uint32_t config)
{
	out_long(GPIO_REG_BASE+4,config);
	out_long(GPIO_REG_BASE,0xFFFFFFFF);
}


void gpio_set(int num)
{
	int value = in_long(GPIO_REG_BASE);
	out_long(GPIO_REG_BASE,value | 1<<num);
}
 
void gpio_clear(int num)
{
	int value = in_long(GPIO_REG_BASE);
	out_long(GPIO_REG_BASE,value & ~(1<<num));	
}
 
int gpio_get(int num)
{
	int value = in_long(GPIO_REG_BASE);
	return (value & (1<<num)) != 0;
}