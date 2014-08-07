module pipeline_cpu(
	input clk,
	input reset,

	output [31:0] dphy_addr_o,
	output [31:0] iphy_addr_o,
	output [31:0] data_o,
	output        data_wr_o,
	output [1:0]  data_type_o,

	output        ibus_memory_en_o,
	input         ibus_memory_data_ready_i,
	input [31:0]  ibus_memory_data_i,
	output        dbus_memory_en_o,
	input [31:0]  dbus_memory_data_i,
	input         dbus_memory_data_ready_i,
	output        dbus_peripheral_en_o,
	input [31:0]  dbus_peripheral_data_i,
	input         dbus_peripheral_data_ready_i,
	output        icache_en_o,
	input         icache_data_ready_i,
	input [31:0]  icache_data_i,
	output        dcache_en_o,
	input         dcache_data_ready_i,
	input [31:0]  dcache_data_i,
	/* external intrrupts*/
	input  hw_interrupt0_i,
	input  hw_interrupt1_i,
	input  hw_interrupt2_i,
	input  hw_interrupt3_i,
	input  hw_interrupt4_i,
	input  hw_interrupt5_i
);


/**
 *  signals
 *
 */
	
 //////////////////////////Whole stage/////////////////////////////////
	/* MMU */
	wire [31:0] mmu_instruction_o,mmu_dm_data_o;
	wire mmu_cpu_pause_o;
	wire mmu_exception_addr_error_o,mmu_exception_tlb_refill_o;
	wire mmu_exception_tlb_mod_o,mmu_exception_tlb_invalid_o;
	wire mmu_exception_tlb_rw_o,mmu_exception_tlb_by_instr_o;
	wire [3:0] tlb_entryhi_match_index_o;
	wire tlb_entryhi_hit_o;
	wire [31:0] tlb_entryhi_o,tlb_entrylo0_o,tlb_entrylo1_o;
	wire tlb_entryhi_data_valid_o,tlb_entrylo0_data_valid_o,tlb_entrylo1_data_valid_o;
	wire [31:0] mmu_bad_vaddr_o;
	
	/* CU */
	wire pa_pc_ifid_o;
	wire wash_ifid_o;
	wire pa_idexmemwr_o;
	wire wash_idex_o;
	wire wash_exmem_o;
	wire wash_memwr_o;
	
	/* FU */
	wire[1:0] id_a_sel;
	wire[1:0] id_b_sel;
	
 //////////////////////////////////////////////////////////////////////
	wire[31:0] next_pc;
	wire[31:0] vector_base_addr;
///////////////////////////If stage////////////////////////////////////
	/*BPU*/
	wire[4:0]  if_bpu_index;
	wire[31:0] if_bpu_pc;
	
	wire[31:0] if_pc_out;
	wire[31:0] if_pc_4_out;
	wire[31:0] if_new_pc;
	
///////////////////////////////////////////////////////////////////////
	/*IFID Register*/
	wire[31:0] id_pc_4_out;
	wire[31:0] id_jaddr_out;
	wire[31:0] id_bpu_pc;
	wire[4:0]  id_bpu_index;
	wire[31:0] id_instr;
	wire[15:0] id_imm;
	wire[31:0] id_pc_out;
	wire[4:0]  id_shamt;
	wire[4:0]  id_rs_addr;
	wire[4:0]  id_rt_addr;
	wire[4:0]  id_rd_addr;
