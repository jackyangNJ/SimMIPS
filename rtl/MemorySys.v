module MemorySys(
	dm_en_i,
	dm_wr_i,
	clk_i,
	rst_i,
	vga_clk_i,
	kb_clk_i,
	kb_dat_i,
	rx_i,
	dm_adr_i,
	dm_dat_i,
	im_adr_i,
	cpu_pause_o,
	int_o,
	tx_o,
	oVGA_BLANK_N,
	oVGA_SYNC_N,
	oVGA_CLOCK,
	oVGA_HS,
	oVGA_VS,
	oVGA_B,
	oVGA_G,
	oVGA_R,
	dm_dat_o,
	im_dat_o,
	/*SSRAM*/
	SRAM_DQ,
	SRAM_DPA,
	oSRAM_ADSP_N,
	oSRAM_ADV_N,
	oSRAM_CE2,
	oSRAM_CE3_N,
	oSRAM_CLK,
	oSRAM_GW_N,
	oSRAM_A,
	oSRAM_ADSC_N,
	oSRAM_BE_N,
	oSRAM_CE1_N,
	oSRAM_OE_N,
	oSRAM_WE_N,
	/*SDRAM*/
	clk_100,
	clk_sdram,
	DRAM_DQ,
	oDRAM0_A,oDRAM1_A,
	oDRAM0_LDQM0, oDRAM0_UDQM1,
	oDRAM1_LDQM0, oDRAM1_UDQM1,
	oDRAM0_WE_N,  oDRAM1_WE_N,
	oDRAM0_CAS_N, oDRAM1_CAS_N,
	oDRAM0_RAS_N, oDRAM1_RAS_N,
	oDRAM0_CS_N,  oDRAM1_CS_N,
	oDRAM0_BA, 	  oDRAM1_BA,
	oDRAM0_CLK,   oDRAM1_CLK,
	oDRAM0_CKE,   oDRAM1_CKE

);


input wire	dm_en_i;
input wire	dm_wr_i;
input wire	clk_i;
input wire	rst_i;
input wire	vga_clk_i;
input wire	kb_clk_i;
input wire	kb_dat_i;
input wire	rx_i;
input wire	[31:0] dm_adr_i;
input wire	[31:0] dm_dat_i;
input wire	[31:0] im_adr_i;
output wire	cpu_pause_o;
output wire	int_o;
output wire	tx_o;
output wire	oVGA_BLANK_N;
output wire	oVGA_SYNC_N;
output wire	oVGA_CLOCK;
output wire	oVGA_HS;
output wire	oVGA_VS;
output wire	[9:0] oVGA_B;
output wire	[9:0] oVGA_G;
output wire	[9:0] oVGA_R;
output wire	[31:0] dm_dat_o;
output wire	[31:0] im_dat_o;

wire	bus_cs;
wire	bus_we;
wire	timer_ack;
wire	uart_ack;
wire	vga_ack;
wire	kb_ack;
wire	ram_ack;
wire	[31:0] bus_adr;
wire	[31:0] bus_dat_i;
wire	[31:0] timer_dat_i;
wire	[31:0] uart_dat_i;
wire	[31:0] vga_dat_i;
wire	[31:0] kb_data;
wire	[31:0] ram_dat_i;
wire	clk_o;
wire	rst_o;
wire	bus_ack;
wire	[31:0] bus_dat_o;
wire	kb_cs;
wire	kb_we;
wire	[31:0] kb_adr;
wire	timer_cs;
wire	uart_int;
wire	kb_int;
wire	timer_int;
wire	ram_cs;
wire	ram_we;
wire	[31:0] ram_adr;
wire	[31:0] ram_dat_o;
wire	timer_we;
wire	[31:0] timer_adr;
wire	[31:0] timer_dat_o;
wire	uart_cs;
wire	uart_we;
wire	[31:0] uart_adr;
wire	[31:0] uart_dat_o;
wire	vga_cs;
wire	vga_we;
wire	[31:0] vga_adr;
wire	[31:0] vga_dat_o;


