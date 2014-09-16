#ifndef __MIPS_GPIO_H__
#define __MIPS_GPIO_H__

#include "types.h"

	

 	void gpio_configure(uint32_t config);
 	void gpio_set(int num);
 	void gpio_clear(int num);
 	int gpio_get(int num);

#endif


