/*
 * This is a simplified 8259A PIC
 */
module 8259a(
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

	

endmodule