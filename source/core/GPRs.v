module GPRs(
	input clk,
	input [4:0]id_rs_addr,
	input [4:0]id_rt_addr,
	input wr_regwr,
	input [4:0]wr_regdst_addr,
	input [31:0]wr_data,
	output [31:0]id_rs_out,
	output [31:0]id_rt_out
);

	reg [31:0]r[31:0];
	
	initial
	begin:initial_loop
		integer i;
		for(i=0;i<32;i=i+1)
			r[i]=32'h0;
	end
	
	always @ (posedge clk) begin
		if ((wr_regwr == 1'b1) && (wr_regdst_addr!=5'd0)) begin
			r[wr_regdst_addr][31:0] = wr_data[31:0];
		end
	end
	
	assign id_rs_out = r[id_rs_addr];
	assign id_rt_out = r[id_rt_addr];

endmodule

