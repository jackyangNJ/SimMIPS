module Section_rs(
	input [31:0]id_rs_out,
	output [4:0]rs_l
);

	assign rs_l = id_rs_out[4:0];

endmodule