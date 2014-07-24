module BarSH(
	input [1:0]ex_shift_op,
	input [31:0]ex_b,
	input [4:0]ex_shift_amount,
	output [31:0]ex_bs_out
);

	reg [31:0]r;
	
	always @ (ex_shift_amount or ex_b or ex_shift_op) begin
		r = ex_b;
		case (ex_shift_op)
			2'b01: begin
				if (ex_shift_amount[0])
					r = {1'b0, r[31:1]};
				if (ex_shift_amount[1])
					r = {2'd0, r[31:2]};
				if (ex_shift_amount[2])
					r = {4'd0, r[31:4]};
				if (ex_shift_amount[3])
					r = {8'd0, r[31:8]};
				if (ex_shift_amount[4])
					r = {16'd0, r[31:16]};
			end
			
			2'b10: begin
				if (r[31]) begin
					if (ex_shift_amount[0])
						r = {1'b1, r[31:1]};
					if (ex_shift_amount[1])
						r = {2'b11, r[31:2]};
					if (ex_shift_amount[2])
						r = {4'hf, r[31:4]};
					if (ex_shift_amount[3])
						r = {8'hff, r[31:8]};
					if (ex_shift_amount[4])
						r = {16'hffff, r[31:16]};
				end
				else begin
					if (ex_shift_amount[0])
						r = {1'b0, r[31:1]};
					if (ex_shift_amount[1])
						r = {2'd0, r[31:2]};
					if (ex_shift_amount[2])
						r = {4'd0, r[31:4]};
					if (ex_shift_amount[3])
						r = {8'd0, r[31:8]};
					if (ex_shift_amount[4])
						r = {16'd0, r[31:16]};
				end
			end
			
			default: begin
				if (ex_shift_amount[0])
					r = {r[30:0], 1'b0};
				if (ex_shift_amount[1])
					r = {r[29:0], 2'd0};
				if (ex_shift_amount[2])
					r = {r[27:0], 4'd0};
				if (ex_shift_amount[3])
					r = {r[23:0], 8'd0};
				if (ex_shift_amount[4])
					r = {r[15:0], 16'd0};
			end
		endcase
	end

	assign ex_bs_out = r;
	
endmodule