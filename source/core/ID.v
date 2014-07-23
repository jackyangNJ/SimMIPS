`include "InstructionConstants.v"
module ID(
	input cu_intr,
	input [31:0]id_bpu_pc,
	input [31:0]id_instr,
	input [31:0]id_br_addr,
	input [31:0]status_out,
	input [3:0]id_compare,
	output id_pc_sel,
	output [1:0]id_bpu_wen,
	output [1:0]selpc,
	output id_dmen,
	output id_regwr,
	output id_memtoreg,
	output id_memwr,
	output [3:0] mem_bytesel_o,
	output mem_extsigned_o,
	output [2:0]id_ex_result_sel,
	output id_alu_b_sel,
	output [3:0]id_alu_op,
	output [1:0]id_shift_op,
	output [1:0]id_bra_addr_sel,
	output id_shift_sel,
	output id_ext_top,
	output [1:0] id_regdst,
	output [1:0]id_cp0_out_sel,
	output id_cp0_in_sel,
	output status_shift_sel,
	output epc_sel,
	output id_of_ctrl,
	output [2:0]cp0_wen,
	output [31:0]cause_in,
	output [3:0] mdu_op_o
);
	wire [5:0] instr_op = id_instr[31:26];
	wire [5:0] instr_tail = id_instr[5:0];
	wire [4:0] instr_rs = id_instr[25:21];
	wire [4:0] instr_rt = id_instr[20:16];
	
	/*arithmetic and logic*/
	wire instr_ADD   = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_ADD);
	wire instr_ADDU  = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_ADDU);
	wire instr_SUB   = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_SUB);
	wire instr_SUBU  = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_SUBU);
	wire instr_CLO   = (instr_op == `OP_SPECIAL2 && instr_tail == `TAIL_CLO);
	wire instr_CLZ   = (instr_op == `OP_SPECIAL2 && instr_tail == `TAIL_CLZ);
	wire instr_AND	 = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_AND);	
	wire instr_ANDI	 = (instr_op == `OP_ANDI);
	wire instr_SLT	 = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_SLT);	
	wire instr_SLTI	 = (instr_op == `OP_SLTI);
	wire instr_OR	 = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_OR);	
	wire instr_ORI	 = (instr_op == `OP_ORI);
	wire instr_SLTU	 = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_SLTU);	
	wire instr_SLTIU = (instr_op == `OP_SLTIU);
	wire instr_NOR	 = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_NOR);	
	wire instr_XOR	 = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_XOR);	
	wire instr_XORI  = (instr_op == `OP_XORI);
	wire instr_LUI   = (instr_op == `OP_LUI);
	/*mdu*/
	wire instr_DIV   = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_DIV);
	wire instr_DIVU  = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_DIVU);
	wire instr_MUL   = (instr_op == `OP_SPECIAL2 && instr_tail == `TAIL_MUL);
	wire instr_MULT  = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_MULT);
	wire instr_MULTU = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_MULTU);
	wire instr_MFHI  = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_MFHI);
	wire instr_MFLO  = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_MFLO);
	wire instr_MTHI  = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_MTHI);
	wire instr_MTLO  = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_MTLO);
	wire instr_MOVN  = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_MOVN);
	wire instr_MOVZ  = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_MOVZ);
	/* Shift */
	wire instr_SLL   = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_SLL);
	wire instr_SLLV  = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_SLLV);
	wire instr_SRL   = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_SRL);
	wire instr_SRLV  = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_SRLV);
	wire instr_SRA   = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_SRA);
	wire instr_SRAV  = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_SRAV);
	/*jump and link*/
	wire instr_BGEZAL = (instr_op == `OP_REGIMM && instr_rt == `RT_BGEZAL);
	wire instr_BLTZAL = (instr_op == `OP_REGIMM && instr_rt == `RT_BLTZAL);
	wire instr_JAL    = (instr_op == `OP_JAL);
	wire instr_JALR   = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_JALR);
	/* load and store*/
	wire instr_LB	= (instr_op == `OP_LB);
	wire instr_LBU  = (instr_op == `OP_LBU);
	wire instr_LH   = (instr_op == `OP_LH);
	wire instr_LHU  = (instr_op == `OP_LHU);
	wire instr_LW   = (instr_op == `OP_LW);
	wire instr_SB   = (instr_op == `OP_SB);
	wire instr_SH   = (instr_op == `OP_SH);
	wire instr_SW   = (instr_op == `OP_SW);
	
	/* cp0*/
	wire instr_MTC0 = (instr_op  == `OP_COP0 || instr_rs == `RS_MT);
	wire instr_MFC0 = (instr_op  == `OP_COP0 || instr_rs == `RS_MF);
	wire instr_ERET = (instr_op  == `OP_COP0 || instr_tail == `TAIL_ERET);
	wire instr_SYSCALL = (instr_op  == `OP_SPECIAL || instr_tail == `TAIL_SYSCALL);
	/* instruction type */
	wire LOAD_instr = (instr_LB || instr_LBU || instr_LH || instr_LHU || instr_LW);
	wire DM_instr   = (instr_LB || instr_LBU || instr_LH || instr_LHU || instr_SB || instr_SH || instr_LH || instr_LW || instr_SW );
	wire MDU_instr   = (instr_DIV || instr_DIVU || instr_MUL || instr_MULT || instr_MULTU || instr_MFHI || instr_MFLO || instr_MTHI || instr_MTLO);
	wire I_Arithmetic_instr = (id_instr[31:29] == 3'b001);
	wire R_Arithmetic_instr = ((instr_op == `OP_SPECIAL && id_instr[5:3]==3'b100) || instr_SLT || instr_SLTU || instr_CLO  || instr_CLZ);
	wire Shift_instr = (instr_SLL || instr_SLLV || instr_SRA || instr_SRAV || instr_SRL || instr_SRLV);
	wire JumpLink_instr = (instr_JAL || instr_BGEZAL || instr_BLTZAL || instr_JALR);
	
	
	assign id_pc_sel = ((id_bpu_pc!=id_br_addr) && ((id_instr[31:26]==6'd0 && id_instr[5:0]==6'd8) ||
								(id_instr[31:26]==6'd1 && id_instr[20:17]==4'd0) ||
								id_instr[31:26]==6'd2 || id_instr[31:28]==4'd1 || instr_JAL)) ? 1'b1 : 1'b0;
	
	assign id_bpu_wen[1] = ((id_bpu_pc!=id_br_addr) && ((id_instr[31:26]==6'd0 && id_instr[5:0]==6'd8) ||
									(id_instr[31:26]==6'd1 && id_instr[20:17]==4'd0) || instr_JAL ||
									id_instr[31:26]==6'd2 || id_instr[31:28]==4'd1)) ? 1'b1 : 1'b0;
	
	assign id_bpu_wen[0] = ((id_bpu_pc!=id_br_addr) && ((id_instr[31:26]==6'd0 && id_instr[5:0]==6'd8) ||
									(id_instr[31:26]==6'd1 && id_instr[20:16]==5'd1 && !id_compare[2]) ||
									(id_instr[31:26]==6'd1 && id_instr[20:16]==5'd0 && id_compare[2]) ||
									id_instr[31:26]==6'd2 || 
									instr_JAL ||
									(id_instr[31:26]==6'd4 && id_compare[0]) ||
									(id_instr[31:26]==6'd5 && !id_compare[0]) ||
									(id_instr[31:26]==6'd6 && (id_compare[2] || id_compare[1])) ||
									(id_instr[31:26]==6'd7 && (!id_compare[2] && !id_compare[1])))) ? 1'b1 : 1'b0;
	
	assign selpc = (cu_intr==1'b1 || (status_out[1]==1'b1 && instr_SYSCALL)) ? 2'b10 :
						instr_ERET ? 2'b01 : 2'b00;
	
	assign id_dmen = DM_instr ? 1'b1 : 1'b0;
	
	assign id_regwr = ( R_Arithmetic_instr||
						Shift_instr ||
						I_Arithmetic_instr||
						LOAD_instr ||
						instr_MFC0 || instr_MFHI || instr_MFLO ||
						(instr_MOVZ && id_compare[3]) ||
						(instr_MOVN && !id_compare[3]) ||
						JumpLink_instr) ? 1'b1 : 1'b0;
	
	assign id_memtoreg = id_instr[31:26]==6'b100011 ? 1'b1 : 1'b0;
	
	assign id_memwr = id_instr[31:26]==6'b101011 ? 1'b1 : 1'b0;
	
	assign id_ex_result_sel = ((id_instr[31:26]==6'd0 && (id_instr[5:1]==5'b10101 || id_instr[5:3]==3'b100)) ||
										(id_instr[31:26]==6'b011100 && id_instr[5:1]==5'b10000) ||
										id_instr[31:29]==3'd1 ||
										id_instr[31:26]==6'b100011 ||
										id_instr[31:26]==6'b101011) ? 3'd1 :
										(id_instr[31:26]==6'b010000 && id_instr[25:21]==5'd0) ? 3'd2 :
										(instr_MOVN || instr_MOVZ) ? 3'd3 :
										MDU_instr ? 3'd4 : 
										JumpLink_instr ? 3'd5 : 3'd0;
	
	assign id_alu_b_sel = (id_instr[31:29]==3'd1 || id_instr[31:26]==6'b100011 || id_instr[31:26]==6'b101011) ? 1'b1 : 1'b0;
	
	assign id_alu_op = (instr_SUB || instr_SUBU) ? 4'b0001 :
						instr_CLZ ? 4'b0010 :
						instr_CLO ? 4'b0011 :
						(instr_AND || instr_ANDI) ? 4'b0100 :
						(instr_SLT || instr_SLTI) ? 4'b0101 :
						(instr_OR || instr_ORI) ? 4'b0110 :
						(instr_SLTU || instr_SLTIU) ? 4'b0111 :
						instr_NOR ? 4'b1000 :
						(instr_XOR || instr_XORI) ? 4'b1001 :
						instr_LUI ? 4'b1010 : 4'b0000;
	
	assign id_shift_op = (id_instr[31:26]==6'd0 && (id_instr[5:0]==6'd3 || id_instr[5:0]==6'd7 || id_instr[5:0]==6'd2 || id_instr[6:0]==7'd6)) ?
								((id_instr[5:0]==6'd3 || id_instr[5:0]==6'd7) ? 2'b10 : 2'b01) : 2'b00;
	
	assign id_bra_addr_sel = (id_instr[31:26]==6'd0 && id_instr[5:0]==6'd8) ? 2'b10 :
										(id_instr[31:26]==6'd2 || instr_JAL)? 2'b11 :
										((id_instr[31:26]==6'd1 && id_instr[20:16]==5'd0 && id_compare[2]) ||
											(id_instr[31:26]==6'd1 && id_instr[20:16]==5'd1 && !id_compare[2]) ||
											(id_instr[31:26]==6'd4 && id_compare[0]) ||
											(id_instr[31:26]==6'd5 && !id_compare[0]) ||
											(id_instr[31:26]==6'd6 && (id_compare[2] || id_compare[1])) ||
											(id_instr[31:26]==6'd7 && (!id_compare[2] && !id_compare[1]))) ? 2'b01 : 2'b00;
	
	assign id_shift_sel = (id_instr[31:26]==6'd0 && (id_instr[5:0]==6'd4 || id_instr[5:0]==6'd7 || id_instr[6:0]==7'd6)) ? 1'b1 : 1'b0;
	
	assign id_ext_top = (id_instr[31:28]==4'b0011 && !(id_instr[27] && id_instr[26])) ? 1'b1 : 1'b0;
	
	assign id_regdst = (id_instr[31:29]==3'd1 || id_instr[31:26]==6'h23 || (id_instr[31:26]==6'b010000 && id_instr[25:21]==5'd0)) ? 2'd0 : 
						(instr_JAL || instr_BGEZAL || instr_BLTZAL) ? 2'd2:	1'b1;
	
	assign id_cp0_out_sel = (id_instr[31:26]==6'b010000 && id_instr[25:21]==5'd0) ? (id_instr[15:11]==6'd13 && id_instr[2:0]==3'd0 ? 2'b01 :
										(id_instr[15:11]==6'd14 && id_instr[2:0]==3'd0 ? 2'b10 : 2'b00)) : 2'b00;

	assign id_cp0_in_sel = (cu_intr==1'b1 || (status_out[1]==1'b1 && instr_SYSCALL) || instr_ERET) ? 1'b1 : 1'b0;
	
	assign status_shift_sel = instr_ERET ? 1'b1 : 1'b0;
	
	assign epc_sel = (cu_intr==1'b1 && id_bpu_pc!=id_br_addr && ((id_instr[31:26]==6'd0 && id_instr[5:0]==6'd8) ||
								(id_instr[31:26]==6'd1 && id_instr[20:17]==4'd0) || id_instr[31:26]==6'd2 || id_instr[31:28]==4'd1)) ? 1'b1 : 1'b0;
	
	assign id_of_ctrl = ((id_instr[31:26]==6'h0 && (id_instr[5:0]==6'h20 || id_instr[5:0]==6'h2a || id_instr[5:0]==6'h22)) ||
								id_instr[31:26]==6'ha || id_instr[31:26]==6'h8) ? 1'b1 : 1'b0;
	
	assign cp0_wen = (cu_intr==1'b1 || (status_out[1]==1'b1 && instr_SYSCALL)) ? 3'b111 :
							((id_instr[31:26]==6'b010000 && id_instr[5:0]==6'b011000) ? 3'b110 :
							((id_instr[31:26]==6'b010000 && id_instr[25:21]==5'b00100) ? (id_instr[15:11]==5'd12 ? 3'b100 :
							(id_instr[15:11]==5'd13 ? 3'b010 : (id_instr[15:11]==5'd14 ? 3'b001 : 3'b000))) : 3'b000));
	
	assign cause_in = cu_intr==1'b1 ? 32'd0 : ((status_out[1]==1'b1 && instr_SYSCALL) ? 32'd1 : 32'd0);
	
	assign mdu_op_o = 	instr_DIV   ? 4'd1 :
						instr_DIVU  ? 4'd2 :
						instr_MUL   ? 4'd3 :
						instr_MULT  ? 4'd4 :
						instr_MULTU ? 4'd5 :
						instr_MFHI  ? 4'd6 :
						instr_MFLO  ? 4'd7 :
						instr_MTHI  ? 4'd8 :
						instr_MTLO  ? 4'd9 : 4'd0;
	assign mem_extsigned_o = (instr_LB || instr_LH) ? 1'b1 : 1'b0;
	assign mem_bytesel_o = (instr_LW || instr_SW) 	? 4'b1111 :
						   (instr_LH || instr_LHU || instr_SH)	? 4'b0011 : 
						   (instr_LB || instr_LBU || instr_SB) 	? 4'b0001 : 4'b0;
endmodule
