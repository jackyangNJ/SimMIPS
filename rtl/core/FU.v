module FU(
	input [31:0]id_instr,
	input ex_regwr,
	input [4:0]ex_regdst_addr,
	input mem_regwr,
	input [4:0]mem_regdst_addr,
	input wr_regwr,
	input [4:0]wr_regdst_addr,
	output reg[1:0]id_a_sel,
	output reg[1:0]id_b_sel
);

	wire [4:0] id_rt;
	wire [4:0] id_rs;
	
	assign id_rt[4:0] = id_instr[20:16];
	assign id_rs[4:0] = id_instr[25:21];

	//转发优先级：Ex > Mem > Wr
	always@(*)
	begin
		if((ex_regwr == 1'b1) && (ex_regdst_addr == id_rs))
			id_a_sel[1:0] = 2'b01;
		else if((mem_regwr == 1'b1) && (mem_regdst_addr == id_rs))
			id_a_sel[1:0] = 2'b10;
		else if((wr_regwr == 1'b1) && (wr_regdst_addr == id_rs))
			id_a_sel[1:0] = 2'b11;
		else
			id_a_sel[1:0] = 2'b00;
	end
	
	//转发优先级：Ex > Mem > Wr
	always@(*)
	begin
		if((ex_regwr == 1'b1) && (ex_regdst_addr == id_rt))
			id_b_sel[1:0] = 2'b01;
		else if((mem_regwr == 1'b1) && (mem_regdst_addr == id_rt))
			id_b_sel[1:0] = 2'b10;
		else if((wr_regwr == 1'b1) && (wr_regdst_addr == id_rt))
			id_b_sel[1:0] = 2'b11;
		else
			id_b_sel[1:0] = 2'b00;
	end
	
endmodule
