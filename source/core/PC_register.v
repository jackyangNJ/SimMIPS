module PC_register(
	input clk,
	input reset,
	input pa_pc_ifid,
	input [31:0]next_pc,
	output [31:0]if_pc_out
);

	reg [31:0]I_pc_out;
	
	always @ (posedge clk) begin
		if (reset)
			I_pc_out = 32'd0;
		else if (pa_pc_ifid == 1'b0)
			I_pc_out = next_pc;
	end
	assign if_pc_out = I_pc_out;

endmodule