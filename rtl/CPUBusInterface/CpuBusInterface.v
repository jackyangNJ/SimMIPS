module CpuBusInterface(
//与IM相连的输入输出
	input[31:0] im_adr_i,
	output[31:0] im_dat_o,
//与DM相连的输入输出
	input dm_en_i,
	input dm_wr_i,
	input[31:0] dm_adr_i,
	input[31:0] dm_dat_i,
	output[31:0] dm_dat_o,
//与总线相连的输入输出
	input bus_clk_i,
	input bus_rst_i,
	input[31:0] bus_dat_i,
	input bus_ack_i,
	output bus_stb_o,
	output bus_we_o,
	output[31:0] bus_adr_o,
	output[31:0] bus_dat_o,
//与CPU相连的输入输出
	output cpu_clk_o,
	output cpu_rst_o,
	output cpu_pause_o
);
	wire im_cs,im_pause,im_stb;
	wire dm_cs,dm_pause,dm_stb;
	wire[31:0] im_dat;
	wire[31:0] dm_dat;
	
	//IM-总线子接口，是CPU-总线子接口的一个实例
	CpuBusSubInterface IM_Interface(
		.clk_i(bus_clk_i),
		.rst_i(bus_rst_i),
		.cs_i(im_cs),
		.cpu_pause_i(cpu_pause_o),
		.mem_en_i(1'b1),
		.bus_ack_i(bus_ack_i),
		.bus_dat_i(bus_dat_i),
		.sub_pause_o(im_pause),
		.sub_stb_o(im_stb),
		.sub_dat_o(im_dat)
	);
	
	//DM-总线子接口，是CPU-总线子接口的一个实例
	CpuBusSubInterface DM_Interface(
		.clk_i(bus_clk_i),
		.rst_i(bus_rst_i),
		.cs_i(dm_cs),
		.cpu_pause_i(cpu_pause_o),
		.mem_en_i(dm_en_i),
		.bus_ack_i(bus_ack_i),
		.bus_dat_i(bus_dat_i),
		.sub_pause_o(dm_pause),
		.sub_stb_o(dm_stb),
		.sub_dat_o(dm_dat)
	);
	//子接口裁决器
	SubInterfaceJudger subInterfaceJudger(
		.im_req_i(im_pause),
		.dm_req_i(dm_pause),
		.im_cs_o(im_cs),
		.dm_cs_o(dm_cs)
	);
	
	assign im_dat_o = im_dat;
	assign dm_dat_o = dm_dat;
	assign cpu_clk_o = bus_clk_i;
	assign cpu_pause_o = im_pause|dm_pause;
	assign cpu_rst_o = bus_rst_i;
	assign bus_stb_o = im_stb|dm_stb;
	assign bus_we_o = dm_wr_i&dm_cs;
	assign bus_adr_o = (im_adr_i&{32{im_cs}})|(dm_adr_i&{32{dm_cs}});
	assign bus_dat_o = dm_dat_i;
	
endmodule
