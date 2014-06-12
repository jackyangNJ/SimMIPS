module InterruptController(
					uart_cr_i,
					uart_sr_i,
					int_o
);
input [5:0] uart_cr_i;
input [3:0] uart_sr_i;
output int_o;

	assign int_o=(uart_cr_i[0]&(
						(uart_sr_i[2] | uart_sr_i[1] | uart_sr_i[0]))
					);
endmodule
