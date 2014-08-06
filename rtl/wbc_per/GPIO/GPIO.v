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
				reg_ctrl <=  8'hff; //default direction is output
				reg_data <=  8'h0;
				ack <= 0;
			end
		else
			/* wb write */
			if(wb_acc)
				begin
					ack <= 1'b1;
					if(we_i)
						case(adr_i[2])
							1'b0:
								reg_data <=  dat_i[7:0];
							1'b1:
								reg_ctrl <=  dat_i[7:0];
						endcase
				end
			else
				begin
					ack <= 1'b0;
					for(i=0;i<8;i=i+1)
						if(!reg_ctrl[i])
							reg_data[i] <=  gpio_pin[i];
				end
	end

	/* wb read */
	reg[31:0] data;
	always@(*)
	begin
		case(adr_i[2])
			1'b0:
				data = {24'b0,reg_data};
			1'b1:
				data = {24'b0,reg_ctrl};
		endcase
	end
	

	assign dat_o = data;
	assign gpio_pin[0] = reg_ctrl[0] ? reg_data[0] : 1'bz;
	assign gpio_pin[1] = reg_ctrl[1] ? reg_data[1] : 1'bz;
	assign gpio_pin[2] = reg_ctrl[2] ? reg_data[2] : 1'bz;
	assign gpio_pin[3] = reg_ctrl[3] ? reg_data[3] : 1'bz;
	assign gpio_pin[4] = reg_ctrl[4] ? reg_data[4] : 1'bz;
	assign gpio_pin[5] = reg_ctrl[5] ? reg_data[5] : 1'bz;
	assign gpio_pin[6] = reg_ctrl[6] ? reg_data[6] : 1'bz;
	assign gpio_pin[7] = reg_ctrl[7] ? reg_data[7] : 1'bz;
	
	assign ack_o = ack;
	
endmodule

