#ifndef _CONSOLE_H_
#define _CONSOLE_H_

#include "types.h"
//default using serial lib

/* COMMAND list */
#define CMD_LOAD 0
#define CMD_DIR 1
#define CMD_RUN 2
#define CMD_GO 3
#define CMD_HELP 4
#define CMD_TRANSFER 5
#define CMD_UNKNOWN 6
#define CMD_NULL 7
#define CMD_SHOW 8
#define CMD_WRITE 9
#define CMD_READ 10

int console_get_command(char * parameter);
void console_print_help();
int console_load(char* filename);
int console_transfer();
void console_loop();


#endif
