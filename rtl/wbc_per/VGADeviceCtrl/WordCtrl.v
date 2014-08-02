module WordCtrl(
	input [7:0] ascii_i,
	input [2:0] row_addr_i,
	output [9:0] read_addr_o,
	input [7:0] read_data_i,
	output [7:0] read_data_o);
	
	//地址数据连线，地址线处防止下标越界
	assign read_addr_o[9:0] = {ascii_i[6:0], row_addr_i[2:0]};
	assign read_data_o[7:0] = (ascii_i[7] == 1'b0) ? (read_data_i[7:0]) : (8'b0);

endmodule
