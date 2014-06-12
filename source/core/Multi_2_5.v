module Multi_2_5(
	input [4:0]a,
	input [4:0]b,
	input sel,
	output [4:0]data
);

	assign data = (sel==1'b1) ? b : a;

endmodule