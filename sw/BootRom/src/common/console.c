#include "console.h"
#include "string.h"
#include "fs/elf.h"
#include "fs/sd_fat.h"
#include "drivers/serial.h"
#include "drivers/spi_sd.h"
#include "mips/cpu.h"
#include "mips/io.h"
#include "serial-msg.h"


int console_get_command(char * parameter) {
    char str_buf[100];
    int i = 0;
    memset(str_buf, 0, sizeof (str_buf));

    while (true) {
        uint8_t ch = serial_read_byte();
        serial_printc(ch);
        if (ch != '\n' && ch != '\r')
            str_buf[i++] = ch;
        else
            break;
    }

    int rtn = 0;
    switch (str_buf[0]) {
        case 'L':
            strcpy(parameter, &str_buf[5]);
            rtn = CMD_LOAD;
            break;
        case 'D':
            rtn = CMD_DIR;
            break;
        case 'R':
            rtn = CMD_RUN;
            strcpy(parameter, &str_buf[4]);
            break;
        case 'G':
            rtn = CMD_GO;
            strcpy(parameter, &str_buf[3]);
            break;
        case 'H':
            rtn = CMD_HELP;
            break;
        case 'T':
            rtn = CMD_TRANSFER;
            break;
        case '\0':
            rtn = CMD_NULL;
            break;
        case 'S':
            rtn = CMD_SHOW;
            break;
        default:
            rtn = CMD_UNKNOWN;
            break;
            
    }
    return rtn;
}

void console_print_help() {
    serial_printf("help:\n");
    serial_printf("1. LOAD file-name. -->load file from SD card to memory \n");
    serial_printf("2. DIR.  --> list all file names in SD root directory \n");
    serial_printf("3. RUN file-name. --> run the executable file from SD card \n");
    serial_printf("4. GO address. --> set MIPS PC to the value of address\n");
    serial_printf("5. HELP. --> help usage \n");
    serial_printf("6. TRANFER. --> set into transfer mode,so that you can transfer your executable program to memory from serial rather than SD card. In this mode,you need to use BootClient program on PC. \n");
    serial_printf("7. SHOW sectorAddr(in hex:0x123), show the content of SD card at specified sector address,the size is 512 Byte")
    serial_printf("NOTE: All commands must be in capital \n");
}

int console_load(char* filename) {
    int rtn = load_elf(filename);
    if (rtn < 0)return -1;
    return 0;
}

/* Send bin file command
 * |1       |4      |4    |....         |
 * |cmd type|length |addr |file content.|
 * Boot command
 * |1       |4      |
 * |cmd type|addr   |
 */
int console_transfer() {
    int i;
    uint32_t addr;
    uint8_t type;
    
    while(true){
        type = serial_read_byte();
        if (type == SERIAL_MSG_BIN_TYPE) {
            serial_printf("type:receive bin file\n");
            uint32_t length = serial_read_int();
            serial_printf("file length = %x\n", length);
            addr = serial_read_int();
            serial_printf("target addr = %x\n", addr);
            
            for (i = 0; i < length; i++) 
                out_byte(addr + i, serial_read_byte());
        } else
            if (type == SERIAL_MSG_BOOT_TYPE) {
            serial_printf("type:boot \n");
            addr = serial_read_int();
            serial_printf("goto addr = %x\n", addr);
            serial_flush();
            cpu_jump(addr);
        }
    }
    return 0;
}

void console_loop() {
    int cmd;
    uint32_t addr;
    char parameter[100];
    uint8_t buffer[512];
    int j,k;
    while (true) {
        serial_printf("mips> ");
        cmd = console_get_command(parameter);
        switch (cmd) {
            case CMD_LOAD:
                if (console_load(parameter) < 0)
                    serial_printf("Load error\n");
                else
                    serial_printf("LOAD succeed\n");
                break;
            case CMD_DIR:
                if (list_root_files((uint8_t*)parameter) < 0)
                    serial_printf("Can't read root directory \n");
                else
                    serial_printf(parameter);
                break;
            case CMD_RUN:
                if (excute_elf(parameter) < 0)
                    serial_printf("Can't execute %s\n", parameter);
                break;
            case CMD_GO:
                addr = str2hex(parameter);
                serial_printf("go addr=%x\n",addr);
                cpu_jump(addr);
                break;
            case CMD_HELP:
                console_print_help();
                break;
            case CMD_TRANSFER:
                console_transfer();
                break;
            case CMD_UNKNOWN:
                serial_printf("Unknown command,please type again. \n");
                break;
            case CMD_NULL:
                break;
            case CMD_SHOW:
                addr = str2hex(parameter);
                sd_read_sector(addr, buffer);
                serial_printf("At sector address %s :\n",parameter);
                for(j=0;j<32;j++){
                    for(k=0;k<16;k++)
                        serial_printf("%x ",buffer[j*16+k]);
                    for(k=0;k<16000;k++);
                    serial_printf("\n");
                } 
        }
    }
}