module BIU(
	input        clk_i,
	input        rst_i,
	
	/* connected with CPU core */
	input [31:0] dphy_addr_i,
	input [31:0] iphy_addr_i,
	input [31:0] data_i,
	input        data_wr_i,
	input [3:0]  data_bytesel_i,
	
	input        ibus_memory_en_i,
	output       ibus_memory_data_ready_o,
	output[31:0] ibus_memory_data_o,
	input        dbus_memory_en_i,
	output[31:0] dbus_memory_data_o,
	output       dbus_memory_data_ready_o,
	input        dbus_peripheral_en_i,
	output[31:0] dbus_peripheral_data_o,
	output       dbus_peripheral_data_ready_o,
	
	/* connected with bus */
	input [31:0] bus_mem_dat_i,
	input        bus_mem_ack_i,
	output       bus_mem_stb_o,
	output       bus_mem_we_o,
	output[31:0] bus_mem_adr_o,
	output[31:0] bus_mem_dat_o,
	output[3:0]  bus_mem_bytesel_o,
	
	input [31:0] bus_per_dat_i,
	input        bus_per_ack_i,
	output       bus_per_stb_o,
	output       bus_per_we_o,
	output[31:0] bus_per_adr_o,
	output[31:0] bus_per_dat_o,
	output[3:0]  bus_per_bytesel_o
);

	wire im_cs,ibus_mem_req,im_stb;
	wire dm_cs,dbus_mem_req,dm_stb;
	wire mem_req;
	wire[31:0] im_dat,dm_dat;
	
	//IM-总线子接口，是CPU-总线子接口的一个实例
	CpuBusSubInterface IM_Interface(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.cs_i(im_cs),
		.mem_req_i(mem_req),
		.mem_en_i(ibus_memory_en_i),
		.bus_ack_i(bus_mem_ack_i),
		.bus_dat_i(bus_mem_dat_i),
		.sub_req_o(ibus_mem_req),
		.sub_stb_o(im_stb),
		.sub_dat_o(im_dat)
	);
	
	//DM-总线子接口，是CPU-总线子接口的一个实例,连接内存总线
	CpuBusSubInterface DM_Interface(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.cs_i(dm_cs),
		.mem_req_i(mem_req),
		.mem_en_i(dbus_memory_en_i),
		.bus_ack_i(bus_mem_ack_i),
		.bus_dat_i(bus_mem_dat_i),
		.sub_req_o(dbus_mem_req),
		.sub_stb_o(dm_stb),
		.sub_dat_o(dm_dat)
	);

	assign mem_req = ibus_mem_req | dbus_mem_req;
	assign im_cs = ibus_mem_req & ~dbus_mem_req;
	assign dm_cs = dbus_mem_req;
	
	//DM-总线子接口，是CPU-总线子接口的一个实例,连接外设总线
	wire dp_req,dp_stb;
	wire[31:0] dp_dat;
	CpuBusSubInterface DM_PER_Interface(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.cs_i(1'b1),
		.mem_req_i(dp_req),
		.mem_en_i(dbus_peripheral_en_i),
		.bus_ack_i(bus_per_ack_i),
		.bus_dat_i(bus_per_dat_i),
		.sub_req_o(dp_req),
		.sub_stb_o(dp_stb),
		.sub_dat_o(dp_dat)
	);
	
	assign ibus_memory_data_o = im_dat;
	assign dbus_memory_data_o = dm_dat;
	assign dbus_peripheral_data_o = dp_dat;
	
	assign ibus_memory_data_ready_o = !ibus_mem_req & ibus_memory_en_i;
	assign dbus_memory_data_ready_o = !dbus_mem_req & dbus_memory_en_i;
	assign dbus_peripheral_data_ready_o = !dp_req;
	
	/* bus signals */
	assign bus_mem_stb_o = im_stb|dm_stb;
	assign bus_mem_we_o = data_wr_i & dm_cs;
	assign bus_mem_adr_o = (iphy_addr_i&{32{im_cs}})|(dphy_addr_i&{32{dm_cs}});
	assign bus_mem_dat_o = data_i;
	assign bus_mem_bytesel_o = im_cs ? 4'b1111 : data_bytesel_i;
	
	assign bus_per_stb_o = dp_stb;
	assign bus_per_we_o  = data_wr_i;
	assign bus_per_adr_o = dphy_addr_i;
	assign bus_per_dat_o = data_i;
	assign bus_per_bytesel_o = data_bytesel_i;

endmodule
