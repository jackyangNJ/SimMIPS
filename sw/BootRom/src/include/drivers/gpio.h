#ifndef __MIPS_GPIO_H__
#define __MIPS_GPIO_H__

#include "types.h"

	

 	void gpio_set_out(int num);
 	void gpio_set_in(int num);
    
 	void gpio_set(int num);
 	void gpio_clear(int num);
 	int gpio_get(int num);

#endif


