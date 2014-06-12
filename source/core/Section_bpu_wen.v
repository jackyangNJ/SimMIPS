module Section_bpu_wen(
	input [1:0]id_bpu_wen,
	output id_bpu_wen_h
);

	assign id_bpu_wen_h = id_bpu_wen[1];

endmodule