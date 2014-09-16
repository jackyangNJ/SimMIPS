#include "drivers/spi.h"
#include "drivers/serial.h"
#include "mips/io.h"

void spi_init() {
    //diide wishbone clock by 512
    out_byte(SPI_SPCR_ADDR, 0x50);
    out_byte(SPI_SPER_ADDR, 0x02);
}

inline bool isTransOver() {
    return (in_byte(SPI_SPSR_ADDR) & 0x01) == 0;
}

uint8_t spi_transfer(uint8_t data) {
    out_byte(SPI_SPDR_ADDR, data);
    while (isTransOver() == 0);
    return in_byte(SPI_SPDR_ADDR);
}

void spi_enable(uint8_t num) {
    out_byte(SPI_SPSSR_ADDR, ~(1 << num));
}

void spi_disable() {
    out_byte(SPI_SPSSR_ADDR, 0x0F);
}