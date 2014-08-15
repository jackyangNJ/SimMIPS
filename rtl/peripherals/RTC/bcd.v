module bcd
#(
	parameter MAX_NUM = 8'h59
)
(
	input clk_i,
	input rst_i,
	output[7:0] dat_o,
	output increment_one_o
);

	reg[7:0] counter;
	reg increment_one;
	always@(posedge clk_i)
	begin
		if(rst_i)
			begin
				counter <= 0;
				increment_one <= 0;
			end
		else
			if(counter == MAX_NUM[7:0])
				begin
					increment_one <= 1'b1;
					counter <= 0;
				end
			else
				begin
					increment_one <= 0;
					if(counter[3:0] == 4'd9)
						begin
							counter[3:0] = 0;
							counter[7:4] = counter[7:4] + 1'b1;
						end
				end
	end
	
	assign increment_one_o = increment_one;
	assign dat_o = counter;
	
	
endmodule