///////////////////////////id stage////////////////////////////////////

	/* ID */
	wire[31:0] id_br_addr;
	
	wire       id_pc_sel;
	wire       id_regwr;
	wire       id_dmen;
	wire       id_memtoreg;
	wire       id_memwr;
	wire[1:0]  id_dm_type_o;
	wire       id_dm_extsigned_o;
	wire       id_alu_b_sel;
	wire       id_shift_sel;
	wire       id_ext_top;
	wire[1:0]  id_regdst;
	wire[1:0]  epc_sel;
	wire       id_of_ctrl;
	wire[3:0]  id_alu_op;
	wire[3:0]  id_mdu_op;
	wire[1:0]  id_bpu_wen;
	wire[1:0]  id_bra_addr_sel;
	wire[2:0]  id_ex_result_sel;
	wire[1:0]  id_shift_op;
	wire[1:0]  selpc;
	wire        instr_ERET_o;
	wire        exception_syscall_o;
	wire        cp0_wen_o;
	wire[4:0]   cp0_addr_o;
	wire        instr_tlbp_o,instr_tlbr_o,instr_tlbwr_o,instr_tlbwi_o;
	
	/* CP0 */
	wire cp0_interrupt_o;
	wire [31:0] cp0_data_o;
	wire [31:0] cp0_epc_o;
	wire [31:0] cp0_config_o;
	wire [31:0] cp0_status_o;
	wire [31:0] cp0_random_o;
	wire [31:0] cp0_index_o;
	wire [31:0] cp0_entryhi_o;
	wire [31:0] cp0_entrylo0_o;
	wire [31:0] cp0_entrylo1_o;
	wire cp0_exception_tlb_o,cp0_exception_tlb_byinstr_o;
	
	/* GPRs */
	wire[31:0] id_rs_out;
	wire[31:0] id_rt_out;
	
	/*id_a,id_b sel out */
	wire[31:0] id_a;
	wire[31:0] id_b;

	/*branch adder*/
	wire[31:0] id_bra_imm;
	wire[31:0] 	id_bra_addr;
	/* other */
	wire[4:0] id_regdst_addr;
	wire[4:0] id_shift_amount;
	wire[31:0] id_imm_ext;
	wire[3:0]  id_compare;
	wire[31:0] epc_in;

///////////////////////////////////////////////////////////////////////
wire[3:0] 	ex_mdu_op;

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
wire[1:0] ex_dm_type_o;
wire ex_dm_extsigned_o;
wire		ex_memtoreg;
wire[4:0] 	ex_regdst_addr;
wire	ex_of_ctrl;
wire	ex_alu_of;
wire	ex_regwr;
wire	ex_memwr;
wire	ex_dmen;
///////////////////////////ex stage////////////////////////////////////
	wire[31:0] 	ex_result;
	/*MDU*/
	wire mdu_pipeline_stall;
///////////////////////////////////////////////////////////////////////
wire	mem_regwr;
wire	[4:0] mem_regdst_addr;
wire	mem_memtoreg;

wire[1:0] mem_dm_type_o;
wire mem_dm_extsigned_o;
wire dm_en_o,dm_wr_o;
wire[31:0] dm_adr_o,dm_dat_o;
wire[31:0] mem_result;
///////////////////////////mem stage////////////////////////////////////
wire [31:0] mem_pc_o;
wire[31:0]  mem_data;
///////////////////////////////////////////////////////////////////////

wire		wr_regwr;
wire[31:0]	wr_data;
wire[4:0] 	wr_regdst_addr;
///////////////////////////wr stage////////////////////////////////////

///////////////////////////////////////////////////////////////////////


wire[4:0] 	rs_l;

wire		id_bpu_wen_h;
wire	[31:0] const_4;
wire pause = mmu_cpu_pause_o | mdu_pipeline_stall;

wire	overflow = ex_of_ctrl & ex_alu_of;

Multi_4_32	id_br_addr_sel(
	.a(id_pc_4_out),
	.b(id_bra_addr),
	.c(id_rs_out),
	.d(id_jaddr_out),
	.sel(id_bra_addr_sel),
	.data(id_br_addr));


CU	b2v_inst18(
	.pause(pause),
	.id_instr(id_instr),
	.ex_memtoreg(ex_memtoreg),
	.id_bpu_wen_h(id_bpu_wen_h),
	.ex_regdst_addr(ex_regdst_addr),
	.pa_pc_ifid_o(pa_pc_ifid_o),
	.wash_ifid_o(wash_ifid_o),
	.pa_idexmemwr_o(pa_idexmemwr_o),
	.wash_idex_o(wash_idex_o),
	.wash_exmem_o(wash_exmem_o),
	.wash_memwr_o(wash_memwr_o),
	.cp0_interrupt_i(cp0_interrupt_o),
	.cp0_exception_tlb_i(cp0_exception_tlb_o),
	.cp0_exception_tlb_byinstr_i(cp0_exception_tlb_byinstr_o)
	);
	
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