/* sram */
wire sram_cs,sram_we,sram_ack;
wire [31:0] sram_dat_i,sram_dat_o,sram_adr;
/* SSRAM signal */
inout [31:0]SRAM_DQ;
inout [3:0]SRAM_DPA;
output  oSRAM_ADSP_N;
output  oSRAM_ADV_N;
output  oSRAM_CE2;
output  oSRAM_CE3_N;
output  oSRAM_CLK;
output  oSRAM_GW_N;
output[18:0]oSRAM_A;
output  oSRAM_ADSC_N;
output[3:0]oSRAM_BE_N;
output  oSRAM_CE1_N;
output  oSRAM_OE_N;
output  oSRAM_WE_N;
/* sdram*/
wire sdram_cs,sdram_we,sdram_ack;
wire [31:0] sdram_dat_i,sdram_dat_o,sdram_adr;
/* SDRAM signal*/
input clk_100;
input	clk_sdram;
inout  [31:0] DRAM_DQ;
output [12:0]oDRAM0_A, oDRAM1_A;
output [1:0]oDRAM0_BA,oDRAM1_BA;
output oDRAM0_LDQM0,oDRAM1_LDQM0;
output oDRAM0_UDQM1,oDRAM1_UDQM1;
output oDRAM0_WE_N, oDRAM1_WE_N;
output oDRAM0_CAS_N,oDRAM1_CAS_N;
output oDRAM0_RAS_N,oDRAM1_RAS_N;
output oDRAM0_CS_N, oDRAM1_CS_N;
output oDRAM0_CLK, oDRAM1_CLK;
output oDRAM0_CKE, oDRAM1_CKE;


Bus	b2v_BUS(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.master_stb_i(bus_cs),
	.master_we_i(bus_we),
	.slave_0_ack_i(timer_ack),
	.slave_1_ack_i(uart_ack),
	.slave_2_ack_i(vga_ack),
	.slave_3_ack_i(kb_ack),
	.slave_4_ack_i(ram_ack),
	
	
	
	.master_adr_i(bus_adr),
	.master_dat_i(bus_dat_i),
	.slave_0_dat_i(timer_dat_i),
	.slave_1_dat_i(uart_dat_i),
	.slave_2_dat_i(vga_dat_i),
	.slave_3_dat_i(kb_data),
	.slave_4_dat_i(ram_dat_i),
	
	
	
	.clk_o(clk_o),
	.rst_o(rst_o),
	
	.master_ack_o(bus_ack),
	.slave_0_cs_o(timer_cs),
	.slave_0_we_o(timer_we),
	.slave_1_cs_o(uart_cs),
	.slave_1_we_o(uart_we),
	.slave_2_cs_o(vga_cs),
	.slave_2_we_o(vga_we),
	.slave_3_cs_o(kb_cs),
	.slave_3_we_o(kb_we),
	.slave_4_cs_o(ram_cs),
	.slave_4_we_o(ram_we),
	
	.master_dat_o(bus_dat_o),
	.slave_0_adr_o(timer_adr),
	.slave_0_dat_o(timer_dat_o),
	.slave_1_adr_o(uart_adr),
	.slave_1_dat_o(uart_dat_o),
	.slave_2_adr_o(vga_adr),
	.slave_2_dat_o(vga_dat_o),
	.slave_3_adr_o(kb_adr),
	
	.slave_4_adr_o(ram_adr),
	.slave_4_dat_o(ram_dat_o),
	
	.slave_5_cs_o(sram_cs),
	.slave_5_we_o(sram_we),
	.slave_5_adr_o(sram_adr),
	.slave_5_dat_i(sram_dat_i),
	.slave_5_dat_o(sram_dat_o),
	.slave_5_ack_i(sram_ack),
	
	.slave_6_cs_o(sdram_cs),
	.slave_6_we_o(sdram_we),
	.slave_6_adr_o(sdram_adr),
	.slave_6_dat_i(sdram_dat_i),
	.slave_6_dat_o(sdram_dat_o),
	.slave_6_ack_i(sdram_ack)
	);


CpuBusInterface	b2v_CPUBusInterface(
	.dm_en_i(dm_en_i),
	.dm_wr_i(dm_wr_i),
	.bus_clk_i(clk_o),
	.bus_rst_i(rst_o),
	.bus_ack_i(bus_ack),
	.bus_dat_i(bus_dat_o),
	.dm_adr_i(dm_adr_i),
	.dm_dat_i(dm_dat_i),
	.im_adr_i(im_adr_i),
	.bus_stb_o(bus_cs),
	.bus_we_o(bus_we),
	
	
	.cpu_pause_o(cpu_pause_o),
	.bus_adr_o(bus_adr),
	.bus_dat_o(bus_dat_i),
	.dm_dat_o(dm_dat_o),
	.im_dat_o(im_dat_o));


