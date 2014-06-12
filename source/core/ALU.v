module ALU(
	input [3:0]ex_alu_op,
	input [31:0]ex_a,
	input [31:0]ex_alu_b,
	output [31:0]ex_alu_out,
	output ex_alu_of
);

	wire [31:0]res[7:0];
	wire [2:0]alu_ctr;
	wire carry;
	wire less;
	
	LeadingZero LZ(.out(res[0]),.in({32{ex_alu_op[0]}}^ex_a));
	assign res[1] = ex_a^ex_alu_b;
	assign res[2] = ex_a|ex_alu_b;
	assign res[3] = ~res[2];
	assign res[4] = ex_a&ex_alu_b;
	assign res[7] = {ex_alu_b[15:0],16'b0};
	
	wire[31:0] adder_op_b;
	assign adder_op_b = {32{ex_alu_op[0]}}^ex_alu_b;
	
	alu_adder alu_adder_32(
		.dataa(ex_a),
		.datab(adder_op_b),
		.cin(ex_alu_op[0]),
		.cout(carry),
		.result(res[6])
	);
	
	assign ex_alu_of = ex_a[31]&adder_op_b[31]&~res[6][31]
								|~ex_a[31]&~adder_op_b[31]&res[6][31];
	
	assign less = ex_alu_op[1]?~carry:ex_alu_of^res[6][31];
	assign res[5] = {31'b0,less};
	
	ALU_Control aluControl(
		.alu_op(ex_alu_op),
		.alu_ctr(alu_ctr)
	);
	
	assign ex_alu_out = res[alu_ctr];
endmodule

module ALU_Control
(
	input [3:0]alu_op,
	output reg [2:0]alu_ctr
);
	always @(*)
	begin
		case (alu_op)
			4'b0000: alu_ctr = 3'b110;
			4'b0001: alu_ctr = 3'b110;
			4'b0010: alu_ctr = 3'b000;
			4'b0011: alu_ctr = 3'b000;
			4'b0100: alu_ctr = 3'b100;
			4'b0101: alu_ctr = 3'b101;
			4'b0110: alu_ctr = 3'b010;
			4'b0111: alu_ctr = 3'b101;
			4'b1000: alu_ctr = 3'b011;
			4'b1001: alu_ctr = 3'b001;
			4'b1010: alu_ctr = 3'b111;
			default: alu_ctr = 3'bxxx;
		endcase
	end
endmodule

module LeadingZero
(
	input [0:31]in,
	output reg[31:0]out
);
	integer i,j;
	always@(*)
	begin:loop
		out = 32'd32;
		for (i=0;i<32;i=i+1)
			if (in[i]==1)
			begin
				out = i;
				disable loop;
			end
	end
endmodule
