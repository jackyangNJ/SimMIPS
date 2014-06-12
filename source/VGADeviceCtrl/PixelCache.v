module PixelCache(
	input clk_i,
	input [7:0] pixel_data_i,
	input cache_rselect_i,
	input cache_wselect_i,
	input [2:0] x_addr_i,
	output pixel_data_o);
	
	reg [7:0] reg_pixel [1:0];
	
	//读出当前像素
	assign pixel_data_o = reg_pixel[cache_rselect_i][x_addr_i];
	
	always@(posedge clk_i)
	begin
	//写入下一字符像素
		reg_pixel[cache_wselect_i][7:0] <= pixel_data_i[7:0];
	end

endmodule
