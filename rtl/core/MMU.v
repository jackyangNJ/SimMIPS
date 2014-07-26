module MMU(
	input clk_i,
	input rst_i,
	input [31:0] ivirtual_addr_i,
	input [31:0] dvirtual_addr_i,
	//connected with cache and bus
	output [31:0] dphy_addr_o,
	output [31:0] iphy_addr_o,
	output [31:0] data_o,
	output        data_wr_o,
	output [3:0]  data_bytesel_o,
	//TLB instructions 
	input instr_tlbp_i,
	input instr_tlbr_i,
	input instr_tlbwr_i,
	input instr_tlbwi_i,
	//CP0 registers data input
	input [31:0] cp0_entryhi_i,
	input [31:0] cp0_entrylo0_i,
	input [31:0] cp0_entrylo1_i,
	input [31:0] cp0_random_i,
	input [31:0] cp0_status_i,
	input [31:0] cp0_index_i,
	input [31:0] cp0_config_i,
	
	//connected with BUS	
	output ibus_memory_en_o,
	input  ibus_memory_data_ready_i,
	input  ibus_memory_data_i,
	output dbus_memory_en_o,
	input  dbus_memory_data_ready_i,
	output dbus_memory_data_i,
	output dbus_peripheral_en_o,
	input  dbus_peripheral_data_ready_i,
	input  dbus_peripheral_data_i,
	
	//connected with CACHE
	output icache_en_o,
	output dcache_en_o,
	input  icache_data_ready_i,
	input  ichache_data_i,
	input  dcache_data_ready_i,
	input  dchache_data_i,
	
	//connected with CPU core
	input         dm_en_i,
	input [31:0]  dm_data_i,
	input         dm_wr_i,
	input [3:0]   dm_bytesel_i,
	input         dm_extsigned_i,
	output [31:0] dm_data_o,
	output [31:0] instruction_o, 
	output        cpu_pause_o, //**
	output        exception_addr_error_o,
	output        exception_tlb_refill_o,
	output        exception_tlb_mod_o,
	output        exception_tlb_invalid_o,
	output        exception_tlb_rw_o, //**
	/* to CP0 registers */
	output [3:0]  tlb_entryhi_match_index_o,
	output        tlb_entryhi_hit_o,
	output [31:0] tlb_entryhi_o,
	output [31:0] tlb_entrylo0_o,
	output [31:0] tlb_entrylo1_o,
	output        tlb_entryhi_data_valid_o,
	output        tlb_entrylo0_data_valid_o,
	output        tlb_entrylo1_data_valid_o
	output [31:0] bad_vaddr_o,
);

/* Constants */
wire [3:0]cp0_random_random = cp0_random_i[3:0];
wire [3:0]cp0_index_index = cp0_index_i[3:0];
wire [2:0] cp0_config_k0 = cp0_config_i[2:0];
wire cp0_status_exl = cp0_status_i[1];                  
wire cp0_status_um = cp0_status_i[4];

//connected with JTLB
wire itlb_hit,dtlb_hit;
reg [31:0] iphy_addr,dphy_addr;
wire [4:0] itlb_opts,dtlb_opts;
wire [2:0] itlb_entry_c;
wire itlb_entry_d,itlb_entry_v;
wire [2:0] dtlb_entry_c;
wire dtlb_entry_d,dtlb_entry_v;
// wire tlb_instrs = (instr_tlbp_i || instr_tlbr_i || instr_tlbwi_i || instr_tlbwr_i);
wire [31:0] dtlb_phy_addr,itlb_phy_addr;


wire cpu_user_mode = !cp0_status_exl && cp0_status_um;
// wire cpu_kernel_mode = !cpu_user_mode;

