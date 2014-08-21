module kb_scan(
		input clk_i,
		input rst_i,
		input kb_clk_i,
		input kb_dat_i,
		output ready_o,
		output[7:0] code_o
);

	/* detect falling edge */
	reg[1:0] falling_detect;
	always@(posedge clk_i)
		falling_detect<={falling_detect[0],kb_clk_i};

	reg[3:0] count;
	reg[7:0] code;
	reg[9:0] buffer;
	reg ready;
	always@(posedge clk_i)
	begin
		if(rst_i)  //reset 
			begin
				count<=0;
				code<=0;
				buffer<=0;
			end
		else
			if(falling_detect==2'b10)  //get code from kb_dat_i when detect falling edge of kb_clk_i
				if(count==4'd10)
					begin
						if(kb_dat_i && (^buffer[9:1]) && ~buffer[0])  //check the code
							begin
								code <= buffer[8:1];
								ready<= 1'b1;
							end	
						count<=0;
					end	
				else
					begin
						buffer[count] <= kb_dat_i;
						count <= count + 1'b1;
					end
			else
				ready <= 0;
	end
	
	assign code_o = code;
	assign ready_o = ready;
endmodule
