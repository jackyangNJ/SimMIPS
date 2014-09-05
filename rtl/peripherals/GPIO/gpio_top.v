module gpio_top(
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
	inout [31:0]  gpio_pin
);

 
  //
  // Module body
  //
  reg [31:0] reg_ctrl;
  reg [31:0] reg_data;

  // WISHBONE interface

	wire cs_i = cyc_i & stb_i;            // WISHBONE access
	reg ack;
	
	integer i;
	always @(posedge clk_i)
	begin
		if(rst_i)
			begin
				reg_ctrl <=  0; //default direction is input
				reg_data <=  0;
				ack <= 0;
			end
		else
			/* wb write */
			if(cs_i)
				begin
					ack <= 1'b1;
					if(we_i)
						case(adr_i[2])
							1'b0:
								for(i=0;i<4;i=i+1)
									if(sel_i[i]) reg_data[i*8 +:8] <= dat_i[i*8 +:8];
							1'b1:
								for(i=0;i<4;i=i+1)
									if(sel_i[i]) reg_ctrl[i*8 +:8] <= dat_i[i*8 +:8];
						endcase
				end
			else
				begin
					ack <= 0;
					for(i=0;i<32;i=i+1)
						if(!reg_ctrl[i])
							reg_data[i] <=  gpio_pin[i];
				end
	end

	generate
         genvar ii;
         for(ii=0; ii<32 ; ii=ii+1) 
         begin :assign_trig
               assign gpio_pin[ii] = reg_ctrl[ii] ? reg_data[ii] : 1'bz;
         end
	endgenerate

	assign dat_o = adr_i[2] ? reg_ctrl : reg_data;
	assign ack_o = ack;
	
endmodule

