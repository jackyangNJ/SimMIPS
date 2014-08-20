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
ram[1]=32'h27bd1284; 
ram[2]=32'h3c198000; 
ram[3]=32'h27390234; 
ram[4]=32'h0320f809; 
ram[5]=32'h1000ffff; 
ram[6]=32'h27bdfff8; 
ram[7]=32'hafbe0004; 
ram[8]=32'h03a0f021; 
ram[9]=32'h00801021; 
ram[10]=32'ha7c20008; 
ram[11]=32'h97c30008; 
ram[12]=32'h3c02b800; 
ram[13]=32'h00621021; 
ram[14]=32'h90420000; 
ram[15]=32'h304200ff; 
ram[16]=32'h03c0e821; 
ram[17]=32'h8fbe0004; 
ram[18]=32'h27bd0008; 
ram[19]=32'h03e00008; 
ram[20]=32'h00000000; 
ram[21]=32'h27bdfff8; 
ram[22]=32'hafbe0004; 
ram[23]=32'h03a0f021; 
ram[24]=32'h00801821; 
ram[25]=32'h00a01021; 
ram[26]=32'ha7c30008; 
ram[27]=32'ha3c2000c; 
ram[28]=32'h97c30008; 
ram[29]=32'h3c02b800; 
ram[30]=32'h00621021; 
ram[31]=32'h93c3000c; 
ram[32]=32'ha0430000; 
ram[33]=32'h03c0e821; 
ram[34]=32'h8fbe0004; 
ram[35]=32'h27bd0008; 
ram[36]=32'h03e00008; 
ram[37]=32'h00000000; 
ram[38]=32'h27bdffe8; 
ram[39]=32'hafbf0014; 
ram[40]=32'hafbe0010; 
ram[41]=32'h03a0f021; 
ram[42]=32'h240403f9; 
ram[43]=32'h00002821; 
ram[44]=32'h0c000015; 
ram[45]=32'h00000000; 
ram[46]=32'h240403fb; 
ram[47]=32'h24050080; 
ram[48]=32'h0c000015; 
ram[49]=32'h00000000; 
ram[50]=32'h240403f8; 
ram[51]=32'h24050001; 
ram[52]=32'h0c000015; 
ram[53]=32'h00000000; 
ram[54]=32'h240403f9; 
ram[55]=32'h00002821; 
ram[56]=32'h0c000015; 
ram[57]=32'h00000000; 
ram[58]=32'h240403fb; 
ram[59]=32'h24050003; 
ram[60]=32'h0c000015; 
ram[61]=32'h00000000; 
ram[62]=32'h240403fa; 
ram[63]=32'h240500c7; 
ram[64]=32'h0c000015; 
ram[65]=32'h00000000; 
ram[66]=32'h240403fc; 
ram[67]=32'h2405000b; 
ram[68]=32'h0c000015; 
ram[69]=32'h00000000; 
ram[70]=32'h03c0e821; 
ram[71]=32'h8fbf0014; 
ram[72]=32'h8fbe0010; 
ram[73]=32'h27bd0018; 
ram[74]=32'h03e00008; 
ram[75]=32'h00000000; 
ram[76]=32'h27bdffe8; 
ram[77]=32'hafbf0014; 
ram[78]=32'hafbe0010; 
ram[79]=32'h03a0f021; 
ram[80]=32'h240403fd; 
ram[81]=32'h0c000006; 
ram[82]=32'h00000000; 
ram[83]=32'h30420020; 
ram[84]=32'h0002102b; 
ram[85]=32'h304200ff; 
ram[86]=32'h03c0e821; 
ram[87]=32'h8fbf0014; 
ram[88]=32'h8fbe0010; 
ram[89]=32'h27bd0018; 
ram[90]=32'h03e00008; 
ram[91]=32'h00000000; 
ram[92]=32'h27bdffe8; 
ram[93]=32'hafbf0014; 
ram[94]=32'hafbe0010; 
ram[95]=32'h03a0f021; 
ram[96]=32'h00801021; 
ram[97]=32'ha3c20018; 
ram[98]=32'h00000000; 
ram[99]=32'h0c00004c; 
ram[100]=32'h00000000; 
ram[101]=32'h00401821; 
ram[102]=32'h24020001; 
ram[103]=32'h1462fffb; 
ram[104]=32'h00000000; 
ram[105]=32'h93c20018; 
ram[106]=32'h240403f8; 
ram[107]=32'h00402821; 
ram[108]=32'h0c000015; 
ram[109]=32'h00000000; 
ram[110]=32'h03c0e821; 
ram[111]=32'h8fbf0014; 
ram[112]=32'h8fbe0010; 
ram[113]=32'h27bd0018; 
ram[114]=32'h03e00008; 
ram[115]=32'h00000000; 
ram[116]=32'h27bdffe8; 
ram[117]=32'hafbf0014; 
ram[118]=32'hafbe0010; 
ram[119]=32'h03a0f021; 
ram[120]=32'hafc40018; 
ram[121]=32'h08000083; 
ram[122]=32'h00000000; 
ram[123]=32'h8fc20018; 
ram[124]=32'h90420000; 
ram[125]=32'h00402021; 
ram[126]=32'h0c00005c; 
ram[127]=32'h00000000; 
ram[128]=32'h8fc20018; 
ram[129]=32'h24420001; 
ram[130]=32'hafc20018; 
ram[131]=32'h8fc20018; 
ram[132]=32'h90420000; 
ram[133]=32'h1440fff5; 
ram[134]=32'h00000000; 
ram[135]=32'h03c0e821; 
ram[136]=32'h8fbf0014; 
ram[137]=32'h8fbe0010; 
ram[138]=32'h27bd0018; 
ram[139]=32'h03e00008; 
ram[140]=32'h00000000; 
ram[141]=32'h27bdffe8; 
ram[142]=32'hafbf0014; 
ram[143]=32'hafbe0010; 
ram[144]=32'h03a0f021; 
ram[145]=32'h0c000026; 
ram[146]=32'h00000000; 
ram[147]=32'h3c028000; 
ram[148]=32'h24440274; 
ram[149]=32'h0c000074; 
ram[150]=32'h00000000; 
ram[151]=32'h03c0e821; 
ram[152]=32'h8fbf0014; 
ram[153]=32'h8fbe0010; 
ram[154]=32'h27bd0018; 
ram[155]=32'h03e00008; 
ram[156]=32'h00000000; 
ram[157]=32'h6c6c6548; 
ram[158]=32'h6f77206f; 
ram[159]=32'h21646c72; 
ram[160]=32'h0000000a; 


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
