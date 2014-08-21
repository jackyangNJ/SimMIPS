module mips_system(
	input  iCLK_50,
	input  PS2_KBCLK,
	input  PS2_KBDAT,
	input  iUART_RXD,
	output oUART_TXD,
	output [17:0] oLEDR,
	output [8:0] oLEDG,
	inout [17:0] iSW,
	input [3:0] iKEY
);


cpu_top#(
	.EXT_CLOCK_FREQ(50000000)
) cpu(
	.external_clk_i(iCLK_50),
	.external_rst_i(~iKEY[0]),
	.uart_rx_i(iUART_RXD),
	.uart_tx_o(oUART_TXD),
	.gpio_pin({oLEDR[15:0],iSW[15:0]}),
	.kb_clk_i(PS2_KBCLK),
	.kb_dat_i(PS2_KBDAT)
);
endmodule
