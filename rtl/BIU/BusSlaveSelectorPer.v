`include "BusConfig.v"
module BusSlaveSelectorPer(
	input[31:0] adr_i,
	input stb_i,
	output[`PBUS_SLAVE_NUMBER-1:0]cs_o,
	output adr_err_o
);

	wire [`PBUS_SLAVE_NUMBER-1:0]match;
	wire matched;
	
	assign match[0] = adr_i[31:32-`PBUS_SLAVE_0_HADDR_WIDTH]==`PBUS_SLAVE_0_HADDR;
	assign match[1] = adr_i[31:32-`PBUS_SLAVE_1_HADDR_WIDTH]==`PBUS_SLAVE_1_HADDR;
	assign match[2] = adr_i[31:32-`PBUS_SLAVE_2_HADDR_WIDTH]==`PBUS_SLAVE_2_HADDR;
	assign match[3] = adr_i[31:32-`PBUS_SLAVE_3_HADDR_WIDTH]==`PBUS_SLAVE_3_HADDR;
	assign match[4] = adr_i[31:32-`PBUS_SLAVE_4_HADDR_WIDTH]==`PBUS_SLAVE_4_HADDR;
	assign match[5] = adr_i[31:32-`PBUS_SLAVE_5_HADDR_WIDTH]==`PBUS_SLAVE_5_HADDR;
	assign match[6] = adr_i[31:32-`PBUS_SLAVE_6_HADDR_WIDTH]==`PBUS_SLAVE_6_HADDR;
	assign match[7] = adr_i[31:32-`PBUS_SLAVE_7_HADDR_WIDTH]==`PBUS_SLAVE_7_HADDR;
	
	assign matched = match[0]|match[1]|match[2]|match[3]|match[4]|match[5]|match[6]|match[7];
	
	assign cs_o = match&{`PBUS_SLAVE_NUMBER{stb_i}};
	assign adr_err_o = stb_i&~matched;
endmodule
