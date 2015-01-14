`include "../include/Defines.v"
module CP0(
	input clk,
	input reset,
	input cpu_pause_i,
	output cp0_intrrupt_o,
	output cp0_exception_tlb_byinstr_o,
	output cp0_exception_tlb_o,
	/* specified instruction available state */
	input instr_ERET_i,
	/* normal r/w interface */
	input         cp0_wen_i,
	input [4:0]   cp0_addr_i,
	input [31:0]  cp0_data_i,
	output [31:0] cp0_data_o,
	/* cp0 data out */
	output [31:0] cp0_epc_o,
	output [31:0] cp0_status_o,
	output [31:0] cp0_config_o,
	// cp0_cause_o,
	output [31:0] cp0_random_o,
	output [31:0] cp0_index_o,
	output [31:0] cp0_entryhi_o,
	output [31:0] cp0_entrylo0_o,
	output [31:0] cp0_entrylo1_o,
	/* cp0 data in */
	input [31:0]  cp0_epc_i,
	input [31:0]  cp0_entryhi_i,
	input         cp0_entryhi_data_valid_i,
	input [31:0]  cp0_entrylo0_i,
	input         cp0_entrylo0_data_valid_i,
	input [31:0]  cp0_entrylo1_i,
	input         cp0_entrylo1_data_valid_i,
	/* tlb signal */
	input [3:0]   tlb_entryhi_match_index_i,
	input         tlb_entryhi_hit_i,
	input [31:0]  cp0_bad_vaddr_i,
	/* exceptions */
	input         exception_tlb_by_instr_i,
	input         exception_addr_error_i,
	input         exception_tlb_refill_i,
	input         exception_tlb_mod_i,
	input         exception_tlb_invalid_i,
	input         exception_tlb_rw_i,
	input         exception_syscall_i,
	input         hw_interrupt0_i,
	input         hw_interrupt1_i,
	input         hw_interrupt2_i,
	input         hw_interrupt3_i,
	input         hw_interrupt4_i,
	input         hw_interrupt5_i
	
);

/* CP0 Registers */
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
	//CP0 BadVAddr
	reg [31:0] cp0_bad_vaddr;
	//CP0 Status
	reg cp0_status_ie,cp0_status_exl,cp0_status_um;
	reg [5:0] cp0_status_im;
	//CP0 Cause
	reg [5:0] cp0_cause_ip;
	reg [4:0] cp0_cause_exc_code;
	//CP0 config
	wire cp0_config_m = 1'b1;
	wire cp0_config_be = 1'b0; //little endian
	wire [2:0] cp0_config_mt = 3'd1;
	wire [2:0] cp0_config_k0 = 3'd2; //no cache
/* Constants */
	/* interrupts occur */
	wire interrupt0 = hw_interrupt0_i && cp0_status_im[0];
	wire interrupt1 = hw_interrupt1_i && cp0_status_im[1];
	wire interrupt2 = hw_interrupt2_i && cp0_status_im[2];
	wire interrupt3 = hw_interrupt3_i && cp0_status_im[3];
	wire interrupt4 = hw_interrupt4_i && cp0_status_im[4];
	wire interrupt5 = hw_interrupt5_i && cp0_status_im[5];
	wire intr_occur = (interrupt0 || interrupt1 || interrupt2 || interrupt3 ||interrupt4 || interrupt5)
						&& (!cp0_status_exl) && cp0_status_ie;
	/* exception occur*/
	wire exc_tlb_occur = exception_addr_error_i || exception_tlb_invalid_i || exception_tlb_mod_i || exception_tlb_refill_i;
	wire exc_occur = intr_occur || exception_syscall_i || exc_tlb_occur;
		
	/* CP0 Index */
	always@(posedge clk)
	begin
		if(!cpu_pause_i)
			begin
				if(tlb_entryhi_hit_i)
					cp0_index_p <= 1'b0;
				else
					cp0_index_p <= 1'b1;
				if(cp0_wen_i && cp0_addr_i ==`CP0_INDEX_ADDR)
						cp0_index_index <= cp0_data_i[3:0];
				else 
					if(tlb_entryhi_hit_i)
						cp0_index_index <= tlb_entryhi_match_index_i;
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
	
	/* CP0 Wired */
	always@(posedge clk)
	begin
		if(reset)
			cp0_wired <= 0;
		else
			if(!cpu_pause_i)
				begin
					if(cp0_wen_i && cp0_addr_i == `CP0_WIRED_ADDR)
						cp0_wired <= cp0_data_i[3:0];
				end
	end

	/* CP0 BadVAddr*/
	always@(posedge clk)
	begin		
		if(!cpu_pause_i)
			begin
				cp0_bad_vaddr <= cp0_bad_vaddr_i;
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
					if(cp0_entrylo1_data_valid_i)
						cp0_entrylo0 <= cp0_entrylo0_i[25:0];
				//entrylo1
				if(cp0_wen_i && cp0_addr_i == `CP0_ENTRYLO1_ADDR)
					cp0_entrylo1 <= cp0_data_i[25:0];
				else
					if(cp0_entrylo1_data_valid_i)
						cp0_entrylo1 <= cp0_entrylo0_i[25:0];
				//entryhi
				if(exception_tlb_invalid_i || exception_tlb_mod_i || exception_tlb_refill_i)
					cp0_entryhi_vpn2 <= cp0_bad_vaddr_i[31:13];
				else
					if(cp0_wen_i && cp0_addr_i == `CP0_ENTRYHI_ADDR)
						{cp0_entryhi_vpn2,cp0_entryhi_asid} <= {cp0_data_i[31:13],cp0_data_i[7:0]};
					else
						if(cp0_entryhi_data_valid_i)
							{cp0_entryhi_vpn2,cp0_entryhi_asid} <= {cp0_entryhi_i[31:13],cp0_entryhi_i[7:0]};
			end
	end
	
	//CP0 Status
	always @ (posedge clk) 
	begin
		if(reset)
			cp0_status_exl <= 1'b1;
		else
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
								if(instr_ERET_i)
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
						casex({intr_occur,exception_addr_error_i,exception_tlb_mod_i,
						exception_tlb_refill_i,exception_tlb_invalid_i,exception_syscall_i})
							/* interrupts */
							6'b1xxxxx:
								begin
									cp0_cause_ip[5] <= interrupt5;
									cp0_cause_ip[4] <= interrupt4;
									cp0_cause_ip[3] <= interrupt3;
									cp0_cause_ip[2] <= interrupt2;
									cp0_cause_ip[1] <= interrupt1;
									cp0_cause_ip[0] <= interrupt0;
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

	
	/* CP0 read,for instruction MFC0 */
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
			`CP0_CONFIG_ADDR:
				cp0_data_output = {cp0_config_m,15'b0,cp0_config_be,5'b0,cp0_config_mt,4'b0,cp0_config_k0};
			`CP0_BADVADDR_ADDR:
				cp0_data_output = cp0_bad_vaddr;
			default:
				cp0_data_output = 0;
		endcase
	end
	
	assign cp0_data_o = cp0_data_output;
	assign cp0_epc_o = cp0_epc;
	assign cp0_entryhi_o = {cp0_entryhi_vpn2,5'b0,cp0_entryhi_asid};
	assign cp0_entrylo0_o = {6'b0,cp0_entrylo0};
	assign cp0_entrylo1_o = {6'b0,cp0_entrylo1};
	assign cp0_status_o = {16'b0,cp0_status_im,5'b0,cp0_status_um,2'b0,cp0_status_exl,cp0_status_ie};
	assign cp0_index_o = {cp0_index_p,27'b0,cp0_index_index};
	assign cp0_random_o = {28'b0,cp0_random};
	assign cp0_config_o = {cp0_config_m,15'b0,cp0_config_be,5'b0,cp0_config_mt,4'b0,cp0_config_k0};
	
	assign cp0_intrrupt_o = intr_occur;
	assign cp0_exception_tlb_byinstr_o = exception_tlb_by_instr_i;
	assign cp0_exception_tlb_o = exc_tlb_occur;
endmodule