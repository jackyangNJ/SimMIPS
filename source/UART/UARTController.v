module UARTController(
	cs_i,
	we_i,
	rx_i,
	clk_i,
	rst_i,
	adr_i,
	dat_i,
	int_o,
	ack_o,
	tx_o,
	dat_o
);


input wire	cs_i;
input wire	we_i;
input wire	rx_i;
input wire	clk_i,rst_i;
input wire	[31:0] adr_i;
input wire	[31:0] dat_i;
output wire	int_o;
output wire	ack_o;
output wire	tx_o;
output wire	[31:0] dat_o;

wire	receive_baudgenerator_en;
wire	[15:0] uart_brr;
wire	send_baudgenerator_en;
wire	rc;
wire	tc;
wire	pe;
wire	busy;
wire	[7:0] receive_data;
wire	[5:0] uart_cr;
wire	[3:0] uart_sr;
wire	receive_baud;
wire	send_start;
wire	send_baud;
wire	[7:0] send_data;





BaudGenerator	receive_baudger(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.enable_i(receive_baudgenerator_en),
	.uart_brr_i(uart_brr),
	.baud_clk_o(receive_baud));


BaudGenerator	send_baudger(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.enable_i(send_baudgenerator_en),
	.uart_brr_i(uart_brr),
	.baud_clk_o(send_baud));


BusController	b2v_inst2(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.rc_i(rc),
	.tc_i(tc),
	.pe_i(pe),
	.busy_i(busy),
	.cs_i(cs_i),
	.we_i(we_i),
	.adr_i(adr_i),
	.dat_i(dat_i),
	.receive_data_i(receive_data),
	.send_start_o(send_start),
	.ack_o(ack_o),
	.dat_o(dat_o),
	.send_data_o(send_data),
	.uart_brr_o(uart_brr),
	.uart_cr_o(uart_cr),
	.uart_sr_o(uart_sr));


InterruptController	b2v_inst3(
	.uart_cr_i(uart_cr),
	.uart_sr_i(uart_sr),
	.int_o(int_o));


Receive	b2v_inst4(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.baud_clk_i(receive_baud),
	.rx_i(rx_i),
	.uart_brr_i(uart_brr),
	.uart_cr_i(uart_cr),
	.rc_o(rc),
	.pe_o(pe),
	.baudgenerator_en_o(receive_baudgenerator_en),
	.data_o(receive_data));
	defparam	b2v_inst4.BIT0 = 2;
	defparam	b2v_inst4.BIT1 = 3;
	defparam	b2v_inst4.BIT2 = 4;
	defparam	b2v_inst4.BIT3 = 5;
	defparam	b2v_inst4.BIT4 = 6;
	defparam	b2v_inst4.BIT5 = 7;
	defparam	b2v_inst4.BIT6 = 8;
	defparam	b2v_inst4.BIT7 = 9;
	defparam	b2v_inst4.IDLE = 0;
	defparam	b2v_inst4.PARITY = 10;
	defparam	b2v_inst4.START = 1;
	defparam	b2v_inst4.STOP = 11;


Send	b2v_inst5(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.start_i(send_start),
	.baud_clk_i(send_baud),
	.data_i(send_data),
	.uart_cr_i(uart_cr),
	.tc_o(tc),
	.busy_o(busy),
	.baudgenerator_en_o(send_baudgenerator_en),
	.tx_o(tx_o));
	defparam	b2v_inst5.BIT0 = 2;
	defparam	b2v_inst5.BIT1 = 3;
	defparam	b2v_inst5.BIT2 = 4;
	defparam	b2v_inst5.BIT3 = 5;
	defparam	b2v_inst5.BIT4 = 6;
	defparam	b2v_inst5.BIT5 = 7;
	defparam	b2v_inst5.BIT6 = 8;
	defparam	b2v_inst5.BIT7 = 9;
	defparam	b2v_inst5.IDLE = 0;
	defparam	b2v_inst5.PARITY = 10;
	defparam	b2v_inst5.START = 1;
	defparam	b2v_inst5.STOP = 11;


endmodule
