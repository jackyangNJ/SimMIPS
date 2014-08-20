`include "CPUConstants.v"
module ID(
	input [31:0] id_bpu_pc,
	input [31:0] id_instr,
	input [31:0] id_br_addr,
	input [3:0]  id_compare,
	output       id_pc_sel,
	output [1:0] id_bpu_wen,
	output [1:0] selpc,
	output       id_dmen,
	output       id_regwr,
	output       id_memtoreg,
	output       id_memwr,
	output [1:0] id_dm_type_o,
	output       id_dm_extsigned_o,
	output [2:0] id_ex_result_sel,
	output       id_alu_b_sel,
	output [3:0] id_alu_op,
	output [1:0] id_shift_op,
	output [1:0] id_bra_addr_sel,
	output       id_shift_sel,
	output       id_ext_top,
	output [1:0] id_regdst,
	output [1:0] epc_sel,
	output       id_of_ctrl,
	output [3:0] mdu_op_o,
	/* CP0 */
	input  cp0_interrupt_i,
	input  cp0_exception_tlb_i,
	input  cp0_exception_tlb_byinstr_i,
	output instr_ERET_o,
	output exception_syscall_o,
	//mtc0,mfc0
	output cp0_wen_o,
	output [4:0] cp0_addr_o,
	/* MMU */
	output instr_tlbp_o,
	output instr_tlbr_o,
	output instr_tlbwr_o,
	output instr_tlbwi_o,
	/* instruction propertiese*/
	output is_instr_branch_o
);
	wire [5:0] instr_op = id_instr[31:26];
	wire [5:0] instr_tail = id_instr[5:0];
	wire [4:0] instr_rs = id_instr[25:21];
	wire [4:0] instr_rt = id_instr[20:16];
	wire [4:0] instr_rd = id_instr[15:11];
	
	/*arithmetic and logic*/
	// wire instr_ADD   = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_ADD);
	// wire instr_ADDU  = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_ADDU);
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
	/*jump */
	wire instr_JR    = (instr_op == `OP_SPECIAL  && instr_tail == `TAIL_JR);
	wire instr_J     = (instr_op == `OP_J);
	wire instr_BGEZ  = (instr_op == `OP_REGIMM && instr_rt == `RT_BGEZ);
	wire instr_BLTZ  = (instr_op == `OP_REGIMM && instr_rt == `RT_BLTZ);
	wire instr_BNE   = (instr_op == `OP_BNE);
	wire instr_BEQ   = (instr_op == `OP_BEQ);
	wire instr_BGTZ  = (instr_op == `OP_BGTZ);
	wire instr_BLEZ  = (instr_op == `OP_BLEZ);
	
	
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
	/* tlb */
	wire instr_TLBP  = (instr_op == `OP_COP0 && instr_tail == `TAIL_TLBP);
	wire instr_TLBR  = (instr_op == `OP_COP0 && instr_tail == `TAIL_TLBR);
	wire instr_TLBWI = (instr_op == `OP_COP0 && instr_tail == `TAIL_TLBWI);
	wire instr_TLBWR = (instr_op == `OP_COP0 && instr_tail == `TAIL_TLBWR);
	/* cp0 instructions*/
	wire instr_MTC0    = (instr_op  == `OP_COP0 && instr_rs == `RS_MT && id_instr[2:0] == 3'b0);
	wire instr_MFC0    = (instr_op  == `OP_COP0 && instr_rs == `RS_MF && id_instr[2:0] == 3'b0);
	/* system instructions */
	wire instr_ERET    = (instr_op  == `OP_COP0 && instr_tail == `TAIL_ERET);
	wire instr_SYSCALL = (instr_op  == `OP_SPECIAL && instr_tail == `TAIL_SYSCALL);
	/* instruction type */
	
	wire Load_instr = (instr_LB || instr_LBU || instr_LH || instr_LHU || instr_LW);
	wire Store_instr = (instr_SB || instr_SH || instr_SW);
	wire LoadStore_instr   = (instr_LB || instr_LBU || instr_LH || instr_LHU || instr_SB || instr_SH || instr_LH || instr_LW || instr_SW );
	wire MDU_instr   = (instr_DIV || instr_DIVU || instr_MUL || instr_MULT || instr_MULTU || instr_MFHI || instr_MFLO || instr_MTHI || instr_MTLO);
	wire I_Arithmetic_instr = (id_instr[31:29] == 3'b001);  //I-type Arithmetic instructions
	wire R_Arithmetic_instr = ((instr_op == `OP_SPECIAL && id_instr[5:3]==3'b100) || instr_SLT || instr_SLTU || instr_CLO  || instr_CLZ);
	wire Shift_instr = (instr_SLL || instr_SLLV || instr_SRA || instr_SRAV || instr_SRL || instr_SRLV);
	wire JumpLink_instr = (instr_JAL || instr_BGEZAL || instr_BLTZAL || instr_JALR);
	wire Branch_instr = JumpLink_instr || instr_JR || instr_J || instr_BGEZ || instr_BLTZ || instr_BEQ || instr_BNE || instr_BGTZ || instr_BLEZ;
	
	assign id_pc_sel = ((id_bpu_pc!=id_br_addr) && Branch_instr) ? 1'b1 : 1'b0;
	
	assign id_bpu_wen[1] = ((id_bpu_pc!=id_br_addr) &&  Branch_instr) ? 1'b1 : 1'b0;
	
	assign id_bpu_wen[0] = ((id_bpu_pc!=id_br_addr) && 
									(instr_JR   || instr_JALR      ||
									(instr_BGEZ && !id_compare[2]) ||
									(instr_BLTZ && id_compare[2])  ||
									instr_J     || instr_JAL       ||
									(instr_BEQ && id_compare[0])   ||
									(instr_BNE && !id_compare[0])  ||
									(instr_BLEZ && (id_compare[2]  || id_compare[1])) ||
									(instr_BGTZ && (!id_compare[2] && !id_compare[1])))
							) ? 1'b1 : 1'b0;
	
	assign selpc = (cp0_interrupt_i || instr_SYSCALL || cp0_exception_tlb_i) ? 2'b10 :
										   instr_ERET ? 2'b01 : 2'b0;
	
	assign id_dmen = LoadStore_instr ? 1'b1 : 1'b0;
	
	assign id_regwr = ( R_Arithmetic_instr||
						Shift_instr ||
						instr_MUL ||
						I_Arithmetic_instr||
						Load_instr ||
						instr_MFC0 || instr_MFHI || instr_MFLO ||
						(instr_MOVZ && id_compare[3]) ||
						(instr_MOVN && !id_compare[3]) ||
						JumpLink_instr) ? 1'b1 : 1'b0;
	
	assign id_memtoreg = Load_instr ? 1'b1 : 1'b0;
	
	assign id_memwr = Store_instr ? 1'b1 : 1'b0;
	
	assign id_ex_result_sel = ((id_instr[31:26]==6'd0 && (id_instr[5:1]==5'b10101 || id_instr[5:3]==3'b100)) ||
										instr_CLO || instr_CLZ ||
										I_Arithmetic_instr ||
										LoadStore_instr) ? 3'd1 :
										instr_MFC0 ? 3'd2 :
										(instr_MOVN || instr_MOVZ) ? 3'd3 :
										MDU_instr ? 3'd4 : 
										JumpLink_instr ? 3'd5 : 3'd0;

	assign id_alu_b_sel = (I_Arithmetic_instr || LoadStore_instr) ? 1'b1 : 1'b0;
	
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
	
	assign id_bra_addr_sel = (instr_JR || instr_JALR) ? 2'b10 :
								(instr_J || instr_JAL)? 2'b11 :
								(((instr_BLTZ || instr_BGEZAL) && id_compare[2]) ||
									((instr_BGEZ || instr_BGEZAL) && !id_compare[2]) ||
									(instr_BEQ && id_compare[0]) ||
									(instr_BNE && !id_compare[0]) ||
									(instr_BLEZ && (id_compare[2] || id_compare[1])) ||
									(instr_BGTZ && (!id_compare[2] && !id_compare[1]))) ? 2'b01 : 2'b00;

	assign id_shift_sel = (id_instr[31:26]==6'd0 && (id_instr[5:0]==6'd4 || id_instr[5:0]==6'd7 || id_instr[6:0]==7'd6)) ? 1'b1 : 1'b0;

	assign id_ext_top = (id_instr[31:28]==4'b0011 && !(id_instr[27] && id_instr[26])) ? 1'b1 : 1'b0;
	
	assign id_regdst = (I_Arithmetic_instr || Load_instr || instr_MFC0) ? 2'd0 : 
						(instr_JAL || instr_BGEZAL || instr_BLTZAL) ? 2'd2: 2'd1;
	
	assign epc_sel = (cp0_interrupt_i && id_bpu_pc!=id_br_addr && Branch_instr) ? 2'b01 : 
						(cp0_exception_tlb_i && !cp0_exception_tlb_byinstr_i) ? 2'b10:2'b0;
	
	assign id_of_ctrl = ((id_instr[31:26]==6'h0 && (id_instr[5:0]==6'h20 || id_instr[5:0]==6'h2a || id_instr[5:0]==6'h22)) ||
								id_instr[31:26]==6'ha || id_instr[31:26]==6'h8) ? 1'b1 : 1'b0;


	assign mdu_op_o = 	instr_DIV   ? 4'd1 :
						instr_DIVU  ? 4'd2 :
						instr_MUL   ? 4'd3 :
						instr_MULT  ? 4'd4 :
						instr_MULTU ? 4'd5 :
						instr_MFHI  ? 4'd6 :
						instr_MFLO  ? 4'd7 :
						instr_MTHI  ? 4'd8 :
						instr_MTLO  ? 4'd9 : 4'd0;
	assign id_dm_extsigned_o = (instr_LB || instr_LH) ? 1'b1 : 1'b0;
	assign id_dm_type_o = (instr_LW || instr_SW) ? 2'b11 :
						   (instr_LH || instr_LHU || instr_SH) ? 2'b10 : 
						   (instr_LB || instr_LBU || instr_SB) ? 2'b01 : 2'b0;
	
	assign instr_ERET_o = instr_ERET;
	assign exception_syscall_o = instr_SYSCALL;
	
	//mtc0,mfc0
	assign cp0_wen_o = instr_MTC0 ? 1'b1 : 1'b0;
	assign cp0_addr_o = instr_rd;
	/* CP0 */
	//MMU
	assign instr_tlbp_o  = instr_TLBP;
	assign instr_tlbr_o  = instr_TLBR;
	assign instr_tlbwr_o = instr_TLBWR;
	assign instr_tlbwi_o = instr_TLBWI;

	/* instruction properties */
	assign is_instr_branch_o = Branch_instr;
endmodule


