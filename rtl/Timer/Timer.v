module Timer(
				clk_i,
				rst_i,
				cs_i,
				we_i,
				dat_i,
				dat_o,
				adr_i,
				ack_o,
				int_o
);
input clk_i,rst_i;
/* Bus */
input cs_i,we_i;
input [31:0] dat_i,adr_i;
output[31:0] dat_o;
output ack_o;
/* CPU Core */
output int_o;

/* internal registers */
	reg [31:0] VAL,LOAD;
	reg [3:0] CTRL;
	reg ack;
	reg [31:0] dat_o;
	
	/* CTRL Register*/
	always@(posedge clk_i)
	begin
		if(rst_i)	CTRL<=0;
		else
			if(!cs_i & (adr_i[3:2]==2'b00))
				begin
					if(we_i)  //bus write
							begin
								CTRL[0]<=dat_i[0];     		//CTRL->EN
								if(!dat_i[1]) CTRL[1]<=0;	//CTRL->TI
								CTRL[2]<=dat_i[2];			//CTRL->TIE
								if(!dat_i[3]) CTRL[3]<=0;	//CTRL->CF
							end
				end	
			else
				if(VAL==32'b1)
					begin
						if(CTRL[2]) CTRL[1]<=1;  //CTRL->TI
						CTRL[3]<=1;  //CTRL->CF
					end
	end
	
	/* LOAD Register*/
	always@(posedge clk_i)
	begin
	if(rst_i) LOAD<=0;
	else
		if(!cs_i &(adr_i[3:2]==2'b01) & we_i & !CTRL[0])
			LOAD<=dat_i;   //CTRL[0] is CTRL->EN
	end
	
	/* VAL Register */
	always@(posedge clk_i)
	begin
		if(rst_i) VAL<=0;
		else
			if(!cs_i & (adr_i[3:2]==2'b10) & we_i & !CTRL[0])
				VAL<=dat_i;   
			else
				if(CTRL[0])
					if(VAL == 0)
						VAL<=LOAD;
					else
						VAL<=VAL-32'b1;			
	end
	
	/* ack,dat_o registers*/
	always@(posedge clk_i)
	begin
	if(rst_i)
		begin
			ack<=0;
			dat_o<=0;
		end	
	else
		begin
			if(!cs_i) ack<=1;
			else    	 ack<=0;
			case(adr_i[3:2])
				2'b00: dat_o<={28'b0,CTRL};
				2'b01: dat_o<=LOAD;
				2'b10: dat_o<=VAL;
			endcase		
		end	
	end
	
	assign ack_o=ack;
	assign int_o=CTRL[1] &CTRL[0];
endmodule
