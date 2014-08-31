module mips_system(
	input  iCLK_50,
	input  PS2_KBCLK,
	input  PS2_KBDAT,
	input  iUART_RXD,
	output oUART_TXD,
	inout [17:0] oLEDR,
	inout [8:0] oLEDG,
	inout  [17:0] iSW,
	input  [3:0] iKEY,
	inout  [31:0]DRAM_DQ,
	output [12:0]oDRAM0_A,
	output [12:0]oDRAM1_A,
	output oDRAM0_LDQM0, 
	output oDRAM0_UDQM1,
	output oDRAM1_LDQM0,
	output oDRAM1_UDQM1,
	output oDRAM0_WE_N,
	output oDRAM1_WE_N,
	output oDRAM0_CAS_N,
	output oDRAM1_CAS_N,
	output oDRAM0_RAS_N,
	output oDRAM1_RAS_N,
	output oDRAM0_CS_N,
	output oDRAM1_CS_N,
	output [1:0]oDRAM0_BA,
	output [1:0]oDRAM1_BA,
	output oDRAM0_CLK,
	output oDRAM1_CLK,
	output oDRAM0_CKE,
	output oDRAM1_CKE,
	inout [31:0]SRAM_DQ,
	inout [3:0]SRAM_DPA,
	output  oSRAM_ADSP_N,
	output  oSRAM_ADV_N,
	output  oSRAM_CE2,
	output  oSRAM_CE3_N,
	output  oSRAM_CLK,
	output  oSRAM_GW_N,
	output  [18:0]oSRAM_A,
	output  oSRAM_ADSC_N,
	output [3:0]oSRAM_BE_N,
	output  oSRAM_CE1_N,
	output  oSRAM_OE_N,
	output  oSRAM_WE_N,
	output  oSD_CLK,
	output  SD_CMD,
	input   SD_DAT,
	output  SD_DAT3
);

wire clk_100;
wire clk_100_sdram;
wire clk_50;

pll pll_entity(
	.inclk0(iCLK_50),
	.c0(clk_100_sdram),
	.c1(clk_100),
	.c2(clk_50)
);

wire [3:0] spi_ss_o;

cpu_top#(
	.EXT_CLOCK_FREQ(50000000)
) cpu(
	.external_clk_i(clk_50),
	.clk_sdram_i(clk_100_sdram),
	.clk_sdram_controller_i(clk_100),
	.external_rst_i(~iKEY[0]),
	.uart_rx_i(iUART_RXD),
	.uart_tx_o(oUART_TXD),
	.gpio_pin({oLEDR[15:0],iSW[15:0]}),
	.kb_clk_i(PS2_KBCLK),
	.kb_dat_i(PS2_KBDAT),
	.DRAM_DQ     (DRAM_DQ),
	.oDRAM0_A    (oDRAM0_A),
	.oDRAM1_A    (oDRAM1_A),
	.oDRAM0_LDQM0(oDRAM0_LDQM0), 
	.oDRAM0_UDQM1(oDRAM0_UDQM1),
	.oDRAM1_LDQM0(oDRAM1_LDQM0),
	.oDRAM1_UDQM1(oDRAM1_UDQM1),
	.oDRAM0_WE_N (oDRAM0_WE_N),
	.oDRAM1_WE_N (oDRAM1_WE_N),
	.oDRAM0_CAS_N(oDRAM0_CAS_N),
	.oDRAM1_CAS_N(oDRAM1_CAS_N),
	.oDRAM0_RAS_N(oDRAM0_RAS_N),
	.oDRAM1_RAS_N(oDRAM1_RAS_N),
	.oDRAM0_CS_N (oDRAM0_CS_N),
	.oDRAM1_CS_N (oDRAM1_CS_N),
	.oDRAM0_BA   (oDRAM0_BA),
	.oDRAM1_BA   (oDRAM1_BA),
	.oDRAM0_CLK  (oDRAM0_CLK),
	.oDRAM1_CLK  (oDRAM1_CLK),
	.oDRAM0_CKE  (oDRAM0_CKE),
	.oDRAM1_CKE  (oDRAM1_CKE),
	.SRAM_DQ(SRAM_DQ),
	.SRAM_DPA(SRAM_DPA),
	.oSRAM_ADSP_N(oSRAM_ADSP_N),
	.oSRAM_ADV_N(oSRAM_ADV_N),
	.oSRAM_CE2(oSRAM_CE2),
	.oSRAM_CE3_N(oSRAM_CE3_N),
	.oSRAM_CLK(oSRAM_CLK),
	.oSRAM_GW_N(oSRAM_GW_N),
	.oSRAM_A(oSRAM_A),
	.oSRAM_ADSC_N(oSRAM_ADSC_N),
	.oSRAM_BE_N(oSRAM_BE_N),
	.oSRAM_CE1_N(oSRAM_CE1_N),
	.oSRAM_OE_N(oSRAM_OE_N),
	.oSRAM_WE_N(oSRAM_WE_N),
	/* SPI */
	.spi_ss_o(spi_ss_o),
	.spi_sck_o(oSD_CLK),
	.spi_mosi_o(SD_CMD),
	.spi_miso_i(SD_DAT)
);


    //SPI
	assign SD_DAT3 = spi_ss_o[0];
	
endmodule
