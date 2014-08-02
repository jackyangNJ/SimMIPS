module KBController(
						clk_i,
						rst_i,
						kb_clk_i,
						kb_dat_i,
						cs_i,
						we_i,
						adr_i,
						dat_o,
						int_o,
						ack_o
						
);
input clk_i,rst_i;
/* KeyBoard */
input kb_clk_i,kb_dat_i;
/* Bus */
input cs_i,we_i;
output ack_o;
input [31:0] adr_i;
output [31:0] dat_o;
/* CPU Core */
output int_o;
		wire ready;
		wire [7:0] data;
		KBScan kbscan(
			.clk_i(clk_i),
			.rst_i(rst_i),
			.kb_clk_i(kb_clk_i),
			.kb_dat_i(kb_dat_i),
			.ready(ready),
			.data(data)
		);
		
		KBCore kbcore(
				.clk_i(clk_i),
				.rst_i(rst_i),
				.cs_i(cs_i),
				.we_i(we_i),
				.dat_o(dat_o),
				.ack_o(ack_o),
				.adr_i(adr_i),
				.int_o(int_o),
				.data(data),
				.ready(ready)
);
endmodule
