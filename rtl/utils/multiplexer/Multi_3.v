module Multi_3
#(
	parameter DATA_WIDTH = 32
)
(
	input [DATA_WIDTH-1:0]a,
	input [DATA_WIDTH-1:0]b,
	input [DATA_WIDTH-1:0]c,
	input [1:0]sel,
	output [DATA_WIDTH-1:0]data
);

	assign data = (sel==2'b01) ? b : ((sel==2'b10) ? c : a);

endmodule