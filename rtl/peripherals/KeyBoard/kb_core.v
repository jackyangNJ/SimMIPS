module kb_core(
		input  clk_i,
		input  rst_i,
		input  stb_i,
		input  cyc_i,
		input  we_i,
		input [3:0] sel_i,
		output ack_o,
		output int_o,
		input  ready_i,
		input [31:0] adr_i,
		output[31:0] dat_o,
		input [7:0]  code_i
);

	reg intr;
	reg ack;
	reg [31:0] data_output;
	reg [7:0] scan_code;
	
	wire cs_i = cyc_i & stb_i;
	always@(posedge clk_i)
	begin
		if(rst_i)
			begin
				scan_code <= 0;
				intr  <= 0;
				ack <= 0;
				data_output <= 0;
			end
		else
			if(cs_i)
				begin
					if(!we_i)  //bus read
						begin
							if(sel_i[0])   //adr_i 0x0
								data_output<={24'b0,scan_code};	//data register    @0x4
								intr<=0;
						end
					ack <= 1'b1;
				end
			else
				begin
					ack <= 1'b0;
					if(ready_i)
						begin
							scan_code <= code_i;
							intr <= 1'b1;
						end	
				end
	end

	assign int_o = intr;
	assign ack_o = ack;
	assign dat_o = data_output;
endmodule
