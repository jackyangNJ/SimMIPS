module NextCharAddr(
	input [12:0] char_addr_i,
	input [9:0] h_count_i,
	input [9:0] v_count_i,
	input [2:0] y_addr_i,
	output reg[12:0] next_char_o,
	output reg[2:0] next_y_addr_o);
	
	parameter FIRST_X_START = 144;
	parameter FIRST_Y_START = 35;
	
	//为计算字模内行地址的中间变量
	wire [9:0] t_pos_y;
	assign t_pos_y[9:0] = v_count_i[9:0] - FIRST_Y_START[9:0];
	
	always@(*)
	begin
		if(h_count_i[9:0] < FIRST_X_START[9:0])	//一行开头
		begin
			next_char_o[12:0] = {t_pos_y[9:3], 6'b0} + {t_pos_y[9:3], 4'b0};
			next_y_addr_o[2:0] = t_pos_y[2:0];
		end
		else		//行中
		begin
			next_char_o[12:0] = char_addr_i[12:0] + 1'b1;
			next_y_addr_o[2:0] = y_addr_i[2:0];
		end
	end
endmodule
