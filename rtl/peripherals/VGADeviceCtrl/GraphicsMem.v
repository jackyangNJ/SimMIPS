module GraphicsMem(
	input [12:0] bus_addr_i,
	input [12:0] vga_addr_i,
	input bus_clk_i,
	input vga_clk_i,
	input [7:0] bus_data_i,
	input [7:0] vga_data_i,
	input bus_wren_i,
	input vga_wren_i,
	output [7:0] bus_data_o,
	output [7:0] vga_data_o
	);
	
	//M4K生成的4800B大小的显存
	dual_port_ram_dual_clock
	#(
		.DATA_WIDTH (8),
		.ADDR_WIDTH (13)
	)GM(
		.addr_a(bus_addr_i),
		.addr_b(vga_addr_i),
		.clk_a(bus_clk_i),
		.clk_b(vga_clk_i),
		.data_a(bus_data_i),
		.data_b(vga_data_i),
		.we_a(bus_wren_i),
		.we_b(vga_wren_i),
		.q_a(bus_data_o),
		.q_b(vga_data_o));
	
endmodule
