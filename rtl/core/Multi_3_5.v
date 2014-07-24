module Multi_3_5(
	input [4:0]a,
	input [4:0]b,
	input [4:0]c,
	input [1:0] sel,
	output reg [4:0]data
);

	always@(*)
	begin
		case(sel)
			2'd0: data = a;
			2'd1: data = b;
			2'd2: data = c;
			default: data = a;
		endcase
	end

endmodule