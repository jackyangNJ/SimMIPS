module MemWr_register(
	input clk,
	input reset,
	input pa_idexmemwr,
	input mem_regwr,
	input [31:0]mem_data,
	input [4:0]mem_regdst_addr,
	output wr_regwr,
	output [31:0]wr_data,
	output [4:0]wr_regdst_addr
);

	reg [31:0]M_data;
	reg [4:0]M_regdst_addr;
	reg M_regwr;

	always @ (posedge clk) begin
		if (reset) begin
			M_data = 32'd0;
			M_regdst_addr = 5'd0;
			M_regwr = 1'b0;
		end
		else if (pa_idexmemwr == 1'b0) begin
			M_data = mem_data;
			M_regdst_addr = mem_regdst_addr;
			M_regwr = mem_regwr;
		end
	end
	
	assign wr_regwr = M_regwr;
	assign wr_data = M_data;
	assign wr_regdst_addr = M_regdst_addr;

endmodule