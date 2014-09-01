module WordMem(
	input clk_i,
	input [9:0] read_addr_i,
	output [7:0] read_data_o);
	
	single_port_rom
	#(
		.DATA_WIDTH(8),
		.ADDR_WIDTH(10)
	)WM(
		.addr(read_addr_i),
		.clk(clk_i),
		.q(read_data_o));
	
endmodule