KBController	b2v_inst(
	.clk_i(clk_o),
	.rst_i(rst_o),
	.kb_clk_i(kb_clk_i),
	.kb_dat_i(kb_dat_i),
	.cs_i(kb_cs),
	.we_i(kb_we),
	.adr_i(kb_adr),
	.int_o(kb_int),
	.ack_o(kb_ack),
	.dat_o(kb_data));




assign	int_o = uart_int | kb_int | timer_int;


InterRAM	b2v_interram(
	.clk_i(clk_o),
	.rst_i(rst_o),
	.cs_i(ram_cs),
	.we_i(ram_we),
	.adr_i(ram_adr),
	.dat_i(ram_dat_o),
	.ack_o(ram_ack),
	.dat_o(ram_dat_i));


Timer	b2v_timer(
	.clk_i(clk_o),
	.rst_i(rst_o),
	.cs_i(~timer_cs),
	.we_i(timer_we),
	.adr_i(timer_adr),
	.dat_i(timer_dat_o),
	.ack_o(timer_ack),
	.int_o(timer_int),
	.dat_o(timer_dat_i));


UARTController	b2v_uart(
	.cs_i(~uart_cs),
	.we_i(uart_we),
	.rx_i(rx_i),
	.clk_i(clk_o),
	.rst_i(rst_o),
	.adr_i(uart_adr),
	.dat_i(uart_dat_o),
	.int_o(uart_int),
	.ack_o(uart_ack),
	.tx_o(tx_o),
	.dat_o(uart_dat_i));


VgaDeviceCtrl	b2v_vgadevice(
	.bus_clk_i(clk_o),
	.reset_i(rst_o),
	.cs_i(vga_cs),
	.we_i(vga_we),
	.vga_clk_i(vga_clk_i),
	.addr_i(vga_adr),
	.data_i(vga_dat_o),
	.ack_o(vga_ack),
	.blank_N_o(oVGA_BLANK_N),
	.sync_N_o(oVGA_SYNC_N),
	.vga_clk_o(oVGA_CLOCK),
	.h_syn_o(oVGA_HS),
	.v_syn_o(oVGA_VS),
	.color_b_o(oVGA_B),
	.color_g_o(oVGA_G),
	.color_r_o(oVGA_R),
	.data_o(vga_dat_i));

SSRAM ssram
(
	.clk_i(clk_o),
	.rst_i(rst_o),
	.cs_i(sram_cs),
	.we_i(sram_we),
	.dat_i(sram_dat_o),
	.adr_i(sram_adr),
	.dat_o(sram_dat_i),
	.ack_o(sram_ack),
	/* SRAM signal */
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
	.oSRAM_WE_N(oSRAM_WE_N)
);
 SDRAM sdram(
	.clk_sys(clk_100),
	.clk_ram(clk_sdram),
	.rst_i(rst_o),
	.cs_i(sdram_cs),
	.we_i(sdram_we),
	.dat_i(sdram_dat_o),
	.dat_o(sdram_dat_i),
	.adr_i(sdram_adr),
	.ack_o(sdram_ack),
	
	.DRAM_DQ(DRAM_DQ),
	.oDRAM0_A(oDRAM0_A),
	.oDRAM1_A(oDRAM1_A),
	.oDRAM0_LDQM0(oDRAM0_LDQM0), 
	.oDRAM0_UDQM1(oDRAM0_UDQM1),
	.oDRAM1_LDQM0(oDRAM1_LDQM0),
	.oDRAM1_UDQM1(oDRAM1_UDQM1),
	.oDRAM0_WE_N(oDRAM0_WE_N),
	.oDRAM1_WE_N(oDRAM1_WE_N),
	.oDRAM0_CAS_N(oDRAM0_CAS_N),
	.oDRAM1_CAS_N(oDRAM1_CAS_N),
	.oDRAM0_RAS_N(oDRAM0_RAS_N),
	.oDRAM1_RAS_N(oDRAM1_RAS_N),
	.oDRAM0_CS_N(oDRAM0_CS_N),
	.oDRAM1_CS_N(oDRAM1_CS_N),
	.oDRAM0_BA(oDRAM0_BA),
	.oDRAM1_BA(oDRAM1_BA),
	.oDRAM0_CLK(oDRAM0_CLK),
	.oDRAM1_CLK(oDRAM1_CLK),
	.oDRAM0_CKE(oDRAM0_CKE),
	.oDRAM1_CKE(oDRAM1_CKE)
);
endmodule
