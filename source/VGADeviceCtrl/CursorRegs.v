module CursorRegs(
	input clk_i,
	input [1:0] w_select_i,
	input [7:0] wdata_i,
	input reset_i,
	output c_en_o,
	output [7:0] c_row_o,
	output [7:0] c_col_o);
	
	reg reg_cursor_en;	//使能
	reg [7:0] reg_cursor_row;	//行
	reg [7:0] reg_cursor_col;	//列
	
	assign c_en_o = reg_cursor_en;
	assign c_row_o[7:0] = reg_cursor_row[7:0];
	assign c_col_o[7:0] = reg_cursor_col[7:0];
	
	always@(posedge clk_i)
	begin
		if(reset_i == 1'b1)
		begin
			reg_cursor_en <= 1'b0;
			reg_cursor_row[7:0] <= 8'b0;
			reg_cursor_col[7:0] <= 8'b0;
		end
		else
		begin
			case(w_select_i[1:0])
				2'b01:
					reg_cursor_en <= wdata_i[0];
				2'b10:	//写行列时防止数据越界
					if(wdata_i[7:0] <= 59)
						reg_cursor_row[7:0] <= wdata_i[7:0];
				2'b11:
					if(wdata_i[7:0] <= 79)
						reg_cursor_col[7:0] <= wdata_i[7:0];
			endcase
		end
	end

endmodule
