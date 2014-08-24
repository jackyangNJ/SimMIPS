module RamOnChip(
	input        clk_i,
	input        rst_i,
	input        stb_i,
	input        cyc_i,
	input        we_i,
	input[3:0]   sel_i,
	input[31:0]  adr_i,
	input[31:0]  dat_i,
	output[31:0] dat_o,
	output       ack_o
);


	wire cs = stb_i && cyc_i;
	reg ack;
	
	always@(posedge clk_i)
	begin
		if(rst_i)
			ack <= 0;
		else
			if(cs)
				ack <= 1'b1;
			else
				ack <= 1'b0;
	end
	
	SinglePortRam ram(
		.clk_i(clk_i),
		.we_i(we_i & cs & !ack),
		.adr_i(adr_i[13:2]),
		.be_i(sel_i),
		.dat_i(dat_i),
		.dat_o(dat_o)
	);
	
	assign ack_o = ack;
endmodule
