module VgaCtrl(
	input [9:0] h_count_i,
	input [9:0] v_count_i,
	output vga_hs_o,
	output vga_vs_o,
	output vga_blank_N_o,
	output vga_sync_N_o,
	output envalid_o,
	output [12:0] char_addr_o,
	output [2:0] x_addr_o,
	output [2:0] y_addr_o);

	parameter H_COUNT_CYC = 95;
	parameter X_START = 144;
	parameter X_END = 783;
	parameter H_COUNT_TOTAL = 799;
	parameter V_COUNT_CYC = 1;
	parameter Y_START = 35;
	parameter Y_END = 514;
	parameter V_COUNT_TOTAL = 524;
	
	//行列消隐信号
	assign vga_hs_o = (h_count_i[9:0] > H_COUNT_CYC);
	assign vga_vs_o = (v_count_i[9:0] > V_COUNT_CYC);
	assign vga_blank_N_o = vga_hs_o & vga_vs_o;
	assign vga_sync_N_o = 1'b0;
	
	//为计算地址产生的中间变量
	wire [9:0] pos_x;
	wire [9:0] pos_y;
	assign pos_x[9:0] = h_count_i[9:0] - X_START[9:0];
	assign pos_y[9:0] = v_count_i[9:0] - Y_START[9:0];
	
	//像素颜色使能
	assign envalid_o = (h_count_i[9:0] >= X_START[9:0]) & (h_count_i[9:0] <= X_END[9:0]) & 
					(v_count_i[9:0] >= Y_START[9:0]) & (v_count_i[9:0] <= Y_END[9:0]);
	
	//字符地址及字模内坐标
	assign char_addr_o[12:0] = (envalid_o == 1'b1) ? ({pos_y[9:3], 6'b0} + {pos_y[9:3], 4'b0} + {pos_x[9:3]}) : (13'b0);
	assign x_addr_o[2:0] = (envalid_o == 1'b1) ? ({pos_x[2:0]}) : (3'b0);
	assign y_addr_o[2:0] = (envalid_o == 1'b1) ? ({pos_y[2:0]}) : (3'b0);

	
endmodule
