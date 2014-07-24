module Multi_6_32(
	input [31:0]a,
	input [31:0]b,
	input [31:0]c,
	input [31:0]d,
	input [31:0]e,
	input [31:0]f,
	input [2:0]sel,
	output reg [31:0]data
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