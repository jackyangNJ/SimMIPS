module pipeline_cpu(
	ext_pause,
	intr,
	clk,
	reset,
	dm_dat_o,
	im_dat_i,
	dm_bytesel_o,
	dm_extsigned_o,
	dm_en_o,
	dm_wr_o,
	overflow,
	dm_adr_o,
	dm_dat_i,
	im_adr_o
);


input wire	ext_pause;
input wire	intr;
input wire	clk;
input wire	reset;
output wire	[31:0] dm_dat_o;
input wire	[31:0] im_dat_i;
output wire [3:0] dm_bytesel_o;
output wire dm_extsigned_o;
output wire	dm_en_o;
output wire	dm_wr_o;
output wire	overflow;
output wire	[31:0] dm_adr_o;
input wire	[31:0] dm_dat_i;
output wire	[31:0] im_adr_o;

/**
 *  signals
 *
 */
///////////////////////////if stage////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////id stage////////////////////////////////////
wire[3:0] 	id_compare;
wire[3:0] 	id_mdu_op;
wire		id_regwr;
wire		id_memtoreg;
wire		id_memwr;
wire		id_alu_b_sel;
wire		id_dmen;
wire		id_of_ctrl;
wire[1:0] 	id_shift_op;
wire[3:0] 	id_alu_op;
wire		epc_sel;
wire[2:0]	id_ex_result_sel;
wire[1:0] 	id_bpu_wen;
wire		id_ext_top;
wire		id_pc_sel;
wire		id_shift_sel;
wire[1:0] 	id_a_sel;
wire[31:0] 	id_rt_out;
wire[1:0] 	id_b_sel;
wire[31:0] 	id_a;
wire[31:0] 	id_b;
wire[1:0]	id_regdst;
wire[4:0] 	id_rd_addr;
wire		id_cp0_in_sel;
wire		status_shift_sel;
wire[31:0] 	id_bpu_pc;
wire[31:0] 	id_br_addr;
///////////////////////////////////////////////////////////////////////
///////////////////////////ex stage////////////////////////////////////
//MDU signals
wire[3:0] 	ex_mdu_op;
wire 		mdu_pipeline_stall;
wire[31:0] 	ex_mdu_data;
wire[31:0] 	ex_b;
wire[4:0] 	ex_shift_amount;
wire[1:0] 	ex_shift_op;
wire[31:0] 	ex_a;
wire[31:0] 	ex_alu_b;
wire[3:0] 	ex_alu_op;
wire		ex_alu_b_sel;
wire[31:0] 	ex_imm_ext;
wire[31:0] 	ex_bs_out;
wire[31:0] 	ex_alu_out;
wire[31:0] 	ex_cp0_out;
wire[2:0] 	ex_result_sel;
wire[31:0]	ex_return_addr;
wire[31:0]  ex_pc;
///////////////////////////////////////////////////////////////////////
///////////////////////////mem stage////////////////////////////////////
wire [31:0] mem_pc;
///////////////////////////////////////////////////////////////////////
///////////////////////////wr stage////////////////////////////////////

///////////////////////////////////////////////////////////////////////
wire		cu_intr;


wire[31:0] 	id_instr;
wire[31:0] 	cp0_reg_status;
wire		pa_pc_ifid;
wire[31:0] 	next_pc;
wire[31:0] 	if_new_pc;
wire[31:0] 	cp0_epc_out;
wire[31:0] 	vector_base_addr;
wire[1:0] 	selpc;
wire[31:0] 	id_pc_4_out;
wire[31:0] 	id_bra_addr;
wire[31:0] 	id_rs_out;
wire[31:0] 	id_jaddr_out;
wire[1:0] 	id_bra_addr_sel;
wire		wr_regwr;
wire[4:0] 	rs_l;
wire[4:0] 	id_rt_addr;
wire[31:0]	wr_data;
wire[4:0] 	wr_regdst_addr;
wire[31:0] 	ex_result;
wire[31:0] 	mem_data;

wire[31:0]	cp0_cause_in;
wire[2:0] 	cp0_wen;
wire[31:0] 	epc_in;
wire[1:0] 	id_cp0_out_sel;
wire		ex_memtoreg;
wire		id_bpu_wen_h;
wire[4:0] 	ex_regdst_addr;
wire		pa_idexmemwr;
wire		wash_idex;


wire	[31:0] id_cp0_out;
wire	[31:0] id_imm_ext;
wire	[4:0] id_regdst_addr;
wire	[4:0] id_shift_amount;
wire	[31:0] if_pc_out;

