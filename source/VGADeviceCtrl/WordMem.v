module WordMem(
	input clk_i,
	input [9:0] read_addr_i,
	output [7:0] read_data_o);
	
	WordMemM4K WM(
		.address(read_addr_i),
		.clock(clk_i),
		.q(read_data_o));
	
endmodule
