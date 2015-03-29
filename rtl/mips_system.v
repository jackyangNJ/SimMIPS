`include "Defines.v"
module mips_system(
    input  iCLK_100,
    input  RESET_BTN,
    input  PS2_KBCLK,
    input  PS2_KBDAT,
    input  iUART_RXD,
    output oUART_TXD,
    inout [31:0] GPIO,
    /* SDRAM */
`ifdef MIPS_SDRAM
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
`endif

    /* SSRAM */
`ifdef MIPS_SRAM
    output[22:0] Mem_A,
    inout [15:0] Mem_DQ,
    output       Mem_CEN,
    output       Mem_OEN,
    output       Mem_WEN,
    output       Mem_UB,
    output       Mem_LB,
    output       Mem_ADV,
    output       Mem_CLK,
    output       Mem_CRE,
    input        Mem_Wait,
`endif
    /* SD */
    output  SD_CLK,
    output  SD_CMD,
    input   SD_DAT,
    output  SD_DAT3,
    /* VGA */
    output  oVGA_HS,
    output  oVGA_VS,
    output  [3:0] oVGA_B,
    output  [3:0] oVGA_G,
    output  [3:0] oVGA_R
);



`ifdef MIPS_SDRAM
    wire clk_100_sdram;
`endif
wire clk_50;
wire clk_cpu = iCLK_100;
wire clk_100 = iCLK_100;

// clk_wiz_0 pll_entity(
    // .clk_in1(clk_100),
    // .clk_out1(clk_50),
    // .reset(RESET_BTN)
// );

wire [3:0] spi_ss_o;
cpu_top#(
    .EXT_CLOCK_FREQ(100000000)
) cpu_inst(
    .clk_i(clk_cpu),
    .rst_i(~RESET_BTN),
    .uart_rx_i(iUART_RXD),
    .uart_tx_o(oUART_TXD),
    .gpio_pin(GPIO),
    .kb_clk_i(PS2_KBCLK),
    .kb_dat_i(PS2_KBDAT)
`ifdef MIPS_SDRAM
    ,
    .clk_sdram_i(clk_100_sdram),
    .clk_sdram_controller_i(clk_100),
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
    .oDRAM1_CKE  (oDRAM1_CKE)
`endif

`ifdef MIPS_SRAM
    ,
    .Mem_A      (Mem_A),
    .Mem_DQ     (Mem_DQ),
    .Mem_CEN    (Mem_CEN),
    .Mem_OEN    (Mem_OEN),
    .Mem_WEN    (Mem_WEN),
    .Mem_UB     (Mem_UB),
    .Mem_LB     (Mem_LB),
    .Mem_ADV    (Mem_ADV),
    .Mem_CLK    (Mem_CLK),
    .Mem_CRE    (Mem_CRE),
    .Mem_Wait   (Mem_Wait)
`endif
    /* SPI SD */
    ,
    .spi_ss_o(spi_ss_o),
    .spi_sck_o(SD_CLK),
    .spi_mosi_o(SD_CMD),
    .spi_miso_i(SD_DAT),
    /* VGA */
    .color_r_o(oVGA_R),
    .color_g_o(oVGA_G),
    .color_b_o(oVGA_B),
    .h_syn_o(oVGA_HS),
    .v_syn_o(oVGA_VS)
);


    //SPI
    assign SD_DAT3 = spi_ss_o[0];
endmodule
