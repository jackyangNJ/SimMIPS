module clock_generator
#(
	parameter CLOCK_IN_FREQ = 50000000,
	parameter CLOCK_OUT_FREQ = 123333
)
(
	input clk_i,
	input rst_i,
	output clk_o
);

	localparam DIVISOR = CLOCK_IN_FREQ / CLOCK_OUT_FREQ;
	reg[25:0] counter;
	
	always@(posedge clk_i)
	begin
		if(rst_i)
			counter <= 0;
		else
			if(counter == DIVISOR[25:0])
				counter <= 0;
			else
				counter <= counter + 1'b1;
	end
	
	assign clk_o = counter == DIVISOR[25:0];
	
endmodule
