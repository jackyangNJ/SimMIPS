#ifndef _SPI_SD_H_
#define _SPI_SD_H_

#include "types.h"


typedef struct{
  // byte 0
  uint8_t mid;  // Manufacturer ID
  // byte 1-2
  char oid[2];  // OEM/Application ID
  // byte 3-7
  char pnm[5];  // Product name
  // byte 8
  unsigned prv_m : 4;  // Product revision n.m
  unsigned prv_n : 4;
  // byte 9-12
  uint32_t psn;  // Product serial number
  // byte 13
  unsigned mdt_year_high : 4;  // Manufacturing date
  unsigned reserved : 4;
  // byte 14
  unsigned mdt_month : 4;
  unsigned mdt_year_low :4;
  // byte 15
  unsigned always1 : 1;
  unsigned crc : 7;
}cid_t;
//------------------------------------------------------------------------------
// CSD for version 1.00 cards
typedef struct CSDV1 {
  // byte 0
  unsigned reserved1 : 6;
  unsigned csd_ver : 2;
  // byte 1
  uint8_t taac;
  // byte 2
  uint8_t nsac;
  // byte 3
  uint8_t tran_speed;
  // byte 4
  uint8_t ccc_high;
  // byte 5
  unsigned read_bl_len : 4;
  unsigned ccc_low : 4;
  // byte 6
  unsigned c_size_high : 2;
  unsigned reserved2 : 2;
  unsigned dsr_imp : 1;
  unsigned read_blk_misalign :1;
  unsigned write_blk_misalign : 1;
  unsigned read_bl_partial : 1;
  // byte 7
  uint8_t c_size_mid;
  // byte 8
  unsigned vdd_r_curr_max : 3;
  unsigned vdd_r_curr_min : 3;
  unsigned c_size_low :2;
  // byte 9
  unsigned c_size_mult_high : 2;
  unsigned vdd_w_cur_max : 3;
  unsigned vdd_w_curr_min : 3;
  // byte 10
  unsigned sector_size_high : 6;
  unsigned erase_blk_en : 1;
  unsigned c_size_mult_low : 1;
  // byte 11
  unsigned wp_grp_size : 7;
  unsigned sector_size_low : 1;
  // byte 12
  unsigned write_bl_len_high : 2;
  unsigned r2w_factor : 3;
  unsigned reserved3 : 2;
  unsigned wp_grp_enable : 1;
  // byte 13
  unsigned reserved4 : 5;
  unsigned write_partial : 1;
  unsigned write_bl_len_low : 2;
  // byte 14
  unsigned reserved5: 2;
  unsigned file_format : 2;
  unsigned tmp_write_protect : 1;
  unsigned perm_write_protect : 1;
  unsigned copy : 1;
  unsigned file_format_grp : 1;
  // byte 15
  unsigned always1 : 1;
  unsigned crc : 7;
}csd1_t;
//------------------------------------------------------------------------------
// CSD for version 2.00 cards
typedef struct CSDV2 {
  // byte 0
  unsigned reserved1 : 6;
  unsigned csd_ver : 2;
  // byte 1
  uint8_t taac;
  // byte 2
  uint8_t nsac;
  // byte 3
  uint8_t tran_speed;
  // byte 4
  uint8_t ccc_high;
  // byte 5
  unsigned read_bl_len : 4;
  unsigned ccc_low : 4;
  // byte 6
  unsigned reserved2 : 4;
  unsigned dsr_imp : 1;
  unsigned read_blk_misalign :1;
  unsigned write_blk_misalign : 1;
  unsigned read_bl_partial : 1;
  // byte 7
  unsigned reserved3 : 2;
  unsigned c_size_high : 6;
  // byte 8
  uint8_t c_size_mid;
  // byte 9
  uint8_t c_size_low;
  // byte 10
  unsigned sector_size_high : 6;
  unsigned erase_blk_en : 1;
  unsigned reserved4 : 1;
  // byte 11
  unsigned wp_grp_size : 7;
  unsigned sector_size_low : 1;
  // byte 12
  unsigned write_bl_len_high : 2;
  unsigned r2w_factor : 3;
  unsigned reserved5 : 2;
  unsigned wp_grp_enable : 1;
  // byte 13
  unsigned reserved6 : 5;
  unsigned write_partial : 1;
  unsigned write_bl_len_low : 2;
  // byte 14
  unsigned reserved7: 2;
  unsigned file_format : 2;
  unsigned tmp_write_protect : 1;
  unsigned perm_write_protect : 1;
  unsigned copy : 1;
  unsigned file_format_grp : 1;
  // byte 15
  unsigned always1 : 1;
  unsigned crc : 7;
}csd2_t;
//------------------------------------------------------------------------------
// union of old and new style CSD register
typedef union{
  csd1_t v1;
  csd2_t v2;
}csd_t;


//card commands
#define CMD0    0   /* GO_IDLE_STATE */
#define CMD55   55  /* APP_CMD */
#define CMD58   58  /* OCR READ */
#define ACMD41  41  /* SEND_OP_COND (ACMD) */
#define CMD1    1   /* SEND_OP_COND */
#define CMD17   17  /* READ_SINGLE_BLOCK */
#define CMD8    8   /* SEND_IF_COND */
#define CMD18   18  /* READ_MULTIPLE_BLOCK */
#define CMD12   12  /* STOP_TRANSMISSION */
#define CMD24   24  /* WRITE_BLOCK */
#define CMD25   25  /* WRITE_MULTIPLE_BLOCK */
#define CMD13   13  /* SEND_STATUS */
#define CMD9    9   /* SEND_CSD */
#define CMD10   10  /* SEND_CID */

#define CSD     9
#define CID     10

#define SD_SECTOR_SIZE  512

// card types
/** Standard capacity V1 SD card */
#define SD_CARD_TYPE_SD1  1
/** Standard capacity V2 SD card */
#define SD_CARD_TYPE_SD2  2
/** High Capacity SD card */
#define SD_CARD_TYPE_SDHC 3


//set CS low
void cs_enable();

//set CS high and send 8 clocks
void cs_disable();

//write a byte
void sd_write_byte(uint8_t data);

//read a byte
uint8_t sd_read_byte();

//send a command and send back the response
uint8_t  sd_send_cmd(uint8_t cmd,uint32_t arg,uint8_t crc);

//reset SD card
uint8_t sd_reset();

//initial SD card
uint8_t sd_init();

//read a single sector
uint8_t sd_read_sector(uint32_t addr,uint8_t * buffer);

//read multiple sectors
uint8_t sd_read_multi_sector(uint32_t addr,uint8_t sector_num,uint8_t * buffer);


//write a single sector
uint8_t sd_write_sector(uint32_t addr,uint8_t * buffer);

//write multiple sectors
uint8_t sd_write_multi_sector(uint32_t addr,uint8_t sector_num,uint8_t * buffer);

//get CID or CSD
uint8_t sd_get_CSD(uint8_t * buffer);

#endif
/* SD_SPI_SOLUTION_H_ */
