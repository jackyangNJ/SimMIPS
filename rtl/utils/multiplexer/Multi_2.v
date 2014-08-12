module Multi_2
#(
	parameter DATA_WIDTH = 32
)
(
	input [DATA_WIDTH-1:0]a,
	input [DATA_WIDTH-1:0]b,
	input sel,
	output [DATA_WIDTH-1:0]data
);

	assign data = (sel==1'b1) ? b : a;

endmodule