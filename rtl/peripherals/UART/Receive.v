module Receive(
				clk_i,
				rst_i,
				rc_o,
				pe_o,
				data_o,
				uart_brr_i,
				uart_cr_i,
				baud_clk_i,
				baudgenerator_en_o,
				rx_i
);
input clk_i,rst_i;
/* BusController */
input [5:0]  	uart_cr_i;
input [15:0] 	uart_brr_i;
output rc_o,pe_o;
output [7:0] 	data_o;
/* BaudGenerator */
input baud_clk_i;
output baudgenerator_en_o;
/* UART */
input rx_i;



		/*internal registers*/
		reg [15:0]	count;
		reg [8:0] 	data_reg;
		reg [3:0] 	state;
		reg [1:0] 	falling_detect;
		reg baudgenerator_en;
		reg pe,rc;
		parameter IDLE=0,START=1,BIT0=2,BIT1=3,BIT2=4,BIT3=5,BIT4=6,BIT5=7,BIT6=8,BIT7=9,PARITY=10,STOP=11;
		wire CR_PCE=uart_cr_i[4];
		wire CR_PS=uart_cr_i[5];
		wire CR_UE=uart_cr_i[0];
		/*detect falling edge of rx_i*/
		always@(posedge clk_i)
			if(rst_i)
				falling_detect<=0;
			else
				falling_detect<={falling_detect[0],rx_i};
		
 		always@(posedge clk_i)
		begin
			if(rst_i)
				begin
					count<=0;
					data_reg<=0;
					state<=0;
					baudgenerator_en<=0;
					pe<=0;
					rc<=0;
				end
			else
				begin
					case(state)
						IDLE:begin
								pe<=0;
								rc<=0;
								if(falling_detect==2'b10 && CR_UE)  //bit UE
									state<=START;	
							end
						START:begin
								if(count==uart_brr_i[15:1])
									if(!rx_i)
										begin
											baudgenerator_en<=1;
											count<=0;
											state<=BIT0;
										end	
									else
										state<=IDLE;
								else
									count<=count+1'b1;
							end	
						BIT0:begin
								if(baud_clk_i)	
								begin
									state<=BIT1;
									data_reg[0]<=rx_i;
								end	
							end
						BIT1:begin
								if(baud_clk_i)	
								begin
									state<=BIT2;
									data_reg[1]<=rx_i;
								end	
							end
						BIT2:begin
								if(baud_clk_i)	
								begin
									state<=BIT3;
									data_reg[2]<=rx_i;
								end	
							end
						BIT3:begin
								if(baud_clk_i)	
								begin
									state<=BIT4;
									data_reg[3]<=rx_i;
								end	
							end
						BIT4:begin
								if(baud_clk_i)	
								begin
									state<=BIT5;
									data_reg[4]<=rx_i;
								end	
							end
						BIT5:begin
								if(baud_clk_i)	
								begin
									state<=BIT6;
									data_reg[5]<=rx_i;
								end	
							end
						BIT6:begin
								if(baud_clk_i)	
								begin
									state<=BIT7;
									data_reg[6]<=rx_i;
								end	
							end	
						BIT7:begin
								if(baud_clk_i)	
								begin
									state<=PARITY;
									data_reg[7]<=rx_i;
								end	
							end
						PARITY:begin
								if(CR_PCE)  //bit PCE
									begin
										if(baud_clk_i)
											begin
												data_reg[8]<=rx_i;
												state<=STOP;
											end		
									end		
								else	
									state<=STOP;
							end
						STOP:begin
								if(baud_clk_i)
									begin
										rc<=1;
										baudgenerator_en<=0;
										if(CR_PCE)  //bit PCE
											if(data_reg[8] != (CR_PS^(^data_reg[7:0])))   //check parity
												pe<=1;
										state<=IDLE;
									end	
							end	
						default: state<=IDLE;	
					endcase	
				end
		end
		
		assign pe_o=pe;
		assign rc_o=rc;
		assign baudgenerator_en_o=baudgenerator_en;
		assign data_o=data_reg[7:0];
endmodule