wire	ex_of_ctrl;
wire	ex_alu_of;
wire	ex_regwr;
wire	ex_memwr;
wire	ex_dmen;
wire	mem_regwr;
wire	[4:0] mem_regdst_addr;
wire	mem_memtoreg;
wire	[31:0] mem_result;
wire	[31:0] const_4;
wire	[15:0] id_imm;
wire	[4:0] id_bpu_index;
wire	[31:0] if_pc_4_out;
wire	wash_ifid;
wire	[4:0] if_bpu_index;
wire	[31:0] if_bpu_pc;
wire	[31:0] id_pc_out;
wire	[31:0] id_bra_imm;
wire	[4:0] id_shamt;
wire	[4:0] id_rs_addr;

wire pause = ext_pause | mdu_pipeline_stall;
assign	dm_adr_o = mem_result;
assign	im_adr_o = if_pc_out;
assign	overflow = ex_of_ctrl & ex_alu_of;





Multi_4_32	id_br_addr_sel(
	.a(id_pc_4_out),
	.b(id_bra_addr),
	.c(id_rs_out),
	.d(id_jaddr_out),
	.sel(id_bra_addr_sel),
	.data(id_br_addr));


GPRs	b2v_inst11(
	.clk(clk),
	.wr_regwr(wr_regwr),
	.id_rs_addr(id_rs_addr),
	.id_rt_addr(id_rt_addr),
	.wr_data(wr_data),
	.wr_regdst_addr(wr_regdst_addr),
	.id_rs_out(id_rs_out),
	.id_rt_out(id_rt_out));
	



CP0	b2v_inst17(
	.clk(clk),
	.reset(reset),
	.pause(pause),
	.id_cp0_in_sel(id_cp0_in_sel),
	.status_shift_sel(status_shift_sel),
	.cause_in(cp0_cause_in),
	.cp0_wen(cp0_wen),
	.epc_in(epc_in),
	.id_b(id_b),
	.id_cp0_out_sel(id_cp0_out_sel),
	.epc_out(cp0_epc_out),
	.id_cp0_out(id_cp0_out),
	.status_out(cp0_reg_status));


CU	b2v_inst18(
	.pause(pause),
	.intr(intr),
	.ex_memtoreg(ex_memtoreg),
	.id_bpu_wen_h(id_bpu_wen_h),
	.ex_regdst_addr(ex_regdst_addr),
	.id_instr(id_instr),
	.status_out(cp0_reg_status),
	.pa_pc_ifid(pa_pc_ifid),
	.wash_ifid(wash_ifid),
	.pa_idexmemwr(pa_idexmemwr),
	.wash_idex(wash_idex),
	.cu_intr(cu_intr));





Multi_2_32	epc_in_selector(
	.sel(epc_sel),
	.a(if_pc_out),
	.b(if_new_pc),
	.data(epc_in));








Multi_2_32	b2v_inst29(
	.sel(mem_memtoreg),
	.a(mem_result),
	.b(dm_dat_i),
	.data(mem_data));


Adder	b2v_inst3(
	.a(const_4),
	.b(if_pc_out),
	.result(if_pc_4_out));


FU	b2v_inst30(
	.ex_regwr(ex_regwr),
	.mem_regwr(mem_regwr),
	.wr_regwr(wr_regwr),
	.ex_regdst_addr(ex_regdst_addr),
	.id_instr(id_instr),
	.mem_regdst_addr(mem_regdst_addr),
	.wr_regdst_addr(wr_regdst_addr),
	.id_a_sel(id_a_sel),
	.id_b_sel(id_b_sel));


const_4	b2v_inst31(
	.num(const_4));


const_base	b2v_inst32(
	.base(vector_base_addr));


Section_bpu_wen	b2v_inst33(
	.id_bpu_wen(id_bpu_wen),
	.id_bpu_wen_h(id_bpu_wen_h));


Section_rs	b2v_inst34(
	.id_rs_out(id_rs_out),
	.rs_l(rs_l));



	
Multi_3_32	next_pc_sel(
	.a(if_new_pc),
	.b(cp0_epc_out),
	.c(vector_base_addr),
	.sel(selpc),
	.data(next_pc));	
	
PC_register	b2v_inst0(
	.clk(clk),
	.reset(reset),
	.pa_pc_ifid(pa_pc_ifid),
	.next_pc(next_pc),
	.if_pc_out(if_pc_out));

///////////////////////////////IF stage////////////////////////////////////
Multi_2_32	if_new_pc_selector(
	.sel(id_pc_sel),
	.a(if_bpu_pc),
	.b(id_br_addr),
	.data(if_new_pc));
	
