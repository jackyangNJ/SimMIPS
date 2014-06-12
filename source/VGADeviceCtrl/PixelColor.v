module PixelColor(
	input pixel_color_i,
	input c_flash_i,
	input [12:0] char_addr_i,
	input cursor_en_i,
	input [7:0] cursor_row_i,
	input [7:0] cursor_col_i,
	input envalid_i,
	output [9:0] color_R_o,
	output [9:0] color_G_o,
	output [9:0] color_B_o);
	
	wire [12:0] cursor_addr;
	wire flash;
	wire color;
	
	//根据光标信息判断是否取反
	assign cursor_addr[12:0] = ({cursor_row_i[6:0], 4'b0}) + ({cursor_row_i[6:0], 6'b0}) + (cursor_col_i[7:0]);
	assign flash = cursor_en_i & c_flash_i & (char_addr_i[12:0] == cursor_addr[12:0]);
	assign color = (flash ^ pixel_color_i) & envalid_i;
				
	//输出颜色为黑或白
	assign color_R_o[9:0] = (color == 1'b1) ? 10'h3ff : 10'd0;
	assign color_G_o[9:0] = (color == 1'b1) ? 10'h3ff : 10'd0;
	assign color_B_o[9:0] = (color == 1'b1) ? 10'h3ff : 10'd0;

endmodule
