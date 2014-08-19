/*
 * This is a simplified 8259A PIC
 * The int_o signal will last only one clock cycle
 */
module pic_top(
	input clk_i,
	input rst_i,
	input cyc_i,
	input stb_i,
	input we_i,
	input [3:0] sel_i,
	input [31:0] adr_i,
	input [31:0] dat_i,
	output[31:0] dat_o,
	output ack_o,
	output int_o,
	input [7:0] irq_i
);
	/* local parameters */
	localparam ST_IDLE = 3'd0;
	localparam ST_ICW1 = 3'd1;
	localparam ST_ICW2 = 3'd2;
	localparam ST_ICW3 = 3'd3;
	localparam ST_ICW4 = 3'd4;
	localparam ST_POLL = 3'd5;
	localparam ST_IRR  = 3'd6;
	localparam ST_ISR  = 3'd7;
	

	/* constant wires */
	wire cs_i = cyc_i & stb_i;
	wire icw_en_bit = dat_i[4];
	wire [1:0] ocw3_en = dat_i[4:3];
	wire icw1_ic4_needed = reg_command[0];
	wire [1:0] read_register_command = dat_i[1:0];
	wire poll_command = dat_i[2];

	/* internal registers */
	reg[7:0] reg_command;
	reg[7:0] reg_imr;
	reg[7:0] reg_isr;
	reg[7:0] reg_irr;
	
	/* bus write */
	reg ack;
	reg[2:0] state;
	reg[7:0] bus_data_out;
	always@(posedge clk_i)
	begin
		if(rst_i)
			begin
				reg_command <= 0;
				reg_imr <= 0;
				reg_isr <= 0;
				ack <= 0;
				state <= ST_IDLE;
			end
		else
			begin
				if(cs_i)
					begin
						ack <= 1'b1
						if(we_i)
							case(sel_i)
								4'b0001:
									begin
										reg_command <= dat_i[7:0];
										if(icw_en_bit == 1'b1)
											state <= ST_ICW2;
										else
											if(poll_command)
												state <= ST_POLL;
											else
												if(read_register_command == 2'b10)
													state <= ST_IRR;
												else
													if(read_register_command == 2'b11)
														state <= ST_ISR;
									end
								4'b0010:
									begin
										case(state)
											ST_IDLE:
												reg_imr <= dat_i[7:0];
											ST_ICW1:
												state <= ST_ICW2;
											ST_ICW2:
												state <= ST_ICW3;
											ST_ICW3:
												if(icw1_ic4_needed)
													state <= ST_ICW4;
												else
													state <= ST_IDLE;
											ST_ICW4:
												state <= ST_IDLE;
										endcase
									end
							endcase
						else
							case(sel_i)
								4'b0001:
									case(state)
										ST_POLL:
											begin
												bus_data_out <= {5'b0,int_code};
												state <= ST_IDLE;
											end
										ST_IRR:
											begin
												bus_data_out <= reg_irr;
												state <= ST_IDLE;
											end
										ST_ISR:
											begin
												bus_data_out <= reg_isr;
												state <= ST_IDLE;
											end
									endcase
								4'b0010:
								
							endcase
					end
				else
					ack <= 0;
			end
	end
	
	/* detect external int,default rising edge */
	integer i;
	reg[7:0] irq,irq_old;
	always@(posedge clk_i)
	begin
		irq_old <= irq;
		irq <= irq_i;
		for(i=0;i<8;i=i+1)
			reg_irr[i] = !irq_old[i] && irq[i];
		reg_isr <= reg_irr;
	end
	
	reg[2:0] int_code;
	always@(reg_isr)
	begin
		casex(reg_isr)
			8'bxxxxxxx1: int_code = 3'd0;
			8'bxxxxxx10: int_code = 3'd1;
			8'bxxxxx100: int_code = 3'd2;
			8'bxxxx1000: int_code = 3'd3;
			8'bxxx10000: int_code = 3'd4;
			8'bxx100000: int_code = 3'd5;
			8'bx1000000: int_code = 3'd6;
			8'b10000000: int_code = 3'd7;
			default: int_code = 3'd0;
		endcase
	end

endmodule