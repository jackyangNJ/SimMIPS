module Counters(
	input clk_i,
	input reset_i,
	output [9:0] h_count_o,
	output [9:0] v_count_o,
	output c_flash_o);
	
	parameter H_COUNT_TOTAL = 799;
	parameter V_COUNT_TOTAL = 524;
	parameter C_COUNT_TOTAL = 118;
	parameter C_FLASH = 59;
	
	reg [9:0] reg_h_count;
	reg [9:0] reg_v_count;
	reg [7:0] reg_c_count;
	
	assign h_count_o[9:0] = reg_h_count[9:0];
	assign v_count_o[9:0] = reg_v_count[9:0];
	assign c_flash_o = (reg_c_count[7:0] >= C_FLASH);
	
	always@(posedge clk_i)
	begin
		if(reset_i == 1'b1)	//重置清零
		begin
			reg_h_count <= 10'b0;
			reg_v_count <= 10'b0;
			reg_c_count <= 8'b0;
		end
		else
		begin
			if(reg_h_count[9:0] >= H_COUNT_TOTAL)	//h到达最大值
			begin
				reg_h_count[9:0] <= 10'b0;
				if(reg_v_count[9:0] >= V_COUNT_TOTAL)	//v到达最大值
				begin
					reg_v_count[9:0] <= 10'b0;
					if(reg_c_count[7:0] >= C_COUNT_TOTAL)	//c到达最大值
						reg_c_count[7:0] <= 8'b0;
					else
						reg_c_count[7:0] <= reg_c_count[7:0] + 1'b1;
				end
				else
					reg_v_count[9:0] <= reg_v_count[9:0] + 1'b1;
			end
			else
				reg_h_count[9:0] <= reg_h_count[9:0] + 1'b1;
		end
	end

endmodule
