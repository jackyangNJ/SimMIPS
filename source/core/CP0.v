`include "CPUConstants.v"
module CP0(
	clk,
	reset,
	input [2:0]cp0_wen,
	input [31:0]id_b,
	input id_cp0_in_sel,
	input status_shift_sel,
	input [31:0]cause_in,
	input [31:0]epc_in,
	input [1:0]id_cp0_out_sel,
	output [31:0]id_cp0_out,
	output [31:0]status_out,
	output [31:0]epc_out,
	
	//normal r/w interface
	cp0_wen_i,
	cp0_addr_i,
	cp0_data_i,
	cp0_data_o,
	
	cp0_epc_o,
	cp0_status_o,
	cp0_config_o,
	cp0_cause_o,
	cp0_random_o,
	cp0_index_o,
	cp0_entryhi_o,
	cp0_entrylo0_o,
	cp0_entrylo1_o,
	
	cp0_status_i,
	cp0_status_wen_i,
	cp0_status_i,
	cp0_epc_i,
	cp0_epc_wen_i,
	cp0_entryhi_i,
	cp0_entryhi_wen_i.
	cp0_entrylo0_i,
	cp0_entrylo0_wen_i,
	cp0_entrylo1_i,
	cp0_entrylo1_wen_i,
	
	exception_addr_error_i,
	exception_tlb_refill_i,
	exception_tlb_mod_i,
	exception_tlb_invalid_i,
	exception_tlb_rw_i,
	hw_interrupt0_i,
	hw_interrupt1_i,
	hw_interrupt2_i,
	hw_interrupt3_i,
	hw_interrupt4_i,
	hw_interrupt5_i,
	
	cpu_pause_i,
	instruction_i,
	
	
);
input clk,reset,cpu_pause_i;
//normal cp0 registers r/w
input cp0_wen_i;
input [4:0]cp0_addr_i;
input [31:0] cp0_data_i;
output [31:0] cp0_data_o;
//cp0 register input
input cp0_status_wen_i,cp0_epc_wen_i,cp0_entryhi_wen_i,cp0_entrylo0_wen_i,cp0_entrylo1_wen_i;
input [31:0] cp0_status_i

/* Constants */
	/* instruction types */
	wire [5:0] instr_op = instruction_i[31:26];
	wire [5:0] instr_tail = instruction_i[5:0];
	wire [4:0] instr_rs = instruction_i[25:21];
	wire [4:0] instr_rt = instruction_i[20:16];
	wire instr_MTC0 = (instr_op  == `OP_COP0 || instr_rs == `RS_MT);
	wire instr_MFC0 = (instr_op  == `OP_COP0 || instr_rs == `RS_MF);
	wire instr_ERET = (instr_op  == `OP_COP0 || instr_tail == `TAIL_ERET);
	wire instr_SYSCALL = (instr_op  == `OP_SPECIAL || instr_tail == `TAIL_SYSCALL);
	
	/* interrupts occur */
	wire intr_occur = (hw_interrupt0_i || hw_interrupt1_i ||	hw_interrupt2_i || hw_interrupt3_i || hw_interrupt4_i || hw_interrupt5_i) && (!cp0_status_exl) && cp0_status_ie;
	/* exception occur*/
	wire exc_tlb_occur = exception_addr_error_i || exception_tlb_invalid_i || exception_tlb_mod_i || exception_tlb_refill_i;
	wire exc_occur = intr_occur || instr_SYSCALL || exc_tlb_occur;
/* CP0 Registers */
	// reg [31:0]status;
	// reg [31:0]cause;
	// reg [31:0]epc;
	reg [31:0] cp0_epc;
	// CP0 Index
	reg cp0_index_p;
	reg [3:0] cp0_index_index;
	// CP0 Random
	reg [3:0] cp0_random;
	// cp0 Wired
	reg [3:0] cp0_wired;
	// CP0  EntryLo0,EntryLo1,Entryhi
	reg [25:0]cp0_entrylo0;
	reg [25:0]cp0_entrylo1;
	reg [18:0] cp0_entryhi_vpn2;
	reg [7:0] cp0_entryhi_asid;
	//CP0 Status
	reg cp0_status_ie,cp0_status_exl,cp0_status_um;
	reg [5:0] cp0_status_im;
	//CP0 Cause
	reg [5:0] cp0_cause_ip;
	reg [4:0] cp0_cause_exc_code;
	
	
	
	/* CP0 Index */
	always@(posedge clk)
	begin
		if(!cpu_pause_i)
			begin
				if(tlb_probe_faled)
					cp0_index_p <= 1'b1;
				else
					cp0_index_p <= 1'b0;
				if(cp0_wen_i && cp0_addr_i ==`CP0_INDEX_NUM)
						cp0_index_index <= cp0_data_i[3:0];
			end
	end
	/* CP0 Random */
	always@(posedge clk)
	begin
		if(reset)
			cp0_random <= 4'd15;
		else
			begin
				if(cp0_random == 4'd15)
					cp0_random <= cp0_wired;
				else
					cp0_random <= cp0_random + 1'b1;
			end
	end
	
	// CP0 Wired
	always@(posedge clk)
	begin
		if(reset)
			cp0_wired <= 0;
		else
			if(!cpu_pause_i)
				begin
					if(cp0_wen_i && cp0_addr_i == `CP0_WIRED_NUM)
						cp0_wired <= cp0_data_i[3:0];
				end
	end

	//CP0 Entryhi,Entrylo0 and EntryLo1
	always @ (posedge clk) 
	begin
		if(!cpu_pause_i)
			begin
				//entrylo0
				if(cp0_wen_i && cp0_addr_i == `CP0_ENTRYLO0_ADDR)
					cp0_entrylo0 <= cp0_data_i[25:0];
				else
					if(cp0_entrylo0_wen_i)
						cp0_entrylo0 <= cp0_entrylo0_i[25:0];
				//entrylo1		
				if(cp0_wen_i && cp0_addr_i == `CP0_ENTRYLO1_ADDR)
					cp0_entrylo1 <= cp0_data_i[25:0];
				else
					if(cp0_entrylo1_wen_i)
						cp0_entrylo1 <= cp0_entrylo0_i[25:0];
				//entryhi
				if(cp0_wen_i && cp0_addr_i == `CP0_ENTRYHI_ADDR)
					{cp0_entryhi_vpn2,cp0_entryhi_asid} <= {cp0_data_i[31:13],cp0_data_i[7:0]};
				else
					if(cp0_entryhi_wen_i)
						{cp0_entryhi_vpn2,cp0_entryhi_asid} <= {cp0_entryhi_i[31:13],cp0_entryhi_i[7:0]};	
			end
	end
	
	//CP0 Status
	always @ (posedge clk) 
	begin
		if(!cpu_pause_i)
			begin
				if(cp0_wen_i && cp0_addr_i == `CP0_STATUS_ADDR)
					{cp0_status_im,cp0_status_um,cp0_status_exl,cp0_status_ie} <=
										{cp0_data_i[15:10],cp0_data_i[4],cp0_data_i[1:0]};
				else
					begin
						if(exc_occur)
							cp0_status_exl <= 1'b1;
						else
							if(instr_ERET)
								cp0_status_exl <= 0;
					end
			end
	end
	
	//CP0 Cause
	always @ (posedge clk) 
	begin
		if(!cpu_pause_i)
			begin
				if(cp0_wen_i && cp0_addr_i == `CP0_CAUSE_ADDR)
					{cp0_cause_ip,cp0_cause_exc_code} <= {cp0_data_i[15:10],cp0_data_i[6:2]};
				else
					begin
						case({intr_occur,exception_addr_error_i,exception_tlb_mod_i,exception_tlb_refill_i,exception_tlb_invalid_i,instr_SYSCALL})
							/* interrupts */
							6'b1xxxxx:
								begin
									cp0_cause_ip[5] <= hw_interrupt5_i && cp0_status_im[5];
									cp0_cause_ip[4] <= hw_interrupt4_i && cp0_status_im[4];
									cp0_cause_ip[3] <= hw_interrupt3_i && cp0_status_im[3];
									cp0_cause_ip[2] <= hw_interrupt2_i && cp0_status_im[2];
									cp0_cause_ip[1] <= hw_interrupt1_i && cp0_status_im[1];
									cp0_cause_ip[0] <= hw_interrupt0_i && cp0_status_im[0];
								end										
							6'b01xxxx:
								if(exception_tlb_rw_i)
									cp0_cause_exc_code <= `EXC_AdES;
								else	
									cp0_cause_exc_code <= `EXC_AdEL;
							6'b001xxx:
								if(exception_tlb_rw_i)
									cp0_cause_exc_code <= `EXC_Mod;
							6'b0001xx,6'b00001x:
								if(exception_tlb_rw_i)
									cp0_cause_exc_code <= `EXC_TLBS;
								else
									cp0_cause_exc_code <= `EXC_TLBL;
							6'b000001:
								cp0_cause_exc_code <= `EXC_Sys;
							default:
								cp0_cause_exc_code <= 0;
						endcase
					end
			end
	end
	
	//CP0 EPC
	always @ (posedge clk) 
	begin
		if(!cpu_pause_i)
			begin
				if(cp0_wen_i && (cp0_addr_i == `CP0_EPC_ADDR))
					cp0_epc <= cp0_data_i;
				else
					if(exc_occur && !cp0_status_exl)
						cp0_epc <= cp0_epc_i;
			end
	end

	
	always @ (posedge clk) begin
		if (reset) begin
			epc = 32'd0;
			cause = 32'd0;
			status = 32'd0;
		end
		else begin
			if (cp0_wen[0] == 1'b1 && pause == 1'b0) begin
				if (id_cp0_in_sel)
					epc = epc_in;
				else
					epc = id_b;
			end
			if (cp0_wen[1] == 1'b1 && pause == 1'b0) begin
				if (id_cp0_in_sel)
					cause = cause_in;
				else
					cause = id_b;
			end
			if (cp0_wen[2] == 1'b1 && pause == 1'b0) begin
				if (id_cp0_in_sel && status_shift_sel)
					status = {2'b00, status[31:2]};
				else if (id_cp0_in_sel && !status_shift_sel)
					status = {status[29:0], 2'b00};
				else
					status = id_b;
			end
		end
	end
	
	//CP0 read
	reg [31:0] cp0_data_output;
	always@(*)
	begin
		case(cp0_addr_i)
			`CP0_INDEX_ADDR:
				cp0_data_output = {cp0_index_p,27'b0,cp0_index_index};
			`CP0_ENTRYLO0_ADDR:
				cp0_data_output = {6'b0,cp0_entrylo0};
			`CP0_ENTRYLO1_ADDR:
				cp0_data_output = {6'b0,cp0_entrylo1 };
			`CP0_WIRED_ADDR:
				cp0_data_output = {28'b0,cp0_wired};
			`CP0_RANDOM_ADDR:
				cp0_data_output = {28'b0,cp0_random};
			`CP0_ENTRYHI_ADDR:
				cp0_data_output = {cp0_entryhi_vpn2,5'b0,cp0_entryhi_asid};
			`CP0_STATUS_ADDR:
				cp0_data_output = {16'b0,cp0_status_im,5'b0,cp0_status_um,2'b0,cp0_status_exl,cp0_status_ie};
			`CP0_CAUSE_ADDR:
				cp0_data_output = {16'b0,cp0_cause_ip,3'b0,cp0_cause_exc_code,2'b0};
			`CP0_EPC_ADDR:
				cp0_data_output = cp0_epc;
			default:
				cp0_data_output = 0;
		endcase
	end
	assign cp0_data_o = cp0_data_output;
	
	
	// assign id_cp0_out = (id_cp0_out_sel==2'd2) ? epc : ((id_cp0_out_sel==2'd1) ? cause : status);
	// assign status_out = status;
	// assign epc_out = epc;
	
endmodule