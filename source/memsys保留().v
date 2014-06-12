module MemorySys(
	clk_i,
	rst_i,
	vga_clk_i,
	
	kb_clk,
	kb_dat,
	
	rx_i,
	tx_o,
	
	dm_en_i,
	dm_wr_i,
	dm_adr_i,
	dm_dat_i,
	im_adr_i,
	dm_dat_o,
	im_dat_o,
	
	cpu_pause_o,
	int_o,
	
	blank_N_o,
	sync_N_o,
	vga_clk_o,
	h_syn_o,
	v_syn_o,
	color_b_o,
	color_g_o,
	color_r_o,
	
	/*SDRAM*/
	sdram_clk_i,
	sdram_sys_clk_i,
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
	oDRAM0_CKE,   oDRAM1_CKE,
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
	oSRAM_WE_N
);



input wire	clk_i;
input wire	rst_i;
input wire	vga_clk_i;

input wire	kb_clk;
input wire	kb_dat;

input wire	rx_i;
output wire	tx_o;

input wire	dm_en_i;
input wire	dm_wr_i;
input wire	[31:0] dm_adr_i;
input wire	[31:0] dm_dat_i;
input wire	[31:0] im_adr_i;
output wire	[31:0] dm_dat_o;
output wire	[31:0] im_dat_o;

output wire	cpu_pause_o;
output wire	int_o;

output wire	blank_N_o;
output wire	sync_N_o;
output wire	vga_clk_o;
output wire	h_syn_o;
output wire	v_syn_o;
output wire	[9:0] color_b_o;
output wire	[9:0] color_g_o;
output wire	[9:0] color_r_o;

/* SDRAM */
input sdram_clk_i;
input	sdram_sys_clk_i;
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

/* timer */
wire timer_cs,timer_ack,timer_int,timer_we;
wire [31:0] timer_adr,timer_dat_i,timer_dat_o;
/* kb */
wire kb_cs,kb_ack,kb_int,kb_we;
wire [31:0] kb_adr,kb_dat_i;
/* uart */
wire uart_cs,uart_ack,uart_int,uart_we;
wire [31:0] uart_adr,uart_dat_i,uart_dat_o;
/* ram */
wire ram_cs,ram_ack,ram_we;
wire [31:0] ram_adr,ram_dat_i,ram_dat_o;
/* vga */
wire vga_cs,vga_ack,vga_we;
wire [31:0] vga_adr,vga_dat_i,vga_dat_o;
/* bus */
wire bus_cs,bus_ack,bus_we;
wire [31:0] bus_adr,bus_dat_i,bus_dat_o;
/* sdram */
wire sdram_cs,sdram_ack,sdram_we;
wire [31:0] sdram_adr,sdram_dat_i,sdram_dat_o;
/* ssram */
wire ssram_cs,ssram_ack,ssram_we;
wire [31:0] ssram_adr,ssram_dat_i,ssram_dat_o;

wire clk_o;
wire rst_o;



CpuBusInterface	b2v_CPUBusInterface(
	.dm_en_i(dm_en_i),
	.dm_wr_i(dm_wr_i),
	.dm_adr_i(dm_adr_i),
	.dm_dat_i(dm_dat_i),
	.dm_dat_o(dm_dat_o),
	
	.im_adr_i(im_adr_i),
	.im_dat_o(im_dat_o),
	
	.bus_clk_i(clk_i),
	.bus_rst_i(rst_i),
	.bus_stb_o(bus_cs),
	.bus_we_o(bus_we),
	.bus_ack_i(bus_ack),
	.bus_adr_o(bus_adr),
	.bus_dat_i(bus_dat_i),
	.bus_dat_o(bus_dat_o),
	
	.cpu_pause_o(cpu_pause_o)
);

