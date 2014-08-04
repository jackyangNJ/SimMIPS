module GPIO(
	input clk_i,
	input rst_i,
	input        cyc_i,
	input        stb_i,
	input [31:0] adr_i,
	input        we_i, 
	input [3:0]  sel_i,
	input [31:0] dat_i,
	output[31:0] dat_o,
	output       ack_o,
	inout [7:0]  gpio_pin
);

 
  //
  // Module body
  //
  reg [7:0] reg_ctrl;
  reg [7:0] reg_data;


  // WISHBONE interface

	wire wb_acc = cyc_i & stb_i;            // WISHBONE access
	reg ack;
	integer i;
	always @(posedge clk_i)
	begin
		if(rst_i)
			begin
				reg_ctrl <= #1 0;
				reg_data <= #1 0;
				ack <= 0;
			end
		else
			/* wb write */
			if(wb_acc)
				begin
					ack <= 1'b1;
					if(we_i)
						case(adr_i[0])
							1'b0:
								reg_data <= #1 dat_i[7:0];
							1'b1:
								reg_ctrl <= #1 dat_i[7:0];
						endcase
				end
			else
				begin
					ack <= 1'b0;
					for(i=0;i<8;i=i+1)
						if(!reg_ctrl[i])
							reg_data[i] <= gpio_pin[i];
				end
	end

	/* wb read */
	reg[31:0] data;
	always@(*)
	begin
		case(adr_i[0])
			1'b0:
				data = reg_data;
			1'b1:
				data = reg_ctrl;
		endcase
	end
	
	reg[7:0] gpio_t;
	always@(*)
	begin
		for(i=0;i<8;i=i+1)
			gpio_t[i] = reg_ctrl[i] ? reg_data[i] : 1'bz;
	end
	
	assign dat_o = data;
	assign gpio_pin = gpio_t;
	assign ack_o = ack;
	
endmodule

