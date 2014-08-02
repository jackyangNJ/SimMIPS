module KBCore(
				clk_i,
				rst_i,
				cs_i,
				we_i,
				dat_o,
				ack_o,
				adr_i,
				int_o,
				data,
				ready
);
input clk_i,rst_i;
/* Bus */
input cs_i,we_i;
output ack_o,int_o;
input [31:0] 	adr_i;
output [31:0] 	dat_o;
/* KBScan modle */
input ready;
input [7:0] data;

		reg intr;
		reg ack_o;
		reg [31:0] dat_o;
		reg [7:0] scan_code;
		
		always@(posedge clk_i)
		begin
			if(rst_i)	
				begin
					scan_code<=0;
					intr<=0;
					ack_o<=0;
					dat_o<=0;			
				end
			else
				begin
					if(cs_i)
						begin
							if(!we_i)  //bus read
								begin
									if(!adr_i[2])   //adr_i 0x0
										dat_o<={21'b0,intr};  			 //status register @0x0
									else      		//adr_i 0x4
										begin
											dat_o<={24'b0,scan_code};	//data register    @0x4
											intr<=0;
										end	
								end
							else   	//bus write
								begin
								end
							ack_o<=1'b1;
						end
					else
						begin
							ack_o<=1'b0;
							if(ready)
							begin
								scan_code<=data;
								intr<=1'b1;
							end	
						end	
				end
		end
	
	assign int_o=intr;
endmodule
