module BusController(
						clk_i,
						rst_i,
						rc_i,
						tc_i,
						pe_i,
						busy_i,
						receive_data_i,
						uart_sr_o,
						uart_cr_o,
						uart_brr_o,
						send_start_o,
						send_data_o,
						cs_i,
						we_i,
						dat_i,
						dat_o,
						ack_o,
						adr_i
);
input clk_i,rst_i;
/* Send */
input tc_i,busy_i;
output send_start_o;
output[7:0] send_data_o;
/* Receive */
input rc_i,pe_i;
input [7:0] receive_data_i;
/* Bus */
input cs_i,we_i;
output ack_o;
input [31:0] adr_i,dat_i;
output [31:0] dat_o;
/* Registers output*/
output [3:0] uart_sr_o;
output [5:0] uart_cr_o;
output [15:0] uart_brr_o;


	/* internal registers*/
	reg [7:0] 	TDR,RDR;
	reg [15:0] 	UART_BRR;
	reg [3:0] 	UART_SR;
	reg [5:0]	UART_CR;
	reg 			send_data;
	reg ack;
	reg [31:0]  dat_o;
	always@(posedge clk_i)
	begin
		if(rst_i)
			begin
				TDR<=0;
				RDR<=0;
				UART_BRR<=0;
				UART_CR<=0;
				UART_SR<=0;
				send_data<=0;
				ack<=0;
			end
		else
			begin
				if(!cs_i)
					begin
						if(we_i)  //bus write
							begin
								case(adr_i[3:2])
									2'b00:begin
											if(!dat_i[0]) UART_SR[0]<=0;
											if(!dat_i[1]) UART_SR[1]<=0;
											if(!dat_i[2]) UART_SR[2]<=0;
											ack<=1;	
										end
									2'b01:begin
											TDR<=dat_i[7:0];
											if(UART_CR[0] & !UART_SR[3] & !ack)  //bit UE and busy
											begin
												send_data<=1;
												ack<=1;
											end	
										end
									2'b10:begin
											if(!UART_CR[0])  //bit UE
												UART_BRR<=dat_i[15:0];
											ack <= 1;	
											end	
											
									2'b11:begin	
											UART_CR<=dat_i[5:0];
											ack<=1;
										end
								endcase
							end
						else 		//bus read
							begin
								case(adr_i[3:2])
									2'b00: dat_o<={28'b0,UART_SR};
									2'b01: dat_o<={24'b0,RDR};
									2'b10: dat_o<={16'b0,UART_BRR};
									2'b11: dat_o<={26'b0,UART_CR};
								endcase
								ack<=1;
							end
					end
				else
					begin
						ack<=0;					
						if(tc_i& UART_CR[2]) UART_SR[0]<=1;  //bit TC
						if(rc_i & UART_CR[1]) 
						begin
							UART_SR[1]<=1; 		 //bit RC
							RDR<=receive_data_i;
						end	
						if(pe_i & UART_CR[3]) UART_SR[2]<=1;  //bit PE
					end
				if(busy_i) 
					begin
						send_data<=0;
						UART_SR[3]<=1;  		 //bit busy
					end	
				else
					UART_SR[3]<=0;	
			end
	end
	
	assign send_start_o=send_data;
	assign send_data_o=TDR;
	assign ack_o=ack;
	assign uart_brr_o=UART_BRR;
	assign uart_cr_o=UART_CR;
	assign uart_sr_o=UART_SR;
endmodule
