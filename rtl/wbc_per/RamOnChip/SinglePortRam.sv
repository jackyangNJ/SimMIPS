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
ram[0]=32'h2401000c; 
ram[1]=32'h2402000d; 
ram[2]=32'h2403000e; 
ram[3]=32'h004c180b; 
ram[4]=32'h0040080a; 
ram[5]=32'h3c018000; 
ram[6]=32'h3c027123; 
ram[7]=32'h34424455; 
ram[8]=32'h240338d2; 
ram[9]=32'h2404007b; 
ram[10]=32'h70645002; 
ram[11]=32'h00220019; 
ram[12]=32'h00002812; 
ram[13]=32'h00003010; 
ram[14]=32'h00220018; 
ram[15]=32'h00002812; 
ram[16]=32'h00003010; 
ram[17]=32'h3c018000; 
ram[18]=32'h3c020003; 
ram[19]=32'h34424455; 
ram[20]=32'h0022001a;
ram[21]=32'h00002812; 
ram[22]=32'h00003010; 
ram[23]=32'h0022001b; 
ram[24]=32'h00000812; 
ram[25]=32'h00002812; 
ram[26]=32'h00003010; 

		
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
