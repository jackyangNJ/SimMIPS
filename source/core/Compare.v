module Compare(
	input [31:0]id_a,
	input [31:0]id_b,
	output [3:0]id_compare
);

	assign id_compare[0] = (id_a==id_b) ? 1'b1 : 1'b0;
	assign id_compare[1] = (id_a==32'd0) ? 1'b1 : 1'b0;
	assign id_compare[2] = (id_a[31]==1'b1) ? 1'b1 : 1'b0;
	assign id_compare[3] = (id_b == 0) ? 1'b1 : 1'b0;
	
endmodule