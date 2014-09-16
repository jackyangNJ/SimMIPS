#include "drivers/spi_sd.h"
#include "fs/FatStructs.h"
#include "fs/sd_fat.h"
#include "drivers/serial.h"
#include "string.h"

/* global variables */
dir_t rootDirItem[20];
uint32_t rootDirSize;
uint8_t sd_buffer[512];
uint32_t firstPartitionSector;
fbs_t fbs;
mbr_t mbr;

int sd_fat_init() {
    //init fat struct
    sd_read_sector(0, sd_buffer);
    fbs = *(fbs_t*) sd_buffer;
    if (memcmp(fbs.oemName, "MSDOS5.0", 8) == 0) return 0;
    //mbr exists in sd-card
	
    /* mbr */
    mbr = *(mbr_t*) sd_buffer;
    firstPartitionSector = (mbr.part[0].firstSectorHigh << 16) + mbr.part[0].firstSectorLow;
    // serial_printf("firstPartitionSector=%x\n",firstPartitionSector);
    /* read boot  */
    sd_read_sector(firstPartitionSector, sd_buffer);
    fbs = *(fbs_t*) sd_buffer;
    
    /* initialize internal variables */
    rootDirSize = 0;
    return 0;
}

int list_root_files(uint8_t* buffer) {
    //data region star sector address
    int dataRegionSectorAddr = fbs.bpb.reservedSectorCount + fbs.bpb.fatCount * fbs.bpb.sectorsPerFat32 + firstPartitionSector;
    //sector addr for Root Directory
    int rootDirSectorAddr = dataRegionSectorAddr + (fbs.bpb.fat32RootCluster - 2) * fbs.bpb.sectorsPerCluster;
    //byte addr for Root Directory
    int rootDirAddr = rootDirSectorAddr * fbs.bpb.bytesPerSector;

    int i,pos = 0;
    bool flag = false;
    // int j,k;
    while (true) {
        sd_read_sector(rootDirAddr / SD_SECTOR_SIZE, sd_buffer);
        dir_t* dir = (dir_t*) sd_buffer;
        for (i = 0; i < SD_SECTOR_SIZE / sizeof (dir_t); i++) {
            if (DIR_IS_FREE(&dir[i])) {
                flag = true;
                break;
            }
            if (DIR_IS_FILE_OR_SUBDIR(&dir[i]) && (!DIR_IS_DELETED(&dir[i]))) {
                rootDirItem[rootDirSize++] = dir[i];
                int j;
                for (j = 0; j < 11; j++)
                    buffer[pos++] = dir[i].name[j];
                buffer[pos++] = '\n';
            }
        }
        if (flag) break;
        rootDirAddr += SD_SECTOR_SIZE;
    }
    buffer[pos] = '\0';
    return 0;
}

int get_file_size(const char* file_name) {
    int num = find_file_item_num(file_name);
    if (num < 0) return -1;

    return rootDirItem[num].fileSize;
}

/**
 * only match the file name ignoring the file extension
 */
int find_file_item_num(const char* file_name) {
    int AaDiff = 'a' - 'A';
    int i;

    bool found = false;
    for (i = 0; i < rootDirSize; i++) {
        if (DIR_IS_FILE(&rootDirItem[i])) {
            uint8_t * name = rootDirItem[i].name;
            //match file name
            int j;
            //only compare file name
            for (j = 0; j < 8; j++) {
                if (name[j] == ' ') continue;
                if (name[j] == ' ' && file_name[j] == '\0') found = true;
                if (name[j] == '~' && name[j + 1] == '1') found = true;
                if (name[j] == file_name[j] || (name[j] + AaDiff == file_name[j]))
                    continue;
                else
                    break;
                if (found) break;
            }
            if (j == 8) found = true;
            if (found)
                return i;
        }
    }
    return -1;
}

int read_file(const char* file_name, int offset, int size, uint8_t* buffer) {
    int num = find_file_item_num(file_name);
    if (num < 0) return -1;
    
    uint32_t startCluster = (rootDirItem[num].firstClusterHigh << 16) + rootDirItem[num].firstClusterLow;
    uint32_t dataRegionSectorAddr = fbs.bpb.reservedSectorCount + fbs.bpb.fatCount * fbs.bpb.sectorsPerFat32 + firstPartitionSector;
    uint32_t startSectorAddr = dataRegionSectorAddr + (startCluster - 2) * fbs.bpb.sectorsPerCluster;
    uint32_t addr = startSectorAddr * fbs.bpb.bytesPerSector + offset;

    // serial_printf("num=%d\n",num);
    // serial_printf("startCluster=%x\n",startCluster);
    // serial_printf("firstPartitionSector=%x\n",firstPartitionSector);
    int sectorBias = offset % SD_SECTOR_SIZE;
	num = 0;
    while (num < size) {
        sd_read_sector(addr / SD_SECTOR_SIZE, sd_buffer);
        int i;
        for (i = sectorBias; i < SD_SECTOR_SIZE && num < size; i++) {
            buffer[num++] = sd_buffer[i];
        }
    }
    return 0;
}
