module BusVgaWrCtrl(
	input clk_i,
	input cs_i,
	input wr_en_i,
	input [31:0] wdata_i,
	input [31:0] addr_i,
	output [31:0] rdata_o,
	output ack_o,
	output gm_en_o,
	output gm_wr_en_o,
	output [7:0] gm_wdata_o,
	output [12:0] gm_addr_o,
	input [7:0] gm_rdata_i,
	input gm_ack_i,
	output [1:0] c_w_select_o,
	output [7:0] c_wdata_o,
	input c_en_i,
	input [7:0] c_row_i,
	input [7:0] c_col_i);
	
	wire t_gm_en;
	wire t_c_en_en;
	wire t_c_row_en;
	wire t_c_col_en;
	
	//判断具体写哪一部分（显存、光标使能、光标行、光标列）
	assign t_gm_en = (addr_i[12:0] < 13'h12C0) & cs_i;
	assign t_c_en_en = (addr_i[12:0] == 13'h12C0) & cs_i;
	assign t_c_row_en = (addr_i[12:0] == 13'h12C1) & cs_i;
	assign t_c_col_en = (addr_i[12:0] == 13'h12C2) & cs_i;
	
	assign rdata_o[31:0] = (t_gm_en == 1'b1) ? {24'b0, gm_rdata_i[7:0]} : 
								((t_c_en_en == 1'b1) ? {31'b0, c_en_i} : 
								((t_c_row_en == 1'b1) ? {24'b0, c_row_i[7:0]} : 
								((t_c_col_en == 1'b1) ? {24'b0, c_col_i[7:0]} : 32'b0)));
	
	assign ack_o = cs_i & ((t_gm_en == 1'b1) ? gm_ack_i : (t_c_en_en | t_c_row_en | t_c_col_en));
	
	assign gm_en_o = t_gm_en;
	assign gm_wr_en_o = t_gm_en & wr_en_i;
	assign gm_wdata_o[7:0] = wdata_i[7:0];
	assign gm_addr_o[12:0] = addr_i[12:0];
	
	//光标寄存器组写控制信号
	assign c_w_select_o[0] = wr_en_i & (t_c_en_en | t_c_col_en);
	assign c_w_select_o[1] = wr_en_i & (t_c_row_en | t_c_col_en);
	
	assign c_wdata_o[7:0] = wdata_i[7:0];
	
endmodule
