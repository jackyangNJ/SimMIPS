module Multi_2_32(
	input [31:0]a,
	input [31:0]b,
	input sel,
	output [31:0]data
);

	assign data = (sel==1'b1) ? b : a;

endmodule