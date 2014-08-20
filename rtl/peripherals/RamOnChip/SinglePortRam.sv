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
ram[0]=32'h3c1d8000; 
ram[1]=32'h27bd10f0; 
ram[2]=32'h3c198000; 
ram[3]=32'h273900b4; 
ram[4]=32'h0320f809; 
ram[5]=32'h1000ffff; 
ram[6]=32'h3c02b800; 
ram[7]=32'h2404ff80; 
ram[8]=32'ha04003f9; 
ram[9]=32'h24030001; 
ram[10]=32'ha04403fb; 
ram[11]=32'h24040003; 
ram[12]=32'ha04303f8; 
ram[13]=32'ha04003f9; 
ram[14]=32'ha04403fb; 
ram[15]=32'h2404ffc7; 
ram[16]=32'ha04403fa; 
ram[17]=32'h2404000b; 
ram[18]=32'ha04403fc; 
ram[19]=32'ha04303f9; 
ram[20]=32'h03e00008; 
ram[21]=32'h00000000; 
ram[22]=32'h308400ff; 
ram[23]=32'h3c02b800; 
ram[24]=32'h904303fd; 
ram[25]=32'h30630020; 
ram[26]=32'h1060fffd; 
ram[27]=32'h00000000; 
ram[28]=32'ha04403f8; 
ram[29]=32'h03e00008; 
ram[30]=32'h00000000; 
ram[31]=32'h90860000; 
ram[32]=32'h10c0000a; 
ram[33]=32'h3c02b800; 
ram[34]=32'h904303fd; 
ram[35]=32'h30630020; 
ram[36]=32'h1060fffd; 
ram[37]=32'h00000000; 
ram[38]=32'ha04603f8; 
ram[39]=32'h24840001; 
ram[40]=32'h90860000; 
ram[41]=32'h14c0fff8; 
ram[42]=32'h00000000; 
ram[43]=32'h03e00008; 
ram[44]=32'h00000000; 
ram[45]=32'h27bdffe8; 
ram[46]=32'hafbf0014; 
ram[47]=32'h0c000006; 
ram[48]=32'h00000000; 
ram[49]=32'h3402ff01; 
ram[50]=32'h40826000; 
ram[51]=32'h3c048000; 
ram[52]=32'h8fbf0014; 
ram[53]=32'h248400e0; 
ram[54]=32'h0800001f; 
ram[55]=32'h27bd0018; 
ram[56]=32'h6c6c6548; 
ram[57]=32'h6f77206f; 
ram[58]=32'h21646c72; 
ram[59]=32'h0000000a; 


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
