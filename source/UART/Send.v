module Send(
			clk_i,
			rst_i,
			tc_o,
			busy_o,
			start_i,
			data_i,
			uart_cr_i,
			baud_clk_i,
			baudgenerator_en_o,
			tx_o
);
input clk_i,rst_i;
/* BusController */
input start_i;
input [7:0] data_i;
input [5:0] uart_cr_i;
output tc_o,busy_o;
/* BaudGenerator */
input baud_clk_i;
output baudgenerator_en_o;
/* UART */
output tx_o;

		reg [3:0] state;
		reg [8:0] data_reg;
		reg tc,busy,tx = 1'b1;
		reg baudgenerator_en;
		parameter IDLE=0,START=1,BIT0=2,BIT1=3,BIT2=4,BIT3=5,BIT4=6,BIT5=7,BIT6=8,BIT7=9,PARITY=10,STOP=11;
		wire CR_PCE=uart_cr_i[4];
		wire CR_PS=uart_cr_i[5];
		
		always@(posedge clk_i)
		begin
			if(rst_i)
				begin
					state<=0;
					data_reg<=0;
					tc<=0;
					busy<=0;
					tx<=1;
					baudgenerator_en<=0;
				end
			else
				begin
					case(state)
						IDLE:begin
								tc<=0;
								if(start_i)
									begin
										baudgenerator_en<=1;
										tx<=0;
										busy<=1;
										data_reg[7:0]<=data_i;
										if(CR_PS)  //bit PS
											data_reg[8]<=!(^data_i);  //odd parity
										else
											data_reg[8]<=^data_i;		//even parity
										state<=START;	
									end
							end
						START:begin
								if(baud_clk_i)state<=BIT0;
							end	
						BIT0:begin
								tx<=data_reg[0];
								if(baud_clk_i)	state<=BIT1;
							end
						BIT1:begin
								tx<=data_reg[1];
								if(baud_clk_i)	state<=BIT2;
							end
						BIT2:begin
								tx<=data_reg[2];
								if(baud_clk_i)	state<=BIT3;
							end
						BIT3:begin
								tx<=data_reg[3];
								if(baud_clk_i)	state<=BIT4;
							end
						BIT4:begin
								tx<=data_reg[4];
								if(baud_clk_i)	state<=BIT5;
							end
						BIT5:begin
								tx<=data_reg[5];
								if(baud_clk_i)	state<=BIT6;
							end
						BIT6:begin
								tx<=data_reg[6];
								if(baud_clk_i)	state<=BIT7;
							end	
						BIT7:begin
								tx<=data_reg[7];
								if(baud_clk_i)	state<=PARITY;
							end
						PARITY:begin
								if(CR_PCE)  //bit PCE
									begin
										tx<=data_reg[8];
										if(baud_clk_i)	state<=STOP;
									end		
								else	
									state<=STOP;
							end
						STOP:begin
								tx<=1;
								if(baud_clk_i) 
								begin	
									tc<=1;
									baudgenerator_en<=0;
									busy<=0;
									state<=IDLE;
								end	
							end
						default: state<=IDLE;	
					endcase
				end
		end
		
	assign baudgenerator_en_o=baudgenerator_en;
	assign tx_o=tx;
	assign tc_o=tc;
	assign busy_o=busy;
	
endmodule