BPU	bpu_inst(
	.clk(clk),
	.reset(reset),
	.id_bpu_index(id_bpu_index),
	.id_bpu_wen(id_bpu_wen),
	.id_pc_4_out(id_pc_4_out),
	.if_new_pc(if_new_pc),
	.if_pc_4_out(if_pc_4_out),
	.if_bpu_index(if_bpu_index),
	.if_bpu_pc(if_bpu_pc));
///////////////////////////////////////////////////////////////////////////
IFID_register	ifid_regs(
	.clk(clk),
	.reset(reset),
	.pa_pc_ifid(pa_pc_ifid),
	.wash_ifid(wash_ifid),
	.if_bpu_index(if_bpu_index),
	.if_bpu_pc(if_bpu_pc),
	.if_instr_out(im_dat_i),
	.if_pc_4_out(if_pc_4_out),
	.if_pc_out(if_pc_out),
	.id_bpu_index(id_bpu_index),
	.id_bpu_pc(id_bpu_pc),
	.id_imm(id_imm),
	.id_instr(id_instr),
	.id_jaddr_out(id_jaddr_out),
	.id_pc_4_out(id_pc_4_out),
	.id_pc_out(id_pc_out),
	.id_rd_addr(id_rd_addr),
	.id_rs_addr(id_rs_addr),
	.id_rt_addr(id_rt_addr),
	.id_shamt(id_shamt));
///////////////////////////////ID stage////////////////////////////////////
Compare	b2v_inst14(
	.id_a(id_a),
	.id_b(id_b),
	.id_compare(id_compare));

ID	instr_decode(
	.cu_intr(cu_intr),
	.id_bpu_pc(id_bpu_pc),
	.id_br_addr(id_br_addr),
	.id_compare(id_compare),
	.id_instr(id_instr),
	.status_out(cp0_reg_status),
	.id_pc_sel(id_pc_sel),
	.id_dmen(id_dmen),
	.id_regwr(id_regwr),
	.id_memtoreg(id_memtoreg),
	.id_memwr(id_memwr),
	.id_alu_b_sel(id_alu_b_sel),
	.id_shift_sel(id_shift_sel),
	.id_ext_top(id_ext_top),
	.id_regdst(id_regdst),
	.id_cp0_in_sel(id_cp0_in_sel),
	.status_shift_sel(status_shift_sel),
	.epc_sel(epc_sel),
	.id_of_ctrl(id_of_ctrl),
	.cause_in(cp0_cause_in),
	.cp0_wen(cp0_wen),
	.id_alu_op(id_alu_op),
	.mdu_op_o(id_mdu_op),
	.id_bpu_wen(id_bpu_wen),
	.id_bra_addr_sel(id_bra_addr_sel),
	.id_cp0_out_sel(id_cp0_out_sel),
	.id_ex_result_sel(id_ex_result_sel),
	.id_shift_op(id_shift_op),
	.selpc(selpc),
	.mem_extsigned_o(dm_extsigned_o),
	.mem_bytesel_o(dm_bytesel_o)	
	);

Multi_4_32	id_a_selector(
	.a(id_rs_out),
	.b(ex_result),
	.c(mem_data),
	.d(wr_data),
	.sel(id_a_sel),
	.data(id_a));


Multi_4_32	id_b_selector(
	.a(id_rt_out),
	.b(ex_result),
	.c(mem_data),
	.d(wr_data),
	.sel(id_b_sel),
	.data(id_b));