MMU mmu(
	.clk_i(clk),
	.rst_i(reset),
	.ivirtual_addr_i(if_pc_out),
	.dvirtual_addr_i(dm_adr_o),
	//connected with cache and bus
	.dphy_addr_o(dphy_addr_o),
	.iphy_addr_o(iphy_addr_o),
	.data_o(data_o),
	.data_wr_o(data_wr_o),
	.data_type_o(data_type_o),
	//TLB instructions 
	.instr_tlbp_i(instr_tlbp_o),
	.instr_tlbr_i(instr_tlbr_o),
	.instr_tlbwr_i(instr_tlbwr_o),
	.instr_tlbwi_i(instr_tlbwi_o),
	//CP0 registers data input
	.cp0_entryhi_i(cp0_entryhi_o),
	.cp0_entrylo0_i(cp0_entrylo0_o),
	.cp0_entrylo1_i(cp0_entrylo1_o),
	.cp0_random_i(cp0_random_o),
	.cp0_status_i(cp0_status_o),
	.cp0_index_i(cp0_index_o),
	.cp0_config_i(cp0_config_o),
	
	//connected with BUS	
	.ibus_memory_en_o(ibus_memory_en_o),
	.ibus_memory_data_ready_i(ibus_memory_data_ready_i),
	.ibus_memory_data_i(ibus_memory_data_i),
	.dbus_memory_en_o(dbus_memory_en_o),
	.dbus_memory_data_ready_i(dbus_memory_data_ready_i),
	.dbus_memory_data_i(dbus_memory_data_i),
	.dbus_peripheral_en_o(dbus_peripheral_en_o),
	.dbus_peripheral_data_ready_i(dbus_peripheral_data_ready_i),
	.dbus_peripheral_data_i(dbus_peripheral_data_i),
	
	//connected with CACHE
	.icache_en_o(icache_en_o),
	.dcache_en_o(dcache_en_o),
	.icache_data_ready_i(icache_data_ready_i),
	.icache_data_i(icache_data_i),
	.dcache_data_ready_i(dcache_data_ready_i),
	.dcache_data_i(dcache_data_i),
	
	//connected with CPU core
	.dm_en_i(dm_en_o),
	.dm_data_i(dm_dat_o),
	.dm_wr_i(dm_wr_o),
	.dm_type_i(mem_dm_type_o),
	.dm_extsigned_i(mem_dm_extsigned_o),
	.dm_data_o(mmu_dm_data_o),
	
	.instruction_o(mmu_instruction_o), 
	.cpu_pause_o(mmu_cpu_pause_o), //**
	.exception_addr_error_o(mmu_exception_addr_error_o),
	.exception_tlb_refill_o(mmu_exception_tlb_refill_o),
	.exception_tlb_mod_o(mmu_exception_tlb_mod_o),
	.exception_tlb_invalid_o(mmu_exception_tlb_invalid_o),
	.exception_tlb_rw_o(mmu_exception_tlb_rw_o),
	.exception_tlb_by_instr_o(mmu_exception_tlb_by_instr_o),
	/* to CP0 registers */
	.tlb_entryhi_match_index_o(tlb_entryhi_match_index_o),
	.tlb_entryhi_hit_o(tlb_entryhi_hit_o),
	.tlb_entryhi_o(tlb_entryhi_o),
	.tlb_entrylo0_o(tlb_entrylo0_o),
	.tlb_entrylo1_o(tlb_entrylo1_o),
	.tlb_entryhi_data_valid_o(tlb_entryhi_data_valid_o),
	.tlb_entrylo0_data_valid_o(tlb_entrylo0_data_valid_o),
	.tlb_entrylo1_data_valid_o(tlb_entrylo1_data_valid_o),
	.bad_vaddr_o(mmu_bad_vaddr_o)
);





Adder	b2v_inst3(
	.a(const_4),
	.b(if_pc_out),
	.result(if_pc_4_out));




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
	.b(cp0_epc_o),
	.c(vector_base_addr),
	.sel(selpc),
	.data(next_pc));	
	
