#include "fs/elf.h"
#include "fs/sd_fat.h"
#include "string.h"
#include "mips/cpu.h"
#include "drivers/serial.h"


// extern void print_memory(uint32_t addr,int size,int type);

int load_elf(const char* name)
{
    uint8_t buffer[512];
    int rtn,i;
    ProgramHeader_t *program_headr = NULL;
    ELFHeader_t *elf_header;
    
    //read elf header
    rtn = read_file(name,0,512,buffer);
    /* int j,k;
           for(j=0;j<32;j++){
            for(k=0;k<16;k++)
                serial_printf("%x ",buffer[j*16+k]);
                for(k=0;k<1600;k++);
            serial_printf("\n");
        }  */
    if(rtn < 0 ) return -1;
    elf_header= (ELFHeader_t*) buffer;
    
    // serial_printf("load\n");
    // serial_printf("elf_header->phnum=%d\n",elf_header->phnum);
    //serach for LOAD program header
    for(i=0;i< elf_header->phnum;i++){
        program_headr = (ProgramHeader_t*)(buffer+elf_header->ehsize+sizeof(ProgramHeader_t)*i);
        if(program_headr->type == PT_LOAD) break;
    }
    if(program_headr->type != PT_LOAD) return -1;
    
    uint32_t offset = program_headr->off;
    uint32_t paddr = program_headr->paddr;
    uint32_t filesz = program_headr->filesz;
    
    serial_printf("offset=%x\n",offset);
    serial_printf("paddr=%x\n",paddr);
    serial_printf("filesz=%x\n",filesz);
    
    uint32_t counter = 0;
    while(counter < filesz){
        uint32_t size = (filesz-counter < 512)? filesz-counter : 512;
        rtn = read_file(name,counter+offset,size,buffer);
        if(rtn < 0) return -1;
        memcpy((void*)(paddr+counter),buffer,size);
        counter += size;
    }
    
    return 0;
}

int excute_elf(const char* name)
{
    int rtn;
    
    rtn = load_elf(name);
    if(rtn <0) return -1;
    
    uint32_t entry_addr = get_elf_entry(name);
    cpu_jump(entry_addr);
    return 0;
}

uint32_t get_elf_entry(const char* name)
{
    uint8_t buffer[512];
    int rtn;
    ELFHeader_t *elf_header;
    
    rtn = read_file(name,0,512,buffer);
    if(rtn < 0 ) return -1;
    
    elf_header= (ELFHeader_t*) buffer;
    return elf_header->entry;
}
;