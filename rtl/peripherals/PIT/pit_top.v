/*
 * 
 */
module pit_top
#(
	parameter CLOCK_FREQ = 50000000
)
(
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
	output int_o
);


	/* internal registers */
	reg[7:0] reg_mode;
	reg [15:0] reg_divisor; 
	
	localparam PIT_CLOCK_FREQ = 14318180;
	localparam MODE_DEFAULT = 8'h34;
	localparam ST_IDLE  = 2'd0;
	localparam ST_WR_LO = 2'd1;
	localparam ST_WR_HI = 2'd2;
	localparam ST_RD_LO = 2'd1;
	localparam ST_RD_HI = 2'd2;
	wire cs_i = stb_i & cyc_i;
	
	reg [1:0] state_wr;
	reg ack;
	/* bus write */
	always@(posedge clk_i)
	begin
		if(rst_i)
			begin
				reg_mode <= 0;
				reg_divisor <= 0;
				state_wr <= ST_IDLE;
			end
		else
			if(cs_i)
				begin
					ack = 1'b1;
					if(we_i)
						case(sel_i)
							4'b1000:
								if(dat_i[7:0] == MODE_DEFAULT)
									begin
										state_wr <= ST_WR_LO;
										reg_mode <= dat_i[7:0];
									end
							4'b0001:
								case(state_wr)
									ST_WR_LO:
										begin
											reg_divisor[7:0]  <= dat_i[7:0];
											state_wr <= ST_WR_HI;
										end
									ST_WR_HI:
										begin
											reg_divisor[15:8] <= dat_i[7:0];
											state_wr <= ST_IDLE;
										end
								endcase
						endcase
				end
			else
				ack <= 0;
	end

	/* bus read */
	reg [1:0] state_rd;
	reg[7:0] data_out;
	always@(posedge clk_i)
	begin
		if(rst_i)
			state_rd <= ST_IDLE;
		else
			begin
				if(cs_i && !we_i)
					case(sel_i)
						4'b1000: data_out <= reg_mode;
						4'b0001: 
							case(state_rd)
								ST_IDLE:
									if(reg_mode == MODE_DEFAULT)
										begin
											data_out <= reg_divisor[7:0];
											state_rd <= ST_RD_HI;
										end
								ST_RD_LO:
									begin
										data_out <= reg_divisor[7:0];
										state_rd <= ST_RD_HI;
									end
								ST_RD_HI:
									begin
										data_out <= reg_divisor[15:8];
										state_rd <= ST_RD_LO;
									end
							endcase
					endcase
					
			end
	end

	wire counter_clk;
	clock_generator #(
		.CLOCK_IN_FREQ   (CLOCK_FREQ),
		.CLOCK_OUT_FREQ  (PIT_CLOCK_FREQ/12)
	) clock_counter(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.clk_o(counter_clk)
	);
	
	reg [15:0] counter;
	always@(posedge counter_clk)
	begin
		if(rst_i)
			counter <= 0;
		else
			if(counter == reg_divisor)
				counter <= 0;
			else
				counter <= counter + 1'b1;
	end
	
	assign int_o = (reg_mode == MODE_DEFAULT && counter == reg_divisor);
	assign dat_o = {24'b0,data_out};
	assign ack_o = ack;
endmodule
