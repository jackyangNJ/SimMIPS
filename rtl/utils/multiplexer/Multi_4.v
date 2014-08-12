module Multi_4
#(
	parameter DATA_WIDTH = 32
)(
	input [DATA_WIDTH-1:0]a,
	input [DATA_WIDTH-1:0]b,
	input [DATA_WIDTH-1:0]c,
	input [DATA_WIDTH-1:0]d,
	input [1:0]sel,
	output [DATA_WIDTH-1:0]data
);

	assign data = (sel[1]==1'b1) ? ((sel[0]==1'b1) ? d : c) : ((sel[0]==1'b1) ? b : a);

endmodule