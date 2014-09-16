#include "drivers/spi.h"
#include "drivers/spi_sd.h"
#include "drivers/serial.h"

uint32_t sd_type;

void spi_write_byte(uint8_t data) {
    spi_transfer(data);
}

uint8_t spi_read_byte() {
    return spi_transfer(0xFF);
}

//set CS low  
void cs_enable() {
    //set CS low  
    spi_enable(0);
}

//set CS high and send 8 clocks  

void cs_disable() {
    //set CS high  
    spi_disable();
    //send 8 clocks  
    spi_write_byte(0xFF);
}

//send a command and send back the response  

uint8_t sd_send_cmd(uint8_t cmd, uint32_t arg, uint8_t crc) {
    uint8_t r1, time = 0;

    //send the command,arguments and CRC  
    spi_write_byte((cmd & 0x3f) | 0x40);
    spi_write_byte(arg >> 24);
    spi_write_byte(arg >> 16);
    spi_write_byte(arg >> 8);
    spi_write_byte(arg);
    spi_write_byte(crc);

    //read the respond until responds is not '0xff' or timeout  
    do {
        r1 = spi_read_byte();
        time++;
        //if time out,return
        if (time > 254) break;
    } while (r1 == 0xff);

    return r1;
}

//reset SD card  

uint8_t sd_reset() {
    uint8_t i, r1, time = 0;
    //set CS high
    cs_disable();
    //send 128 clocks  
    for (i = 0; i < 16; i++) {
        spi_write_byte(0xff);
    }
    //set CS low  
    cs_enable();

    //send CMD0 till the response is 0x01  
    do {
        r1 = sd_send_cmd(CMD0, 0, 0x95);
        time++;
        //if time out,set CS high and return r1  
        if (time > 254) {
            //set CS high and send 8 clocks  
            cs_disable();
            return r1;
        }
    } while (r1 != 0x01);
    //set CS high and send 8 clocks  
    cs_disable();
    serial_printf("sd_reset ok\n");
    return 0;
}

//initial SD card(send CMD55+ACMD41 or CMD1)  

uint8_t sd_init() {
    uint8_t i,r1, time = 0;

	//sd reset
	sd_reset();
	
    //set CS low  
    cs_enable();

    //check interface operating condition  
    r1 = sd_send_cmd(CMD8, 0x000001aa, 0x87);
    //if support Ver1.x,but do not support Ver2.0,set CS high and return r1  
    if (r1 == 0x05) {
        //set CS high and send 8 clocks  
        cs_disable();
        sd_type = SD_CARD_TYPE_SD1;
        return r1;
    }
    //read the other 4 bytes of response(the response of CMD8 is 5 bytes)  
    for(i=0;i<4;i++) r1 = spi_read_byte();
    
    sd_type = SD_CARD_TYPE_SD2;
    serial_printf("support Ver2.0\n");
    
	//send CMD55+ACMD41 to initial SD card  
    do {
        do {
            r1 = sd_send_cmd(CMD55, 0, 0xff);
            time++;
            //if time out,set CS high and return r1  
            if (time > 254){
                //set CS high and send 8 clocks
                cs_disable();
                return r1;
            }
        } while (r1 != 0x01);

        r1 = sd_send_cmd(ACMD41, 0x40000000, 0xff);

        //send CMD1 to initial SD card  
        // r1 = sd_send_cmd(CMD1,0x00ffc000,0xff);  
        time++;

        //if time out,set CS high and return r1  
        if (time > 254) {
            //set CS high and send 8 clocks  
            cs_disable();
            return r1;
        }
    } while (r1 != 0x00);

    // if SD2 read OCR register to check for SDHC card
    r1 = sd_send_cmd(CMD58,0,0xFF);
    if (r1 == 0x05) {
        cs_disable();
        return r1;
    }
    r1 = spi_read_byte();
	
    if(r1 & 0x40){
        sd_type = SD_CARD_TYPE_SDHC;
        serial_printf("SDHC card \n");
    }
    for(i=0;i<3;i++) r1 = spi_read_byte();
	
    //set CS high and send 8 clocks  
    cs_disable();
    
    serial_printf("sd_init ok\n");
    return 0;
}

