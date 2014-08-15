module SinglePortRam
(
	input clk_i,
	input we_i,
	input [11:0] adr_i, 
	input [3:0] be_i, 
	input [31:0] dat_i,
	output[31:0] dat_o
);
	
	// use a multi-dimensional packed array
	//to model individual bytes within the word
	// (* ram_init_file = "ram_init.mif" *) logic [3:0][7:0] ram[0:4095];
	logic [3:0][7:0] ram[0:4095];
	integer i;
	initial
	begin
		for(i=0;i<4096;i=i+1)
			ram[i] = 0;
ram[0]=32'h3c01a000; 
ram[1]=32'h34210080; 
ram[2]=32'ha0200001; 
ram[3]=32'h24020080; 
ram[4]=32'ha0220003; 
ram[5]=32'h24020001; 
ram[6]=32'ha0220000; 
ram[7]=32'h24020003; 
ram[8]=32'ha0220003; 
ram[9]=32'h240200c7; 
ram[10]=32'ha0220002; 
ram[11]=32'h2402000b; 
ram[12]=32'ha0220004; 
ram[13]=32'h2402003d; 
ram[14]=32'ha0220000; 
ram[15]=32'h24020001; 
ram[16]=32'ha0220001; 
ram[17]=32'h24020031; 
ram[18]=32'ha0220000; 
ram[700]=32'h80230000;
ram[701]=32'h80230000;
ram[702]=32'h80230000;
ram[703]=32'h80230000;
ram[704]=32'h80230000;
ram[705]=32'h80230000;
ram[706]=32'h80230000;
ram[707]=32'h80230000;
ram[708]=32'h80230000;
ram[709]=32'h80230000;
ram[710]=32'h80230000;
ram[711]=32'h80230000;
ram[712]=32'h80230000;
ram[713]=32'h80230000;
ram[714]=32'h80230000;
ram[715]=32'h80230000;



	end
	
	reg[31:0] q;
	always_ff@(posedge clk_i)
	begin
	if(we_i) 
		begin
			if(be_i[0]) ram[adr_i][0] <= dat_i[7:0];
			if(be_i[1]) ram[adr_i][1] <= dat_i[15:8];
			if(be_i[2]) ram[adr_i][2] <= dat_i[23:16];
			if(be_i[3]) ram[adr_i][3] <= dat_i[31:24];
		end
		q <= ram[adr_i];
	end
	
	assign dat_o = q;
endmodule