reg iexception_tlb_refill,iexception_addr_error,iexception_tlb_invalid;
reg icache_en,dcache_en,ibus_memory_en,dbus_memory_en,dbus_peripheral_en;
//instruction 
always@(*)
begin
	icache_en = 0;
	ibus_memory_en = 0;
	iexception_addr_error = 0;
	iexception_tlb_invalid = 0;
	iexception_tlb_refill = 0;
	
	if(cpu_user_mode && ivirtual_addr_i[31])
		iexception_addr_error = 1'b1;
	else
		begin
			//kseg0
			case(ivirtual_addr_i[31:29])
				3'b100: //kseg0
					begin
						iphy_addr = {3'b000,ivirtual_addr_i[28:0]};
						if(cp0_config_k0 == 3'd2 || cp0_config_k0 == 3'd7)
							ibus_memory_en = 1'b1;
						else
							icache_en = 1'b1;
			
					end
				3'b101: //kseg1
					begin
						iphy_addr = {3'b000,ivirtual_addr_i[28:0]};
						
					end
				default:
					begin
						iphy_addr = itlb_phy_addr;
						if(!itlb_hit)
							iexception_tlb_refill = 1'b1;
						else
							if(!itlb_entry_v)
								iexception_tlb_invalid = 1'b1;
							else
								if(itlb_entry_c == 3'd2 || itlb_entry_c == 3'd7)
									ibus_memory_en = 1'b1;
								else
									icache_en = 1'b1;
					end
			endcase
		end
end

//data
reg dexception_addr_error,dexception_tlb_invalid,dexception_tlb_refill,dexception_tlb_mod;
always@(*)
begin
	dcache_en = 0;
	dbus_memory_en = 0;
	dbus_peripheral_en = 0;
	dexception_addr_error = 0;
	dexception_tlb_invalid = 0;
	dexception_tlb_refill = 0;
	dexception_tlb_mod = 0;
	dphy_addr =0;
	if(dm_en_i)
		begin
			if(cpu_user_mode && ivirtual_addr_i[31])
				dexception_addr_error = 1'b1;
			else
				begin
				
					//kseg0
					case(dvirtual_addr_i[31:29])
						3'b100: //kseg0
							begin
								dphy_addr = {3'b000,dvirtual_addr_i[28:0]};
								if(cp0_config_k0 == 3'd2 || cp0_config_k0 == 3'd7)
									dbus_memory_en = 1'b1;
								else
									dcache_en = 1'b1;
					
							end
						3'b101: //kseg1
							begin
								dphy_addr = {3'b000,dvirtual_addr_i[28:0]};
								dbus_peripheral_en = 1'b1;
							end
						default:
							begin						
								dphy_addr = dtlb_phy_addr;
								if(!dtlb_hit)
									dexception_tlb_refill = 1'b1;
								else
									if(!dtlb_entry_v)
										dexception_tlb_invalid = 1'b1;
									else
										if(!dtlb_entry_d && dm_wr_i)  
											dexception_tlb_mod = 1'b1;
										else
											if(dtlb_entry_c == 3'd2 || dtlb_entry_c == 3'd7)
												dbus_memory_en = 1'b1;
											else
												dcache_en = 1'b1;
							end
					endcase
				end
		end
			
end

reg [31:0] dm_data;
reg [31:0] instruction;
always@(*)
begin
	instruction = 0;
	dm_data = 0;
	//instruction
	if(icache_en)
		instruction = ichache_data_i;
	else
		if(ibus_memory_en)
			instruction = ibus_memory_data_i;
			
	//data
	if(dcache_en)
		dm_data = dchache_data_i;
	else 	
		if(dbus_memory_en)
			dm_data = dbus_memory_data_i;
		else
			if(dbus_peripheral_en)
				dm_data = dbus_peripheral_data_i;
	
	case(dm_bytesel_i)
		4'b0001:
			if(dm_extsigned_i)
				dm_data = {24'b0,dm_data[7:0]};
			
		4'b0011:
			if(dm_extsigned_i)
				dm_data = {16'b0,dm_data[15:0]};
		default:
			begin
			end
	endcase
end




wire tlb_wr = (instr_tlbwi_i || instr_tlbwr_i) ? 1'b1 : 1'b0;
wire [3:0] tlb_index  = (instr_tlbr_i || instr_tlbwi_i) ? cp0_index_index : cp0_random_random;
JTLB jtlb_entry(
	.clk_i(clk_i),
	.ivirtual_addr_i(ivirtual_addr_i),
	.tlb_wr_i(tlb_wr),
	.tlb_entryhi_i(cp0_entryhi_i),
	.tlb_entrylo0_i(cp0_entrylo0_i),
	.tlb_entrylo1_i(cp0_entrylo1_i),
	.tlb_index_i(tlb_index),
	.dvirtual_addr_i(dvirtual_addr_i),
	.tlb_index_o(tlb_entryhi_match_index_o),
	.tlb_entryhi_hit_o(tlb_entryhi_hit_o),
	.itlb_hit_o(itlb_hit),
	.iphy_addr_o(itlb_phy_addr),
	.itlb_opts_o({itlb_entry_c,itlb_entry_d,itlb_entry_v}),
	.dtlb_hit_o(dtlb_hit),
	.dphy_addr_o(dtlb_phy_addr),
	.dtlb_opts_o({dtlb_entry_c,dtlb_entry_d,dtlb_entry_v}),
	.tlb_entryhi_o(tlb_entryhi_o),
	.tlb_entrylo0_o(tlb_entrylo0_o),
	.tlb_entrylo1_o(tlb_entrylo1_o)
);
assign data_wr_o = dm_wr_i;
assign data_o = dm_data_i;
assign data_bytesel_o = dm_bytesel_i;
//address
assign iphy_addr_o = iphy_addr;
assign dphy_addr_o = dphy_addr;
//cache
assign icache_en_o = icache_en;
assign dcache_en_o = dcache_en;
//bus
assign ibus_memory_en_o = ibus_memory_en;
assign dbus_memory_en_o = dbus_memory_en;
assign dbus_peripheral_en_o = dbus_peripheral_en;


//exception
assign exception_addr_error_o = iexception_addr_error & dexception_addr_error;
assign exception_tlb_invalid_o = iexception_tlb_invalid & dexception_tlb_invalid;
assign exception_tlb_mod_o = dexception_tlb_mod;
assign exception_tlb_refill_o = iexception_tlb_refill & dexception_tlb_refill;
assign exception_tlb_rw_o = (iexception_addr_error || iexception_tlb_invalid || iexception_tlb_refill)? 0 : dm_wr_i;
//to cp0
assign tlb_entryhi_data_valid_o = instr_tlbr_i ? 1'b1 : 1'b0;
assign tlb_entrylo0_data_valid_o = instr_tlbr_i ? 1'b1 : 1'b0;
assign tlb_entrylo1_data_valid_o = instr_tlbr_i ? 1'b1 : 1'b0;
assign bad_vaddr_o = (iexception_addr_error || iexception_tlb_invalid || iexception_tlb_refill) ? ivirtual_addr_i : dvirtual_addr_i;
//cpu
assign instruction_o = instruction;
assign dm_data_o = dm_data;
assign cpu_pause_o = ~(icache_data_ready_i || ibus_memory_data_ready_i) || 
					   ~((dm_en_i && (dcache_data_ready_i || dbus_memory_data_ready_i || dbus_peripheral_data_ready_i)) || !dm_en_i);

endmodule
