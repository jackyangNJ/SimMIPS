#ifndef _SD_FAT_H_
#define _SD_FAT_H_
#include "types.h"

	int sd_fat_init();
	int list_root_files(uint8_t* buffer);
	int read_file(const char* file_name, int offset, int size, uint8_t* buffer);
	int get_file_size(const char* file_name);
	int find_file_item_num(const char* file_name);
	
#endif