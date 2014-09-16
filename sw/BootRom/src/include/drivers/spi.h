#ifndef _SPI_H_
#define _SPI_H_

#include "types.h"

#define SPI_BASEADDR   (0xB8000500)
#define SPI_SPCR_ADDR  (0xB8000500)
#define SPI_SPSR_ADDR  (0xB8000504)
#define SPI_SPDR_ADDR  (0xB8000508)
#define SPI_SPER_ADDR  (0xB800050C)
#define SPI_SPSSR_ADDR (0xB8000510)

void spi_init();
inline bool isTransOver();
uint8_t spi_transfer(uint8_t data);
void spi_enable(uint8_t num);
void spi_disable();

#endif
