module CpuBusSubInterface(
	input clk_i,
	input rst_i,
	input cs_i,
	input mem_req_i,
	input mem_en_i,
	input bus_ack_i,
	input[31:0] bus_dat_i,
	output sub_req_o,
	output sub_stb_o,
	output[31:0] sub_dat_o
);

	reg sub_stb_reg;
	reg sub_ack_reg;
	reg[31:0] sub_dat_reg;

	/* sub_stb_reg */
	always @(posedge clk_i)
	begin
		if (rst_i)
			sub_stb_reg <= 1'b0;
		else
			if (bus_ack_i)
				sub_stb_reg <= 1'b0;
			else
				if (mem_en_i & !sub_ack_reg & cs_i)
					sub_stb_reg <= 1'b1;
	end
	/* sub_ack_reg */
	always @(posedge clk_i)
	begin
		if (rst_i)
			sub_ack_reg <= 1'b0;
		else
		if (~mem_req_i)
			sub_ack_reg <= 1'b0;
		else
		if (bus_ack_i & cs_i)
			sub_ack_reg <= 1'b1;
	end
	/* sub_dat_reg */
	always @(posedge clk_i)
	begin
		if (bus_ack_i & cs_i) 
			sub_dat_reg <= bus_dat_i;
	end

	assign sub_req_o = mem_en_i & !sub_ack_reg;
	assign sub_stb_o = sub_stb_reg;
	assign sub_dat_o = sub_dat_reg;

endmodule
