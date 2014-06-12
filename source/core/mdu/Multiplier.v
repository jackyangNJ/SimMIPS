
module Multiplier(
		multiplier_i,
		multiplicand_i,
		signed_i,
		product_hi_o,
		product_lo_o
);
input [31:0] multiplier_i;
input [31:0] multiplicand_i;
input signed_i;
output reg [31:0] product_hi_o;
output reg [31:0] product_lo_o;
		
always@(*)
begin
	if(signed_i) begin
		{product_hi_o,product_lo_o} = $signed(multiplier_i) * $signed(multiplicand_i);
	end
	else begin
		{product_hi_o,product_lo_o} = multiplier_i * multiplicand_i;
	end
end

endmodule
