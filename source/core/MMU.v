module MMU(
	clk_i,
	rst_i,
	instr_tlbp_i,
	instr_tlbr_i,
	instr_tlbwr_i,
	instr_tlbwi_i,
	cp0_entryhi_i,
	cp0_entrylo0_i,
	cp0_entrylo1_i,
	cp0_random_i,
	cp0_wired_i,
	cp0_status_i,
	ivirtual_addr_i,
	dvirtual_addr_i,
	dmem_data_i,
	dmem_en_i,
	dmem_wr_i,
	exception_addr_error_o,
	exception_tlb_refill_o,
	exception_tlb_mod_o,
	exception_tlb_invalid_o,
	exception_by_instr
);


endmodule



module TLB(
	clk_i,
	ivirtual_addr_i,
	tlb_wr_i,
	tlb_entryhi_i,
	tlb_entrylo0_i,
	tlb_entrylo1_i,
	tlb_index_i,
	dvirtual_addr_i,
	itlb_hit_o,
	iphy_addr_o,
	itlb_opts_o,
	dtlb_hit_o,
	dphy_addr_o,
	dtlb_opts_o
);
input clk_i;
input [31:0] ivirtual_addr_i,dvirtual_addr_i;
input tlb_wr_i;
input [31:0] tlb_entryhi_i,tlb_entrylo0_i,tlb_entrylo1_i;
input [3:0] tlb_index_i;
output itlb_hit_o,dtlb_hit_o;
output [4:0] itlb_opts_o,dtlb_opts_o;
output [31:0] iphy_addr_o,dphy_addr_o;


wire [7:0]asid = tlb_entryhi_i[7:0];
reg [18:0] tlb_vpn2[15:0];
reg  tlb_g[15:0];
reg [7:0]tlb_asid[15:0];
reg [19:0] tlb_entrylo0_pfn[15:0];
reg [4:0] tlb_entrylo0_opts[15:0];
reg [4:0] tlb_entrylo1_opts[15:0];
reg [19:0] tlb_entrylo1_pfn[15:0];



always@(posedge clk_i)
begin
	if(tlb_wr_i)
		begin
			tlb_vpn2[tlb_index_i] <= tlb_entryhi_i[31:13];
			tlb_asid[tlb_index_i] <=asid;
			tlb_entrylo0_pfn[tlb_index_i] <= tlb_entrylo0_i[25:6];
			tlb_entrylo0_opts[tlb_index_i] <= tlb_entrylo0_i[5:1];
			tlb_entrylo1_pfn[tlb_index_i] <= tlb_entrylo1_i[25:6];
			tlb_entrylo1_opts[tlb_index_i] <= tlb_entrylo1_i[5:1];
			tlb_g[tlb_index_i] <= tlb_entrylo0_i[0] & tlb_entrylo1_i[0];
		end
end


reg itlb_match;
reg [4:0]itlb_match_index;
reg [18:0] tlb_vpn2[15:0];
always@(*)
begin
	itlb_match = 1'b0;
	itlb_match_index = 4'dx;
	begin:loop1
			integer i;
			for (i=0;i<16;i=i+1)
			begin
				if (tlb_vpn2[i] == ivirtual_addr_i[31:13]) //匹配地址高位
				begin
					itlb_match= 1; 
					itlb_match_index = i[3:0];  //找到匹配的地址
					disable loop1;				//退出循环
				end
			end
	end
end
wire itlb_hit = ((itlb_match && tlb_g[itlb_match_index]) || (itlb_match && !tlb_g[itlb_match_index] && tlb_asid[itlb_match_index] == asid)) ? 1'b1 : 1'b0;
assign itlb_hit_o = itlb_hit;
assign iphy_addr_o = itlb_hit ? (ivirtual_addr_i[12] ? {tlb_entrylo1_pfn[itlb_match_index],ivirtual_addr_i[11:0]} : {tlb_entrylo0_pfn[itlb_match_index],ivirtual_addr_i[11:0]}) : 32'b0;
assign itlb_opts_o = itlb_hit ? (ivirtual_addr_i[12] ? tlb_entrylo1_opts[itlb_match_index] : tlb_entrylo0_opts[itlb_match_index]) : 5'b0;

reg dtlb_match;
reg [4:0]dtlb_match_index;
always@(*)
begin
	dtlb_match = 1'b0;
	dtlb_match_index = 4'dx;
	begin:loop2
			integer i;
			for (i=0;i<16;i=i+1)
			begin
				if (tlb_vpn2[i] == dvirtual_addr_i[31:13])
				begin
					dtlb_match= 1;
					dtlb_match_index = i[3:0];
					disable loop2;
				end
			end
	end
end
wire dtlb_hit = ((dtlb_match && tlb_g[dtlb_match_index]) || (dtlb_match && !tlb_g[dtlb_match_index] && tlb_asid[dtlb_match_index] == asid)) ? 1'b1 : 1'b0;
assign dtlb_hit_o = dtlb_hit;
assign dphy_addr_o = dtlb_hit ? (dvirtual_addr_i[12] ? {tlb_entrylo1_pfn[dtlb_match_index],dvirtual_addr_i[11:0]} : {tlb_entrylo0_pfn[dtlb_match_index],dvirtual_addr_i[11:0]}) : 32'b0;
assign dtlb_opts_o = dtlb_hit ? (dvirtual_addr_i[12] ? tlb_entrylo1_opts[dtlb_match_index] : tlb_entrylo0_opts[dtlb_match_index]) : 5'b0;


endmodule