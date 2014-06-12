module Multi_4_32(
	input [31:0]a,
	input [31:0]b,
	input [31:0]c,
	input [31:0]d,
	input [1:0]sel,
	output [31:0]data
);

	assign data = (sel[1]==1'b1) ? ((sel[0]==1'b1) ? d : c) : ((sel[0]==1'b1) ? b : a);

endmodule