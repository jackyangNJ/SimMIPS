module Ext_Branch(
	input [15:0]id_imm,
	output [31:0]id_bra_imm
);

	assign id_bra_imm = (id_imm[15]==1'b1) ? {2'b11, 12'hfff, id_imm , 2'b00} : {14'd0, id_imm, 2'b00};

endmodule