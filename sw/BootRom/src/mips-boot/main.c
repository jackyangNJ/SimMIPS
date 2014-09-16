#include "mips/cpu.h"
#include "mips/io.h"
#include "drivers/serial.h"
#include "mips/cp0.h"
#include "drivers/gpio.h"
#include "serial-msg.h"
#include "drivers/spi_sd.h"
#include "fs/sd_fat.h"
#include "console.h"
#include "drivers/spi.h"
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
    
    // // int i;
    

    // out_long(0x88000000,0x3c01b800);
    // out_long(0x88000004,0x34210400);
    // out_long(0x88000008,0x3c02ffff);
    // out_long(0x8800000C,0xac220004);
    // out_long(0x88000010,0x94220000);
    // out_long(0x88000014,0xa4220002);
    // out_long(0x88000018,0x1000fffd);
    // out_long(0x8800001C,0x1000fffc);
    // print_memory(0x88000000,32,4);

    // cpu_jump(0x88000000);

/*     while(true){
        uint32_t addr;
        uint8_t type = serial_read_byte();

        if(type == SERIAL_MSG_BIN_TYPE){
            serial_printf("type:receive bin file.\n");
            uint32_t length = serial_read_int();
            serial_printf("length = %x\n",length);
            addr = serial_read_int();
            serial_printf("addr = %x\n",addr);
            int i;
            for(i=0;i<length;i++){
                uint8_t data = serial_read_byte();
                // addr[i] = data;
                out_byte(addr+i,data);
            }
        }
        else
            if(type == SERIAL_MSG_BOOT_TYPE){
                serial_printf("type:boot \n");
                addr = serial_read_int();
                serial_printf("goto addr = %x\n",addr);
                while(serial_idle() != 1);
                cpu_jump(addr);
            }

    } */
    
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




