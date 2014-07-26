module IDEx_register(
	input clk,
	input reset,
	input pa_idexmemwr,
	input wash_idex,
	input id_regwr,
	input id_memtoreg,
	input id_memwr,
	input [31:0] return_addr_i,
	input [31:0] id_pc_i,
	input [2:0]id_ex_result_sel,
	input id_alu_b_sel,
	input [3:0] id_alu_op,
	input [3:0] mdu_op_i,
	input [1:0]id_shift_op,
	input id_dmen,
	input id_of_ctrl,
	input [4:0]id_shift_amount,
	input [31:0]id_a,
	input [31:0]id_b,
	input [31:0]id_imm_ext,
	input [4:0]id_regdst_addr,
	input [31:0]id_cp0_out,
	output ex_regwr,
	output ex_memtoreg,
	output ex_memwr,
	output ex_dmen,
	output [1:0]ex_shift_op,
	output [4:0]ex_shift_amount,
	output ex_of_ctrl,
	output [3:0]ex_alu_op,
	output [3:0]mdu_op_o,
	output [2:0]ex_result_sel,
	output [31:0]ex_a,
	output ex_alu_b_sel,
	output [31:0]ex_b,
	output [31:0]ex_imm_ext,
	output [4:0]ex_regdst_addr,
	output [31:0]ex_cp0_out,
	output [31:0]return_addr_o,
	output [31:0]ex_pc_o
);

	reg I_regwr;
	reg I_memtoreg;
	reg I_memwr;
	reg [2:0]I_ex_result_sel;
	reg I_alu_b_sel;
	reg [3:0]I_alu_op;
	reg [3:0] I_mdu_op;
	reg [1:0]I_shift_op;
	reg I_dmen;
	reg I_of_ctrl;
	reg [4:0]I_shift_amount;
	reg [31:0]I_a;
	reg [31:0]I_b;
	reg [31:0]I_imm_ext;
	reg [4:0]I_regdst_addr;
	reg [31:0]I_cp0_out;
	reg [31:0]I_return_addr;
	reg [31:0]I_pc;
	always @ (posedge clk) begin
		if (wash_idex || reset) begin
			I_regwr <= 1'b0;
			I_memtoreg <= 1'b0;
			I_memwr <= 1'b0;
			I_ex_result_sel <= 2'b00;
			I_alu_b_sel <= 1'b0;
			I_alu_op <= 4'd0;
			I_mdu_op <= 4'd0;
			I_shift_op <= 2'b00;
			I_dmen <= 1'b0;
			I_of_ctrl <= 1'b0;
			I_shift_amount <= 5'd0;
			I_a <= 32'd0;
			I_b <= 32'd0;
			I_imm_ext <= 32'd0;
			I_regdst_addr <= 5'd0;
			I_cp0_out <= 32'd0;
			I_return_addr <= 32'b0;
			I_pc <= 32'b0;
		end
		else begin
			if (pa_idexmemwr == 1'b0) begin
				I_regwr <= id_regwr;
				I_memtoreg <= id_memtoreg;
				I_memwr <= id_memwr;
				I_ex_result_sel <= id_ex_result_sel;
				I_alu_b_sel <= id_alu_b_sel;
				I_alu_op <= id_alu_op;
				I_mdu_op <= mdu_op_i;
				I_shift_op <= id_shift_op;
				I_dmen <= id_dmen;
				I_of_ctrl <= id_of_ctrl;
				I_shift_amount <= id_shift_amount;
				I_a <= id_a;
				I_b <= id_b;
				I_imm_ext <= id_imm_ext;
				I_regdst_addr <= id_regdst_addr;
				I_cp0_out <= id_cp0_out;
				I_return_addr <= return_addr_i;
				I_pc <= id_pc_i;
			end
		end
	end

	assign ex_regwr = I_regwr;
	assign ex_memtoreg = I_memtoreg;
	assign ex_memwr = I_memwr;
	assign ex_dmen = I_dmen;
	assign ex_shift_op = I_shift_op;
	assign ex_shift_amount = I_shift_amount;
	assign ex_of_ctrl = I_of_ctrl;
	assign ex_alu_op = I_alu_op;
	assign mdu_op_o = I_mdu_op;
	assign ex_result_sel = I_ex_result_sel;
	assign ex_a = I_a;
	assign ex_alu_b_sel = I_alu_b_sel;
	assign ex_b = I_b;
	assign ex_imm_ext = I_imm_ext;
	assign ex_regdst_addr = I_regdst_addr;
	assign ex_cp0_out = I_cp0_out;
	assign return_addr_o = I_return_addr;
	assign ex_pc_o = I_pc;
endmodule