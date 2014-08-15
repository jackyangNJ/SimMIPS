module kb_top(
		input  clk_i,
		input  rst_i,
		input  stb_i,
		input  cyc_i,
		input  we_i,
		input [3:0] sel_i,
		output ack_o,
		output int_o,
		input [31:0] adr_i,
		input [31:0] dat_i,
		output[31:0] dat_o,
		/* KeyBoard */
	 	input  kb_clk_i,
		input  kb_dat_i
);

	wire [7:0] code;
	wire ready;
	kb_scan kbscan(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.kb_clk_i(kb_clk_i),
		.kb_dat_i(kb_dat_i),
		.ready_o(ready),
		.code_o(code)
	);
		
	kb_core kbcore(
			.clk_i(clk_i),
			.rst_i(rst_i),
			.stb_i(stb_i),
			.cyc_i(cyc_i),
			.sel_i(sel_i),
			.we_i(we_i),
			.dat_o(dat_o),
			.ack_o(ack_o),
			.adr_i(adr_i),
			.int_o(int_o),
			.code_i(code),
			.ready_i(ready)
	);
endmodule
