`include "BusConfig.v"
module BusSwitchMem(
//其他的输入输出
	output adr_err_o,
//仅与主设备相连的输入输出
	input master_stb_i,
	input master_we_i,
	input[31:0]  master_adr_i,
	input[31:0]  master_dat_i,
	input[3:0]   master_sel_i,
	output[31:0] master_dat_o,
	output master_ack_o,
//与0号从设备相连的输入输出
	input[31:0] slave_0_dat_i,
	input slave_0_ack_i,
	output slave_0_stb_o,
	output slave_0_cyc_o,
	output slave_0_we_o,
	output[31:0] slave_0_adr_o,
	output[31:0] slave_0_dat_o,
	output[3:0]  slave_0_sel_o,
//与1号从设备相连的输入输出
	input[31:0] slave_1_dat_i,
	input slave_1_ack_i,
	output slave_1_stb_o,
	output slave_1_cyc_o,
	output slave_1_we_o,
	output[31:0] slave_1_adr_o,
	output[31:0] slave_1_dat_o,
	output[3:0]  slave_1_sel_o,
//与2号从设备相连的输入输出
	input[31:0] slave_2_dat_i,
	input slave_2_ack_i,
	output slave_2_stb_o,
	output slave_2_cyc_o,
	output slave_2_we_o,
	output[31:0] slave_2_adr_o,
	output[31:0] slave_2_dat_o,
	output[3:0]  slave_2_sel_o,
//与3号从设备相连的输入输出
	input[31:0] slave_3_dat_i,
	input slave_3_ack_i,
	output slave_3_stb_o,
	output slave_3_cyc_o,
	output slave_3_we_o,
	output[31:0] slave_3_adr_o,
	output[31:0] slave_3_dat_o,
	output[3:0]  slave_3_sel_o,
//与4号从设备相连的输入输出
	input[31:0] slave_4_dat_i,
	input slave_4_ack_i,
	output slave_4_stb_o,
	output slave_4_cyc_o,
	output slave_4_we_o,
	output[31:0] slave_4_adr_o,
	output[31:0] slave_4_dat_o,
	output[3:0]  slave_4_sel_o,
//与5号从设备相连的输入输出
	input[31:0] slave_5_dat_i,
	input slave_5_ack_i,
	output slave_5_stb_o,
	output slave_5_cyc_o,
	output slave_5_we_o,
	output[31:0] slave_5_adr_o,
	output[31:0] slave_5_dat_o,
	output[3:0]  slave_5_sel_o,
//与6号从设备相连的输入输出
	input[31:0] slave_6_dat_i,
	input slave_6_ack_i,
	output slave_6_stb_o,
	output slave_6_cyc_o,
	output slave_6_we_o,
	output[31:0] slave_6_adr_o,
	output[31:0] slave_6_dat_o,
	output[3:0]  slave_6_sel_o,
//与7号从设备相连的输入输出
	input[31:0] slave_7_dat_i,
	input slave_7_ack_i,
	output slave_7_stb_o,
	output slave_7_cyc_o,
	output slave_7_we_o,
	output[31:0] slave_7_adr_o,
	output[31:0] slave_7_dat_o,
	output[3:0]  slave_7_sel_o
);
	
	wire [`MBUS_SLAVE_NUMBER-1:0]cs;

	
	BusSlaveSelectorMem busSlaveSelector(
		.adr_i(master_adr_i),
		.stb_i(master_stb_i),
		.cs_o(cs),
		.adr_err_o(adr_err_o)
	);
	
	//连接到主设备的输出的驱动
	assign master_dat_o = ({32{cs[0]}}&slave_0_dat_i)
						| ({32{cs[1]}}&slave_1_dat_i)
						| ({32{cs[2]}}&slave_2_dat_i)
						| ({32{cs[3]}}&slave_3_dat_i)
						| ({32{cs[4]}}&slave_4_dat_i)
						| ({32{cs[5]}}&slave_5_dat_i)
						| ({32{cs[6]}}&slave_6_dat_i)
						| ({32{cs[7]}}&slave_7_dat_i)
						;
	
	assign master_ack_o = (cs[0]&slave_0_ack_i)
						| (cs[1]&slave_1_ack_i)
						| (cs[2]&slave_2_ack_i)
						| (cs[3]&slave_3_ack_i)
						| (cs[4]&slave_4_ack_i)
						| (cs[5]&slave_5_ack_i)
						| (cs[6]&slave_6_ack_i)
						| (cs[7]&slave_7_ack_i)
						;
						
	//连接到从设备的输出的驱动
	assign slave_0_we_o = master_we_i;
	assign slave_0_adr_o = master_adr_i;
	assign slave_0_dat_o = master_dat_i;
	assign slave_0_stb_o = cs[0];
	assign slave_0_cyc_o = slave_0_stb_o;
	assign slave_0_sel_o = master_sel_i;
	
	assign slave_1_we_o = master_we_i;
	assign slave_1_adr_o = master_adr_i;
	assign slave_1_dat_o = master_dat_i;
	assign slave_1_stb_o = cs[1];
	assign slave_1_cyc_o = slave_1_stb_o;
	assign slave_1_sel_o = master_sel_i;
	
	assign slave_2_we_o = master_we_i;
	assign slave_2_adr_o = master_adr_i;
	assign slave_2_dat_o = master_dat_i;
	assign slave_2_stb_o = cs[2];
	assign slave_2_cyc_o = slave_2_stb_o;
	assign slave_2_sel_o = master_sel_i;
	
	assign slave_3_we_o = master_we_i;
	assign slave_3_adr_o = master_adr_i;
	assign slave_3_dat_o = master_dat_i;
	assign slave_3_stb_o = cs[3];
	assign slave_3_cyc_o = slave_3_stb_o;
	assign slave_3_sel_o = master_sel_i;
	

	assign slave_4_we_o = master_we_i;
	assign slave_4_adr_o = master_adr_i;
	assign slave_4_dat_o = master_dat_i;
	assign slave_4_stb_o = cs[4];
	assign slave_4_cyc_o = slave_4_stb_o;
	assign slave_4_sel_o = master_sel_i;

	assign slave_5_we_o = master_we_i;
	assign slave_5_adr_o = master_adr_i;
	assign slave_5_dat_o = master_dat_i;
	assign slave_5_stb_o = cs[5];
	assign slave_5_cyc_o = slave_5_stb_o;
	assign slave_5_sel_o = master_sel_i;
	
	assign slave_6_we_o = master_we_i;
	assign slave_6_adr_o = master_adr_i;
	assign slave_6_dat_o = master_dat_i;
	assign slave_6_stb_o = cs[6];
	assign slave_6_cyc_o = slave_6_stb_o;
	assign slave_6_sel_o = master_sel_i;
	
	assign slave_7_we_o = master_we_i;
	assign slave_7_adr_o = master_adr_i;
	assign slave_7_dat_o = master_dat_i;
	assign slave_7_stb_o = cs[7];
	assign slave_7_cyc_o = slave_7_stb_o;
	assign slave_7_sel_o = master_sel_i;
	
endmodule
