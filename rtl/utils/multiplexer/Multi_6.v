module Multi_6
#(
	parameter DATA_WIDTH = 32
)
(
	input [DATA_WIDTH-1:0]a,
	input [DATA_WIDTH-1:0]b,
	input [DATA_WIDTH-1:0]c,
	input [DATA_WIDTH-1:0]d,
	input [DATA_WIDTH-1:0]e,
	input [DATA_WIDTH-1:0]f,
	input [2:0]sel,
	output reg [DATA_WIDTH-1:0]data
);

	always@(*)
	begin
		case(sel)
			3'd0: data = a;
			3'd1: data = b;
			3'd2: data = c;
			3'd3: data = d;
			3'd4: data = e;
			3'd5: data = f;
			default: data=0;
		endcase
	end

endmodule