PC_register b2v_inst0(
	.clk(clk),
	.reset(reset),
	.pa_pc_ifid(pa_pc_ifid_o),
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
	.pa_pc_ifid(pa_pc_ifid_o),
	.wash_ifid(wash_ifid_o),
	.if_bpu_index(if_bpu_index),
	.if_bpu_pc(if_bpu_pc),
	.if_instr_out(mmu_instruction_o),
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
	.id_bpu_pc(id_bpu_pc),
	.id_br_addr(id_br_addr),
	.id_compare(id_compare),
	.id_instr(id_instr),
	.id_pc_sel(id_pc_sel),
	.id_regwr(id_regwr),
	.id_dmen(id_dmen),
	.id_memtoreg(id_memtoreg),
	.id_memwr(id_memwr),
	.id_dm_extsigned_o(id_dm_extsigned_o),
	.id_dm_type_o(id_dm_type_o),
	.id_alu_b_sel(id_alu_b_sel),
	.id_shift_sel(id_shift_sel),
	.id_ext_top(id_ext_top),
	.id_regdst(id_regdst),
	.epc_sel(epc_sel),
	.id_of_ctrl(id_of_ctrl),
	.id_alu_op(id_alu_op),
	.mdu_op_o(id_mdu_op),
	.id_bpu_wen(id_bpu_wen),
	.id_bra_addr_sel(id_bra_addr_sel),
	.id_ex_result_sel(id_ex_result_sel),
	.id_shift_op(id_shift_op),
	.selpc(selpc),
	.instr_ERET_o(instr_ERET_o),
	.exception_syscall_o(exception_syscall_o),
	.cp0_wen_o(cp0_wen_o),
	.cp0_addr_o(cp0_addr_o),
	.cp0_exception_tlb_i(cp0_exception_tlb_o),
	.cp0_exception_tlb_byinstr_i(cp0_exception_tlb_byinstr_o),
	.cp0_interrupt_i(cp0_interrupt_o),
	.instr_tlbp_o(instr_tlbp_o),
	.instr_tlbr_o(instr_tlbr_o),
	.instr_tlbwr_o(instr_tlbwr_o),
	.instr_tlbwi_o(instr_tlbwi_o)
	);

GPRs	b2v_inst11(
	.clk(clk),
	.wr_regwr(wr_regwr),
	.id_rs_addr(id_rs_addr),
	.id_rt_addr(id_rt_addr),
	.wr_data(wr_data),
	.wr_regdst_addr(wr_regdst_addr),
	.id_rs_out(id_rs_out),
	.id_rt_out(id_rt_out));
	
