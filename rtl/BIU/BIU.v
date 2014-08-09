module BIU(
	input        clk_i,
	input        rst_i,
	
	/* connected with CPU core */
	input [31:0] dphy_addr_i,
	input [31:0] iphy_addr_i,
	input [31:0] data_i,
	input        data_wr_i,
	input [1:0]  data_type_i,
	
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
	output[3:0]  bus_mem_sel_o,
	
	input [31:0] bus_per_dat_i,
	input        bus_per_ack_i,
	output       bus_per_stb_o,
	output       bus_per_we_o,
	output[31:0] bus_per_adr_o,
	output[31:0] bus_per_dat_o,
	output[3:0]  bus_per_sel_o
);

	wire im_cs,ibus_mem_req,ibus_mem_stb;
	wire dm_cs,dbus_mem_req,dbus_mem_stb;
	wire dp_cs,dbus_per_req,dbus_per_stb;
	wire bus_req;
	wire[31:0] ibus_mem_dat,dbus_mem_dat;
	
	//IM-总线子接口，是CPU-总线子接口的一个实例
	CpuBusSubInterface IM_Interface(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.cs_i(im_cs),
		.mem_req_i(bus_req),
		.mem_en_i(ibus_memory_en_i),
		.bus_ack_i(bus_mem_ack_i),
		.bus_dat_i(bus_mem_dat_i),
		.sub_req_o(ibus_mem_req),
		.sub_stb_o(ibus_mem_stb),
		.sub_dat_o(ibus_mem_dat)
	);
	
	//DM-总线子接口，是CPU-总线子接口的一个实例,连接内存总线
	CpuBusSubInterface DM_Interface(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.cs_i(dm_cs),
		.mem_req_i(bus_req),
		.mem_en_i(dbus_memory_en_i),
		.bus_ack_i(bus_mem_ack_i),
		.bus_dat_i(bus_mem_dat_i),
		.sub_req_o(dbus_mem_req),
		.sub_stb_o(dbus_mem_stb),
		.sub_dat_o(dbus_mem_dat)
	);

	assign bus_req = ibus_mem_req | dbus_mem_req | dbus_per_req;
	assign im_cs = ibus_mem_req & ~dbus_mem_req;
	assign dm_cs = dbus_mem_req;
	
	//DM-总线子接口，是CPU-总线子接口的一个实例,连接外设总线
	wire[31:0] dbus_per_dat;
	
	CpuBusSubInterface DM_PER_Interface(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.cs_i(1'b1),
		.mem_req_i(bus_req),
		.mem_en_i(dbus_peripheral_en_i),
		.bus_ack_i(bus_per_ack_i),
		.bus_dat_i(bus_per_dat_i),
		.sub_req_o(dbus_per_req),
		.sub_stb_o(dbus_per_stb),
		.sub_dat_o(dbus_per_dat)
	);
	
	/* generate bus signal sel*/
	reg[3:0] dbus_bytesel;
	always@(*)
	begin
		dbus_bytesel = 0;
		case(data_type_i)
			2'b01:
				dbus_bytesel[dphy_addr_i[1:0]] = 1'b1;
			2'b10:
				if(dphy_addr_i[1])
					dbus_bytesel = 4'b1100;
				else
					dbus_bytesel = 4'b0011;
			default:
				dbus_bytesel = 4'b1111;
		endcase
	end
	
	/* dealing byte select for data input */
	reg[31:0] dbus_data;
	always@(*)
	begin
		if(dbus_memory_en_i)
			dbus_data = dbus_mem_dat;
		else
			dbus_data = dbus_per_dat;
		case(dbus_bytesel)
			4'b0001: dbus_data = {24'b0,dbus_data[7:0]};
			4'b0010: dbus_data = {24'b0,dbus_data[15:8]};
			4'b0100: dbus_data = {24'b0,dbus_data[23:16]};
			4'b1000: dbus_data = {24'b0,dbus_data[31:24]};
			4'b0011: dbus_data = {16'b0,dbus_data[15:0]};
			4'b1100: dbus_data = {16'b0,dbus_data[31:16]};
			default: dbus_data = dbus_data;
		endcase
	end
	
	/*adjust order of data output*/
	reg[31:0] dbus_data_output;
	always@(*)
	begin
		dbus_data_output = data_i;
		case(dbus_bytesel)
			4'b0001: dbus_data_output[7:0]   = data_i[7:0];
			4'b0010: dbus_data_output[15:8]  = data_i[7:0];
			4'b0100: dbus_data_output[23:16] = data_i[7:0];
			4'b1000: dbus_data_output[31:24] = data_i[7:0];
			4'b0011: dbus_data_output[15:0]  = data_i[15:0];
			4'b1100: dbus_data_output[31:16] = data_i[15:0];
			default: dbus_data_output = data_i;
		endcase
	end
	
	assign ibus_memory_data_o = ibus_mem_dat;
	assign dbus_memory_data_o = dbus_data;
	assign dbus_peripheral_data_o = dbus_data;
	
	assign ibus_memory_data_ready_o = !ibus_mem_req & ibus_memory_en_i;
	assign dbus_memory_data_ready_o = !dbus_mem_req & dbus_memory_en_i;
	assign dbus_peripheral_data_ready_o = !dbus_per_req & dbus_peripheral_en_i;
	
	/* bus signals */
	assign bus_mem_stb_o = ibus_mem_stb|dbus_mem_stb;
	assign bus_mem_we_o = data_wr_i & dm_cs;
	assign bus_mem_adr_o = (iphy_addr_i&{32{im_cs}})|(dphy_addr_i&{32{dm_cs}});
	assign bus_mem_dat_o = dbus_data_output;
	assign bus_mem_sel_o = im_cs ? 4'b1111 : dbus_bytesel;
	
	assign bus_per_stb_o = dbus_per_stb;
	assign bus_per_we_o  = data_wr_i;
	assign bus_per_adr_o = dphy_addr_i;
	assign bus_per_dat_o = dbus_data_output;
	assign bus_per_sel_o = dbus_bytesel;

endmodule
