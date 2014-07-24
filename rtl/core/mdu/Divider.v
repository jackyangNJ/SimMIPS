/**
 * dividend_i 表示被除数，divisior_i 表示除数
 * valid ready signal will last only one clock cycle
 */
module Divider(
	clk_i,
	rst_i,
	dividend_i,
	divisior_i,
	signed_i,
	start_i,
	quotient_o,
	remainder_o,
	ready_o,
	busy_o
);
input clk_i,rst_i;
input start_i;
input [31:0] dividend_i,divisior_i;
input signed_i;
output  [31:0] quotient_o,remainder_o;
output  ready_o,busy_o;

/* internal variables*/
wire [31:0] dividend,divisior;
wire [31:0] quotient,remainder;


assign divisior = (signed_i&divisior_i[31]) ?  ~divisior_i + 1'b1 : divisior_i;
assign dividend = (signed_i&dividend_i[31]) ?  ~dividend_i + 1'b1 : dividend_i;
assign quotient_o = (signed_i &(dividend_i[31] ^ divisior_i[31])) ? ~quotient + 1'b1 : quotient;
assign remainder_o = (signed_i & dividend_i[31]) ? ~remainder + 1'b1 : remainder;

DividerNonRestoring dividerNonRestoring_inst(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.divisior_i(divisior),
	.dividend_i(dividend),
	.start_i(start_i),
	.quotient_o(quotient),
	.remainder_o(remainder),
	.ready_o(ready_o),
	.busy_o(busy_o)
	);

endmodule


/* unsigned divider with nonrestoring method */
module DividerNonRestoring(
	clk_i,
	rst_i,
	divisior_i,
	dividend_i,
	start_i,
	quotient_o,
	remainder_o,
	ready_o,
	busy_o
);
input clk_i,rst_i;
input start_i;
input [31:0] dividend_i,divisior_i;
output ready_o,busy_o;
output [31:0] quotient_o,remainder_o;

/*  internal variables  */
reg [5:0] count;
reg ready;
reg busy;
reg r_sign;
reg [31:0] quotient,remainder;
wire [32:0] inter_result;

 
always@(posedge clk_i)
begin
	if(rst_i)  //reset
		begin
			count <= 0;
			busy <= 0;
			ready <= 0;
			r_sign <= 0;
		end
	else
		begin
			if(start_i)
				begin
					busy <= 1'b1;
					ready <= 1'b0;
					count <= 0;
					r_sign <= 0;
					quotient <= dividend_i;
					remainder <= 0;
				end
			else if(busy)
					begin
						remainder <= inter_result[31:0];
						quotient <= {quotient[30:0],~inter_result[32]};
						count <= count + 1'b1;
						r_sign <= inter_result[32];
						if(count == 5'd31)
							begin
								busy <= 0;
								ready <= 1'b1;
							end
					end
		end
end

assign ready_o = ready;
assign inter_result = r_sign ? {remainder,quotient[31]}+{1'b0,divisior_i} : {remainder,quotient[31]} - {1'b0,divisior_i};
assign quotient_o = quotient;
assign remainder_o = r_sign ? remainder + divisior_i : remainder;
assign busy_o = busy;
endmodule

