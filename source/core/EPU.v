module EPU(
	cp0_status_i,
	cp0_config_i,
	interrupt_i,
	exception_tlb_mod_i,
	exception_tlb_refill_i,
	exception_tlb_invalid_i,
	exception_ov_i,
	instruction,
	vector_addr_o,
	exception_code_o,
	exception_occur_o
);
input	cp0_status_i;
input	cp0_config_i;
input	interrupt_i;
input	exception_tlb_mod_i;
input	exception_tlb_refill_i;
input	exception_tlb_invalid_i;
input	exception_ov_i;
input[31:0]	instruction;
output [31:0]	vector_addr_o;
output [5:0]	exception_code_o;
output	exception_occur_o;


assign vector_addr_o = 32'hBFC00000;

endmodule
