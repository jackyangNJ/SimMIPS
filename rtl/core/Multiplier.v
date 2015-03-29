
module Multiplier(
	input [31:0] multiplier_i,
	input [31:0] multiplicand_i,
	input signed_i,
	output[31:0] product_hi_o,
	output[31:0] product_lo_o
);

wire [63:0] product_signed,product_unsigned;

// multiplier_unsigned unsigned_inst(
    // .multiplier_i(multiplier_i),
    // .multiplicand_i(multiplicand_i),
    // .product_o(product_unsigned)
// );

// multiplier_signed signed_inst(
    // .multiplier_i(multiplier_i),
    // .multiplicand_i(multiplicand_i),
    // .product_o(product_signed)
// );

mult_unsigned unsigned_inst(
    .A(multiplier_i),
    .B(multiplicand_i),
    .P(product_unsigned)
);

mult_signed signed_inst(
    .A(multiplier_i),
    .B(multiplicand_i),
    .P(product_signed)
); 

assign product_hi_o = signed_i? product_signed[63:32] : product_unsigned[63:32];
assign product_lo_o = signed_i? product_signed[31:0] : product_unsigned[31:0];

endmodule

module multiplier_signed(
    input signed[31:0] multiplier_i,
    input signed[31:0] multiplicand_i,
    output signed[63:0] product_o
);
assign product_o = multiplicand_i * multiplier_i;
endmodule

module multiplier_unsigned(
    input [31:0] multiplier_i,
    input [31:0] multiplicand_i,
    output[63:0] product_o
);
assign product_o = multiplicand_i * multiplier_i;
endmodule