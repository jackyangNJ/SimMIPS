
module Multiplier(
	input [31:0] multiplier_i,
	input [31:0] multiplicand_i,
	input signed_i,
	output[31:0] product_hi_o,
	output[31:0] product_lo_o
);

reg signed [63:0] product_signed;
reg unsigned [63:0] product_unsigned;

always@(*)
begin
	product_signed = 0;
	product_unsigned = 0;
	if(signed_i)
		product_signed = $signed(multiplier_i) * $signed(multiplicand_i);
	else
		product_unsigned = multiplier_i * multiplicand_i;
end

assign product_hi_o = signed_i? product_signed[63:32] : product_unsigned[63:32];
assign product_lo_o = signed_i? product_signed[31:0] : product_unsigned[31:0];
endmodule