//read a single sector  

uint8_t sd_read_sector(uint32_t addr, uint8_t * buffer) {
    uint8_t r1;
    uint16_t i, time = 0;

	if(sd_type != SD_CARD_TYPE_SDHC) addr <<= 9;
	
	// serial_printf("read addr=%x\n",addr);
    //set CS low  
    cs_enable();
    //send CMD17 for single block read  
    r1 = sd_send_cmd(CMD17, addr, 0x55);
    //if CMD17 fail,return  
    if (r1 != 0x00) {
        //set CS high and send 8 clocks  
        cs_disable();
        return r1;
    }

    //continually read till get the start byte 0xfe  
    do {
        r1 = spi_read_byte();
        time++;
        //if time out,set CS high and return r1  
        if (time > 30000) {
            //set CS high and send 8 clocks  
            cs_disable();
            return r1;
        }
    } while (r1 != 0xfe);

    //read 512 Bits of data  
    for (i = 0; i < 512; i++) {
        buffer[i] = spi_read_byte();
    }

    //read two bits of CRC  
    spi_read_byte();
    spi_read_byte();

    //set CS high and send 8 clocks  
    cs_disable();

    return 0;
}

//read multiple sectors  

uint8_t sd_read_multi_sector(uint32_t addr, uint8_t sector_num, uint8_t * buffer) {
    uint16_t i, time = 0;
    uint8_t r1;

    //set CS low  
    cs_enable();

    //send CMD18 for multiple blocks read  
    r1 = sd_send_cmd(CMD18, addr << 9, 0xff);
    //if CMD18 fail,return  
    if (r1 != 0x00) {
        //set CS high and send 8 clocks  
        cs_disable();
        return r1;
    }

    //read sector_num sector  
    do {
        //continually read till get start byte  
        do {
            r1 = spi_read_byte();
            time++;
            //if time out,set CS high and return r1  
            if (time > 30000 || ((r1 & 0xf0) == 0x00 && (r1 & 0x0f))) {
                //set CS high and send 8 clocks  
                cs_disable();
                return r1;
            }
        } while (r1 != 0xfe);
        time = 0;

        //read 512 Bits of data  
        for (i = 0; i < 512; i++) {
            *buffer++ = spi_read_byte();
        }

        //read two bits of CRC  
        spi_read_byte();
        spi_read_byte();
    } while (--sector_num);
    time = 0;

    //stop multiple reading  
    r1 = sd_send_cmd(CMD12, 0, 0xff);

    //set CS high and send 8 clocks  
    cs_disable();

    return 0;
}

//write a single sector  

uint8_t sd_write_sector(uint32_t addr, uint8_t * buffer) {
    uint16_t i, time = 0;
    uint8_t r1;

    //set CS low  
    cs_enable();

    do {
        do {
            //send CMD24 for single block write  
            r1 = sd_send_cmd(CMD24, addr << 9, 0xff);
            time++;
            //if time out,set CS high and return r1  
            if (time > 254) {
                //set CS high and send 8 clocks  
                cs_disable();
                return r1;
            }
        } while (r1 != 0x00);
        time = 0;

        //send some dummy clocks  
        for (i = 0; i < 5; i++) {
            spi_write_byte(0xff);
        }

        //write start byte  
        spi_write_byte(0xfe);

        //write 512 bytes of data  
        for (i = 0; i < 512; i++) {
            spi_write_byte(buffer[i]);
        }

        //write 2 bytes of CRC  
        spi_write_byte(0xff);
        spi_write_byte(0xff);

        //read response  
        r1 = spi_read_byte();
        time++;
        //if time out,set CS high and return r1  
        if (time > 254) {
            //set CS high and send 8 clocks  
            cs_disable();
            return r1;
        }
    } while ((r1 & 0x1f) != 0x05);
    time = 0;

    //check busy  
    do {
        r1 = spi_read_byte();
        time++;
        //if time out,set CS high and return r1  
        if (time > 60000) {
            //set CS high and send 8 clocks  
            cs_disable();
            return r1;
        }
    } while (r1 != 0xff);

    //set CS high and send 8 clocks  
    cs_disable();

    return 0;
}

