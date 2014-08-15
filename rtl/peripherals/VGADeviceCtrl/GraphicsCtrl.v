module GraphicsCtrl(
	input bus_clk_i,
	input bus_en_i,
	input bus_wren_i,
	input [7:0] bus_wdata_i,
	input [12:0] bus_addr_i,
	output [7:0] bus_rdata_o,
	output bus_ack_o,
	input [12:0] vga_raddr_i,
	output [7:0] vga_rdata_o,
	output [12:0] gm_bus_addr_o,
	output [12:0] gm_vga_addr_o,
	output [7:0] gm_bus_data_o,
	output [7:0] gm_vga_data_o,
	output gm_bus_wren_o,
	output gm_vga_wren_o,
	input [7:0] gm_bus_data_i,
	input [7:0] gm_vga_data_i);
	
	reg reg_ack;	//应答信号寄存器
	
	//直接连线输出
	assign bus_rdata_o[7:0] = gm_bus_data_i[7:0];
	assign bus_ack_o = reg_ack;
	assign vga_rdata_o[7:0] = gm_vga_data_i[7:0];
	assign gm_vga_data_o[7:0] = 8'b0;
	assign gm_vga_wren_o = 1'b0;
	
	//条件判断后输出
	assign gm_vga_addr_o[12:0] = (vga_raddr_i[12:0] < 13'h12C0) ? vga_raddr_i[12:0] : 13'b0;
	assign gm_bus_addr_o[12:0] = (bus_en_i == 1'b1) ? bus_addr_i[12:0] : 13'b0;
	assign gm_bus_data_o[7:0] = ((bus_en_i == 1'b1) && (bus_wren_i == 1'b1)) ? bus_wdata_i[7:0] : 8'b0;
	assign gm_bus_wren_o = (bus_en_i == 1'b1) ? bus_wren_i : 1'b0;
	
	//寄存器
	always@(posedge bus_clk_i)
	begin
		reg_ack <= bus_en_i;
	end
	
endmodule
