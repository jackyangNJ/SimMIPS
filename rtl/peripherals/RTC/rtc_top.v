/*
 * according to ISA RTC standard
 */
module rtc_top
#(
	parameter CLOCK_FREQ = 50000000
)
(
	input clk_i,
	input rst_i,
	input cyc_i,
	input stb_i,
	input we_i,
	input [3:0] sel_i,
	input [31:0] adr_i,
	input [31:0] dat_i,
	output[31:0] dat_o,
	output ack_o
);

	wire[7:0] second,minute,hour;
	wire sencond_clk = (counter == CLOCK_FREQ);
	wire minute_clk,hour_clk;

	/* bus write */
	reg[7:0] command;
	reg ack;
	always@(posedge clk_i)
	begin
		if(rst_i)
			ack <= 0;
		if(cyc_i & stb_i)
			begin
				if(!adr_i[0] & we_i & sel_i[0])
					command <= dat_i[7:0];
				ack <= 1'b1;
			end
		else
			ack <= 0;
	end

	/* bus read */
	reg[15:0] data_out;
	always@(*)
	begin
		data_out[7:0] = command;
		case(command)
			8'h0: data_out[15:8] = second;
			8'h2: data_out[15:8] = minute;
			8'h4: data_out[15:8] = hour;
			default: 
				data_out[15:8] = 0;
		endcase
	end

	reg[26:0] counter;
	always@(posedge clk_i)
	begin
		if(rst_i)
			counter <= 0;
		else
			if(counter == CLOCK_FREQ)
				counter <= 0;
			else
				counter <= counter + 1'b1;
	end

	bcd #(
	.MAX_NUM(8'h59)
	)second_bcd(
		.clk_i(sencond_clk),
		.rst_i(rst_i),
		.dat_o(second),
		.increment_one_o(minute_clk)
	);
	bcd #(
	.MAX_NUM(8'h59)
	)minute_bcd(
		.clk_i(minute_clk),
		.rst_i(rst_i),
		.dat_o(minute),
		.increment_one_o(hour_clk)
	);
	
	bcd #(
	.MAX_NUM(8'h59)
	)hour_bcd(
		.clk_i(hour_clk),
		.rst_i(rst_i),
		.dat_o(hour),
	);
	
	assign dat_o = {16'b0,data_out};
	assign ack_o = ack;
endmodule