CP0	cp0(
	.clk(clk),
	.reset(reset),
	.cpu_pause_i(pause),
	.cp0_intrrupt_o(cp0_interrupt_o),
	.cp0_exception_tlb_o(cp0_exception_tlb_o),
	.cp0_exception_tlb_byinstr_o(cp0_exception_tlb_byinstr_o),
	.instr_ERET_i(instr_ERET_o),
	.cp0_wen_i(cp0_wen_o),
	.cp0_addr_i(cp0_addr_o),
	.cp0_data_i(id_b),
	.cp0_data_o(cp0_data_o),
	.cp0_epc_o(cp0_epc_o),
	.cp0_config_o(cp0_config_o),
	.cp0_status_o(cp0_status_o),
	.cp0_random_o(cp0_random_o),
	.cp0_index_o(cp0_index_o),
	.cp0_entryhi_o(cp0_entryhi_o),
	.cp0_entrylo0_o(cp0_entrylo0_o),
	.cp0_entrylo1_o(cp0_entrylo1_o),
	.cp0_epc_i(epc_in),
	.cp0_entryhi_i(tlb_entryhi_o),
	.cp0_entryhi_data_valid_i(tlb_entryhi_data_valid_o),
	.cp0_entrylo0_i(tlb_entrylo0_o),
	.cp0_entrylo0_data_valid_i(tlb_entrylo0_data_valid_o),
	.cp0_entrylo1_i(tlb_entrylo1_o),
	.cp0_entrylo1_data_valid_i(tlb_entrylo1_data_valid_o),
	.tlb_entryhi_match_index_i(tlb_entryhi_match_index_o),
	.tlb_entryhi_hit_i(tlb_entryhi_hit_o),
	.cp0_bad_vaddr_i(mmu_bad_vaddr_o),
	.exception_tlb_by_instr_i(mmu_exception_tlb_by_instr_o),
	.exception_addr_error_i(mmu_exception_addr_error_o),
	.exception_tlb_refill_i(mmu_exception_tlb_refill_o),
	.exception_tlb_mod_i(mmu_exception_tlb_mod_o),
	.exception_tlb_invalid_i(mmu_exception_tlb_invalid_o),
	.exception_tlb_rw_i(mmu_exception_tlb_rw_o),
	.exception_syscall_i(exception_syscall_o),
	.hw_interrupt0_i(hw_interrupt0_i),
	.hw_interrupt1_i(hw_interrupt1_i),
	.hw_interrupt2_i(hw_interrupt2_i),
	.hw_interrupt3_i(hw_interrupt3_i),
	.hw_interrupt4_i(hw_interrupt4_i),
	.hw_interrupt5_i(hw_interrupt5_i)
	);

	Multi_3_32	epc_in_selector(
	.sel(epc_sel),
	.a(if_pc_out),
	.b(if_new_pc),
	.c(mem_pc_o),
	.data(epc_in));

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
	.pa_idexmemwr(pa_idexmemwr_o),
	.wash_idex(wash_idex_o),
	.return_addr_i(id_pc_4_out),
	.id_pc_i(id_pc_out),
	.id_regwr(id_regwr),
	.id_memtoreg(id_memtoreg),
	.id_memwr(id_memwr),
	.id_dm_type_i(id_dm_type_o),
	.id_dm_extsigned_i(id_dm_extsigned_o),
	.id_alu_b_sel(id_alu_b_sel),
	.id_dmen(id_dmen),
	.id_of_ctrl(id_of_ctrl),
	.id_a(id_a),
	.id_alu_op(id_alu_op),
	.mdu_op_i(id_mdu_op),
	.id_b(id_b),
	.id_cp0_out(cp0_data_o),
	.id_ex_result_sel(id_ex_result_sel),
	.id_imm_ext(id_imm_ext),
	.id_regdst_addr(id_regdst_addr),
	.id_shift_amount(id_shift_amount),
	.id_shift_op(id_shift_op),
	.ex_regwr(ex_regwr),
	.ex_memtoreg(ex_memtoreg),
	.ex_memwr(ex_memwr),
	.ex_dmen(ex_dmen),
	.ex_dm_type_o(ex_dm_type_o),
	.ex_dm_extsigned_o(ex_dm_extsigned_o),
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
	.pa_idexmemwr(pa_idexmemwr_o),
	.wash_exmem_i(wash_exmem_o),
	.ex_pc_i(ex_pc),
	.ex_regwr(ex_regwr),
	.ex_memtoreg(ex_memtoreg),
	.ex_memwr(ex_memwr),
	.ex_dmen(ex_dmen),
	.ex_dm_type_i(ex_dm_type_o),
	.ex_dm_extsigned_i(ex_dm_extsigned_o),
	.ex_b(ex_b),
	.ex_regdst_addr(ex_regdst_addr),
	.ex_result(ex_result),
	.mem_pc_o(mem_pc_o),
	.mem_regwr(mem_regwr),
	.mem_memtoreg(mem_memtoreg),
	.mem_dmen(dm_en_o),
	.mem_memwr(dm_wr_o),
	.mem_dm_type_o(mem_dm_type_o),
	.mem_dm_extsigned_o(mem_dm_extsigned_o),
	.mem_result(mem_result),
	.mem_regdst_addr(mem_regdst_addr),
	.mem_rt(dm_dat_o));

//////////////////////////////Mem Stage///////////////////////////////////////
assign dm_adr_o = mem_result;
Multi_2_32	mem_data_selector(
	.sel(mem_memtoreg),
	.a(mem_result),
	.b(mmu_dm_data_o),
	.data(mem_data));
//////////////////////////////////////////////////////////////////////////////
MemWr_register	b2v_inst27(
	.clk(clk),
	.reset(reset),
	.pa_idexmemwr(pa_idexmemwr_o),
	.wash_memwr_i(wash_memwr_o),
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

