module IFID_register(
	input clk,
	input reset,
	input pa_pc_ifid,
	input wash_ifid,
	input [31:0]if_bpu_pc,
	input [4:0]if_bpu_index,
	input [31:0]if_pc_4_out,
	input [31:0]if_instr_out,
	input [31:0]if_pc_out,
	output [31:0]id_pc_4_out,
	output [31:0]id_jaddr_out,
	output [31:0]id_bpu_pc,
	output [4:0]id_bpu_index,
	output [31:0]id_instr,
	output [15:0]id_imm,
	output [31:0]id_pc_out,
	output [4:0]id_shamt,
	output [4:0]id_rs_addr,
	output [4:0]id_rt_addr,
	output [4:0]id_rd_addr
);

	reg [31:0]I_bpu_pc;
	reg [4:0]I_bpu_index;
	reg [31:0]I_pc_4_out;
	reg [31:0]I_instr_out;
	reg [31:0]I_pc_out;
	
	always @ (posedge clk) begin
		if (wash_ifid || reset) begin
			I_instr_out = 32'd0;
			I_bpu_pc = 32'd0;
			I_bpu_index = 5'd0;
			I_pc_4_out = 32'd0;
			I_pc_out = 32'd0;
		end
		else begin
			if (pa_pc_ifid == 1'b0) begin
				I_bpu_index = if_bpu_index;
				I_bpu_pc = if_bpu_pc;
				I_pc_4_out = if_pc_4_out;
				I_instr_out = if_instr_out;
				I_pc_out = if_pc_out;
			end
		end
	end
	
	assign id_pc_4_out = I_pc_4_out;
	assign id_jaddr_out = {I_pc_out[31:28],I_instr_out[25:0],2'b00};
	assign id_bpu_pc = I_bpu_pc;
	assign id_bpu_index = I_bpu_index;
	assign id_instr = I_instr_out;
	assign id_imm = I_instr_out[15:0];
	assign id_pc_out = I_pc_out;
	assign id_shamt = I_instr_out[10:6];
	assign id_rs_addr = I_instr_out[25:21];
	assign id_rt_addr = I_instr_out[20:16];
	assign id_rd_addr = I_instr_out[15:11];

endmodule