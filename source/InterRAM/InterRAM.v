module InterRAM(
			clk_i,
			rst_i,
			cs_i,
			we_i,
			adr_i,
			dat_i,
			dat_o,
			ack_o
			
);
input clk_i,rst_i;
/* Bus */
input cs_i,we_i;
input [31:0] adr_i,dat_i;
output [31:0] dat_o;
output ack_o;



	reg ack;
	always@(posedge clk_i)
	begin
		if(rst_i)
			ack<=0;
		else
			begin
				if(cs_i)
					ack<=1;
				else
					ack<=0;
			end
	end	
	/* M4K RAM */
	InterRAMM4K ram(
			.address(adr_i[15:2]),
			.clock(clk_i),
			.data(dat_i),
			.wren(we_i& cs_i),
			.q(dat_o)
	);

	assign ack_o=ack;
endmodule
