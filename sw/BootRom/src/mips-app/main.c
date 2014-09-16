#include "mips/cpu.h"
#include "mips/io.h"
#include "drivers/serial.h"
#include "mips/cp0.h"
#include "drivers/gpio.h"
#include "drivers/spi.h"
#include "drivers/vga.h"
#include "drivers/spi_sd.h"
#include "fs/sd_fat.h"
#include "console.h"

extern void init_irq();

void print_memory(uint32_t addr,int size,int type)
{
    int i;
    if(type == 1){
        for(i=0;i<size;i++){
            uint8_t data = in_byte(addr+i);
            serial_printf("addr 0x%x=%x\n",addr+i,data);
        }
    }else
        if(type == 2){
           for(i=0;i<size;i+=2){
                uint16_t data = in_word(addr+i);
                serial_printf("addr 0x%x=%x\n",addr+i,data);
            }
                
        }
        else
            if(type == 4){
                for(i=0;i<size;i+=4){
                   uint32_t data = in_long(addr+i);
                   serial_printf("addr 0x%x=%x\n",addr+i,data);
                }
            }

}
void gpio_loop()
{
    int i;
    gpio_configure(0xFFFF0000);
    while(true){
        for(i=0;i<16;i++){
            int value = gpio_get(i);
            if(value)
                gpio_set(16+i);
            else
                gpio_clear(16+i);
        }
    }
}    
void c_entry()
{

    serial_init();
    serial_printf("serial init complete!\n");
    // gpio_loop();    
    spi_init();
    serial_printf("spi init complete!\n");
    sd_init();
    serial_printf("sd card init complete!\n");
    sd_fat_init();
    serial_printf("fat32 fs init complete!\n");
    
    console_loop();
}

