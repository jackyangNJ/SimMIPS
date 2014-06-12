module Imm_Ext(
	input [15:0]id_imm,
	input id_ext_top,
	output [31:0]id_imm_ext
);

	assign id_imm_ext = (id_ext_top==1'b0 && id_imm[15]==1'b1) ? {16'hffff, id_imm} : {16'h0, id_imm};

endmodule