Bus	b2v_BUS(
	.clk_i(clk_i),
	.rst_i(rst_i),
	
	.master_stb_i(bus_cs),
	.master_we_i(bus_we),
	.master_adr_i(bus_adr),
	.master_dat_i(bus_dat_o),
	.master_dat_o(bus_dat_i),
	.master_ack_o(bus_ack),
	
	.slave_0_cs_o(timer_cs),
	.slave_0_we_o(timer_we),
	.slave_0_dat_i(timer_dat_i),
	.slave_0_adr_o(timer_adr),
	.slave_0_dat_o(timer_dat_o),
	.slave_0_ack_i(timer_ack),
	
	.slave_1_cs_o(uart_cs),
	.slave_1_we_o(uart_we),
	.slave_1_dat_i(uart_dat_i),
	.slave_1_adr_o(uart_adr),
	.slave_1_ack_i(uart_ack),
	.slave_1_dat_o(uart_dat_o),
	
	.slave_2_cs_o(vga_cs),
	.slave_2_we_o(vga_we),
	.slave_2_adr_o(vga_adr),
	.slave_2_dat_i(vga_dat_i),
	.slave_2_dat_o(vga_dat_o),
	.slave_2_ack_i(vga_ack),
	
	.slave_3_cs_o(kb_cs),
	.slave_3_we_o(kb_we),
	.slave_3_dat_i(kb_dat_i),
	.slave_3_adr_o(kb_adr),
	.slave_3_ack_i(kb_ack),
	
	
	.slave_4_cs_o(ram_cs),
	.slave_4_we_o(ram_we),
	.slave_4_ack_i(ram_ack),
	.slave_4_adr_o(ram_adr),
	.slave_4_dat_i(ram_dat_i),
	.slave_4_dat_o(ram_dat_o),
	
	.slave_5_cs_o(ssram_cs),
	.slave_5_we_o(ssram_we),
	.slave_5_ack_i(ssram_ack),
	.slave_5_adr_o(ssram_adr),
	.slave_5_dat_i(ssram_dat_i),
	.slave_5_dat_o(ssram_dat_o),
	
	.slave_6_cs_o(sdram_cs),
	.slave_6_we_o(sdram_we),
	.slave_6_ack_i(sdram_ack),
	.slave_6_adr_o(sdram_adr),
	.slave_6_dat_i(sdram_dat_i),
	.slave_6_dat_o(sdram_dat_o),
	
	.clk_o(clk_o),
	.rst_o(rst_o)
);

KBController	b2v_inst(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.cs_i(kb_cs),
	.we_i(kb_we),
	.adr_i(kb_adr),
	.dat_o(kb_dat_i),
	.int_o(kb_int),
	.ack_o(kb_ack),
	.kb_clk_i(kb_clk),
	.kb_dat_i(kb_dat)
);

InterRAM	b2v_interram(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.cs_i(ram_cs),
	.we_i(ram_we),
	.adr_i(ram_adr),
	.dat_i(ram_dat_o),
	.dat_o(ram_dat_i),
	.ack_o(ram_ack)
);


Timer	b2v_timer(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.cs_i(!timer_cs),
	.we_i(timer_we),
	.adr_i(timer_adr),
	.dat_i(timer_dat_o),
	.dat_o(timer_dat_i),
	.ack_o(timer_ack),
	.int_o(timer_int)
);

UARTController	b2v_uart(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.cs_i(!uart_cs),
	.we_i(uart_we),
	.adr_i(uart_adr),
	.dat_i(uart_dat_o),
	.dat_o(uart_dat_i),
	.int_o(uart_int),
	.ack_o(uart_ack),
	.rx_i(rx_i),
	.tx_o(tx_o)
);


VgaDeviceCtrl	b2v_vgadevice(
	.bus_clk_i(clk_i),
	.vga_clk_i(vga_clk_i),
	.reset_i(rst_i),
	
	.cs_i(vga_cs),
	.we_i(vga_we),
	.addr_i(vga_adr),
	.data_i(vga_dat_o),
	.data_o(vga_dat_i),
	.ack_o(vga_ack),
	
	.blank_N_o(blank_N_o),
	.sync_N_o(sync_N_o),
	.vga_clk_o(vga_clk_o),
	.h_syn_o(h_syn_o),
	.v_syn_o(v_syn_o),
	.color_b_o(color_b_o),
	.color_g_o(color_g_o),
	.color_r_o(color_r_o)
);

 SDRAM sdram(
	.clk_sys(sdram_sys_clk_i),
	.clk_ram(sdram_clk_i),
	.rst_i(rst_i),
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

SSRAM ssram
(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.cs_i(ssram_cs),
	.we_i(ssram_we),
	.adr_i(ssram_adr),
	.dat_i(ssram_dat_o),
	.dat_o(ssram_dat_i),
	.ack_o(ssram_ack),
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
assign	int_o = timer_int | uart_int | kb_int;
assign 	vga_clk_o = vga_clk_i;
endmodule