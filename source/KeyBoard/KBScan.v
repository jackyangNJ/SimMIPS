module KBScan(
			clk_i,
			rst_i,
			kb_clk_i,
			kb_dat_i,
			ready,
			data
);
input clk_i,rst_i;
/*KeyBoard*/
input kb_clk_i,kb_dat_i;
output ready;
output [7:0]data;
	
	reg[1:0] falling_detect;
	always@(posedge clk_i)	
		falling_detect<={falling_detect[0],kb_clk_i};
		
	reg [3:0]count;
	reg [7:0]data;
	reg [9:0]buffer;
	reg ready;
	always@(posedge clk_i)
	begin
		if(rst_i)  //reset 
			begin	
				count<=0;
				data<=0;
				buffer<=0;
			end
		else
			if(falling_detect==2'b10)  //get data from kb_dat_i when detect falling edge of kb_clk_i
				if(count==4'd10)
					begin
						if(kb_dat_i && (^buffer[9:1]) && ~buffer[0])  //check the data
							begin
								data<=buffer[8:1];
								ready<=1'b1;
							end	
						count<=0;
					end	
				else
					begin
						buffer[count]<=kb_dat_i;	
						count<=count+4'b1;
					end
			else
				ready<=0;
	end
endmodule
