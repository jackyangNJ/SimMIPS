module ExMem_register(
	input clk,
	input reset,
	input pa_idexmemwr,
	input wash_exmem_i,
	input ex_regwr,
	input ex_memtoreg,
	input ex_memwr,
	input ex_dmen,
	input [3:0] ex_mem_bytesel_i,
	input ex_mem_extsigned_i,
	input [31:0] ex_pc_i,
	input [31:0]ex_result,
	input [31:0]ex_b,
	input [4:0]ex_regdst_addr,
	output mem_regwr,
	output mem_dmen,
	output mem_memtoreg,
	output mem_memwr,
	output [3:0]  mem_bytesel_o,
	output        mem_extsigned_o,
	output [31:0] mem_result,
	output [31:0] mem_rt,
	output [4:0]  mem_regdst_addr,
	output [31:0] mem_pc_o
);

	reg E_regwr;
	reg E_memtoreg;
	reg E_memwr;
	reg E_dmem;
	reg [3:0] E_mem_bytesel;
	reg E_mem_extsigned;
	reg [31:0]E_result;
	reg [31:0]E_b;
	reg [4:0]E_regdst_addr;
	reg [31:0] E_pc;
	always @ (posedge clk) begin
		if (reset || wash_exmem_i) begin
			E_regwr = 1'b0;
			E_memtoreg = 1'b0;
			E_memwr = 1'b0;
			E_dmem = 1'b0;
			E_mem_extsigned = 1'b0;
			E_mem_bytesel = 4'b0;
			E_result = 32'd0;
			E_b = 32'd0;
			E_regdst_addr = 5'd0;
			E_pc = 32'b0;
		end
		else if (!pa_idexmemwr) begin
			E_regwr = ex_regwr;
			E_memtoreg = ex_memtoreg;
			E_memwr = ex_memwr;
			E_dmem = ex_dmen;
			E_result = ex_result;
			E_b = ex_b;
			E_regdst_addr = ex_regdst_addr;
			E_pc = ex_pc_i;
			E_mem_bytesel = ex_mem_bytesel_i;
		end
	end
	
	assign mem_regwr = E_regwr;
	assign mem_dmen = E_dmem;
	assign mem_memtoreg = E_memtoreg;
	assign mem_memwr = E_memwr;
	assign mem_bytesel_o = E_mem_bytesel;
	assign mem_extsigned_o = E_mem_extsigned;
	assign mem_result = E_result;
	assign mem_rt = E_b;
	assign mem_regdst_addr = E_regdst_addr;
	assign mem_pc_o = E_pc;
endmodule