Multi_3_5	id_regdst_addr_sel(
	.sel(id_regdst),
	.a(id_rt_addr),
	.b(id_rd_addr),
	.c(5'd31),
	.data(id_regdst_addr));
	
Imm_Ext	b2v_inst35(
	.id_ext_top(id_ext_top),
	.id_imm(id_imm),
	.id_imm_ext(id_imm_ext));
	
///////////////////////////////////////////////////////////////////////////
IDEx_register	b2v_inst19(
	.clk(clk),
	.reset(reset),
	.pa_idexmemwr(pa_idexmemwr),
	.wash_idex(wash_idex),
	.return_addr_i(id_pc_4_out),
	.id_pc_i(if_pc_out),
	.id_regwr(id_regwr),
	.id_memtoreg(id_memtoreg),
	.id_memwr(id_memwr),
	.id_alu_b_sel(id_alu_b_sel),
	.id_dmen(id_dmen),
	.id_of_ctrl(id_of_ctrl),
	.id_a(id_a),
	.id_alu_op(id_alu_op),
	.mdu_op_i(id_mdu_op),
	.id_b(id_b),
	.id_cp0_out(id_cp0_out),
	.id_ex_result_sel(id_ex_result_sel),
	.id_imm_ext(id_imm_ext),
	.id_regdst_addr(id_regdst_addr),
	.id_shift_amount(id_shift_amount),
	.id_shift_op(id_shift_op),
	.ex_regwr(ex_regwr),
	.ex_memtoreg(ex_memtoreg),
	.ex_memwr(ex_memwr),
	.ex_dmen(ex_dmen),
	.ex_of_ctrl(ex_of_ctrl),
	.ex_alu_b_sel(ex_alu_b_sel),
	.ex_a(ex_a),
	.ex_alu_op(ex_alu_op),
	.mdu_op_o(ex_mdu_op),
	.ex_b(ex_b),
	.ex_cp0_out(ex_cp0_out),
	.ex_imm_ext(ex_imm_ext),
	.ex_regdst_addr(ex_regdst_addr),
	.ex_result_sel(ex_result_sel),
	.ex_shift_amount(ex_shift_amount),
	.return_addr_o(ex_return_addr),
	.ex_shift_op(ex_shift_op),
	.ex_pc_o(ex_pc)
	);
	
///////////////////////////////Ex stage////////////////////////////////////
Multi_2_32	ex_alu_b_selector(
	.sel(ex_alu_b_sel),
	.a(ex_b),
	.b(ex_imm_ext),
	.data(ex_alu_b));
	
ALU	alu_inst(
	.ex_a(ex_a),
	.ex_alu_b(ex_alu_b),
	.ex_alu_op(ex_alu_op),
	.ex_alu_of(ex_alu_of),
	.ex_alu_out(ex_alu_out));
	
MDU mdu_inst(
	.clk_i(clk),
	.rst_i(reset),
	.mdu_op_i(ex_mdu_op),
	.mdu_a_i(ex_a),
	.mdu_b_i(ex_b),
	.mdu_data_o(ex_mdu_data),
	.mdu_pipeline_stall_o(mdu_pipeline_stall)
);

BarSH	ex_bs_out_sel(
	.ex_b(ex_b),
	.ex_shift_amount(ex_shift_amount),
	.ex_shift_op(ex_shift_op),
	.ex_bs_out(ex_bs_out));

Multi_6_32	ex_result_selector(
	.a(ex_bs_out),
	.b(ex_alu_out),
	.c(ex_cp0_out),
	.d(ex_a),
	.e(ex_mdu_data),
	.f(ex_return_addr),
	.sel(ex_result_sel),
	.data(ex_result));
	
	
///////////////////////////////////////////////////////////////////////////
ExMem_register	b2v_inst26(
	.clk(clk),
	.reset(reset),
	.pa_idexmemwr(pa_idexmemwr),
	.ex_pc_i(ex_pc),
	.ex_regwr(ex_regwr),
	.ex_memtoreg(ex_memtoreg),
	.ex_memwr(ex_memwr),
	.ex_dmen(ex_dmen),
	.ex_b(ex_b),
	.ex_regdst_addr(ex_regdst_addr),
	.ex_result(ex_result),
	.mem_pc_o(mem_pc),
	.mem_regwr(mem_regwr),
	.mem_dmen(dm_en_o),
	.mem_memtoreg(mem_memtoreg),
	.mem_memwr(dm_wr_o),
	.mem_regdst_addr(mem_regdst_addr),
	.mem_result(mem_result),
	.mem_rt(dm_dat_o));

//////////////////////////////Mem Stage///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
MemWr_register	b2v_inst27(
	.clk(clk),
	.reset(reset),
	.pa_idexmemwr(pa_idexmemwr),
	.mem_regwr(mem_regwr),
	.mem_data(mem_data),
	.mem_regdst_addr(mem_regdst_addr),
	.wr_regwr(wr_regwr),
	.wr_data(wr_data),
	.wr_regdst_addr(wr_regdst_addr));

//////////////////////////////Wr Stage///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////






Ext_Branch	b2v_inst7(
	.id_imm(id_imm),
	.id_bra_imm(id_bra_imm));


Adder	id_bra_addr_adder(
	.a(id_pc_out),
	.b(id_bra_imm),
	.result(id_bra_addr));


Multi_2_5	id_shift_amount_sel(
	.sel(id_shift_sel),
	.a(id_shamt),
	.b(rs_l),
	.data(id_shift_amount));


endmodule