//write several blocks  

uint8_t sd_write_multi_sector(uint32_t addr, uint8_t sector_num, uint8_t * buffer) {
    uint16_t i, time = 0;
    uint8_t r1;

    //set CS low  
    cs_enable();

    //send CMD25 for multiple block read  
    r1 = sd_send_cmd(CMD25, addr << 9, 0xff);
    //if CMD25 fail,return  
    if (r1 != 0x00) {
        //set CS high and send 8 clocks  
        cs_disable();
        return r1;
    }

    do {
        do {
            //send several dummy clocks  
            for (i = 0; i < 5; i++) {
                spi_write_byte(0xff);
            }

            //write start byte  
            spi_write_byte(0xfc);

            //write 512 byte of data  
            for (i = 0; i < 512; i++) {
                spi_write_byte(*buffer++);
            }

            //write 2 byte of CRC  
            spi_write_byte(0xff);
            spi_write_byte(0xff);

            //read response  
            r1 = spi_read_byte();
            time++;
            //if time out,set CS high and return r1  
            if (time > 254) {
                //set CS high and send 8 clocks  
                cs_disable();
                return r1;
            }
        } while ((r1 & 0x1f) != 0x05);
        time = 0;

        //check busy  
        do {
            r1 = spi_read_byte();
            time++;
            //if time out,set CS high and return r1  
            if (time > 30000) {
                //set CS high and send 8 clocks  
                cs_disable();
                return r1;
            }
        } while (r1 != 0xff);
        time = 0;
    } while (--sector_num);

    //send stop byte  
    spi_write_byte(0xfd);

    //check busy  
    do {
        r1 = spi_read_byte();
        time++;
        //if time out,set CS high and return r1  
        if (time > 30000) {
            //set CS high and send 8 clocks  
            cs_disable();
            return r1;
        }
    } while (r1 != 0xff);

    //set CS high and send 8 clocks  
    cs_disable();

    return 0;
}

uint8_t get_csd_reg(csd_t* csd) {
    uint8_t r1;
    uint16_t i, time = 0;
    uint8_t * buffer = (uint8_t*) csd;
    //set CS low  
    cs_enable();

    //send CMD10 for CID read or CMD9 for CSD  
    do {
        r1 = sd_send_cmd(CMD9, 0, 0xff);
        time++;
        //if time out,set CS high and return r1  
        if (time > 254) {
            //set CS high and send 8 clocks  
            cs_disable();
            return -1;
        }
    } while (r1 != 0x00);
    time = 0;

    //continually read till get 0xfe  
    do {
        r1 = spi_read_byte();
        time++;
        //if time out,set CS high and return r1  
        if (time > 30000) {
            //set CS high and send 8 clocks  
            cs_disable();
            return -1;
        }
    } while (r1 != 0xfe);

    //read 512 Bits of data  
    for (i = 0; i < 16; i++) {
        *buffer++ = spi_read_byte();
    }

    //read two bits of CRC  
    spi_read_byte();
    spi_read_byte();

    //set CS high and send 8 clocks  
    cs_disable();

    return 0;
}

/**
 * Determine the size of an SD flash memory card.
 *
 * \return The number of 512 byte data blocks in the card
 *         or zero if an error occurs.
 */
uint32_t sd_size(void) {
    csd_t csd;

    if (get_csd_reg(&csd) == -1)
        return 0;

    if (csd.v1.csd_ver == 0) {
        uint8_t read_bl_len = csd.v1.read_bl_len;
        uint16_t c_size = (csd.v1.c_size_high << 10)
                | (csd.v1.c_size_mid << 2) | csd.v1.c_size_low;
        uint8_t c_size_mult = (csd.v1.c_size_mult_high << 1)
                | csd.v1.c_size_mult_low;
        return (uint32_t) (c_size + 1) << (c_size_mult + read_bl_len + 2);
    } else if (csd.v2.csd_ver == 1) {
        uint32_t c_size = ((uint32_t) csd.v2.c_size_high << 16)
                | (csd.v2.c_size_mid << 8) | csd.v2.c_size_low;
        return (c_size + 1) << 10;
    } else {
        return 0;
    }
}
