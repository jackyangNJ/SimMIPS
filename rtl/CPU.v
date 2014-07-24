// Copyright (C) 1991-2012 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// PROGRAM		"Quartus II 32-bit"
// VERSION		"Version 12.0 Build 178 05/31/2012 SJ Web Edition"
// CREATED		"Fri Oct 12 09:17:44 2012"

module CPU(
	iCLK_28,
	iCLK_50,
	iKEY,
	oUART_TXD,
	oVGA_BLANK_N,
	oVGA_SYNC_N,
	oVGA_CLOCK,
	oVGA_HS,
	oVGA_VS,
	oLEDG,
	oVGA_B,
	oVGA_G,
	oVGA_R
);


input wire	iCLK_28;
input wire	iCLK_50;
input wire	[3:0] iKEY;
output wire	oUART_TXD;
output wire	oVGA_BLANK_N;
output wire	oVGA_SYNC_N;
output wire	oVGA_CLOCK;
output wire	oVGA_HS;
output wire	oVGA_VS;
output reg	[0:0] oLEDG;
output wire	[9:0] oVGA_B;
output wire	[9:0] oVGA_G;
output wire	[9:0] oVGA_R;

wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_11;
wire	[31:0] SYNTHESIZED_WIRE_3;
wire	[31:0] SYNTHESIZED_WIRE_4;
wire	[31:0] SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_7;
wire	[31:0] SYNTHESIZED_WIRE_9;
wire	[31:0] SYNTHESIZED_WIRE_10;

always@(posedge iCLK_50)
begin
if(iKEY[3]==0)
		oLEDG[0]<=0;
else
	if(SYNTHESIZED_WIRE_7==1)
		oLEDG[0] <= 1;
	
end		




MemorySys	b2v_inst(

	.dm_en_i(SYNTHESIZED_WIRE_0),
	.dm_wr_i(SYNTHESIZED_WIRE_1),
	.clk_i(iCLK_50),
	.rst_i(SYNTHESIZED_WIRE_11),
	.vga_clk_i(iCLK_28),
	
	
	
	.dm_adr_i(SYNTHESIZED_WIRE_3),
	.dm_dat_i(SYNTHESIZED_WIRE_4),
	.im_adr_i(SYNTHESIZED_WIRE_5),
	.cpu_pause_o(SYNTHESIZED_WIRE_6),
	.int_o(SYNTHESIZED_WIRE_7),
	.tx_o(oUART_TXD),
	.blank_N_o(oVGA_BLANK_N),
	.sync_N_o(oVGA_SYNC_N),
	.vga_clk_o(oVGA_CLOCK),
	.h_syn_o(oVGA_HS),
	.v_syn_o(oVGA_VS),
	.color_b_o(oVGA_B),
	.color_g_o(oVGA_G),
	.color_r_o(oVGA_R),
	.dm_dat_o(SYNTHESIZED_WIRE_9),
	.im_dat_o(SYNTHESIZED_WIRE_10));


pipeline_cpu	b2v_inst1(
	.pause(SYNTHESIZED_WIRE_6),
	.intr(SYNTHESIZED_WIRE_7),
	.clk(iCLK_50),
	.reset(SYNTHESIZED_WIRE_11),
	.dm_dat_o(SYNTHESIZED_WIRE_9),
	.im_dat_o(SYNTHESIZED_WIRE_10),
	.dm_en_i(SYNTHESIZED_WIRE_0),
	.dm_wr_i(SYNTHESIZED_WIRE_1),
	
	.dm_adr_i(SYNTHESIZED_WIRE_3),
	.dm_dat_i(SYNTHESIZED_WIRE_4),
	.im_adr_i(SYNTHESIZED_WIRE_5));

assign	SYNTHESIZED_WIRE_11 =  ~iKEY;


endmodule
