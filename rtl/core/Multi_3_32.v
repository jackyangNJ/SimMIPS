module Multi_3_32(
	input [31:0]a,
	input [31:0]b,
	input [31:0]c,
	input [1:0]sel,
	output [31:0]data
);

	assign data = (sel==2'b01) ? b : ((sel==2'b10) ? c : a);

endmodule