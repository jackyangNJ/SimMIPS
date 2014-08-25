module sdram_top(
	input clk_sys,
	input clk_ram,
	input rst_i,
	input stb_i,
	input cyc_i,
	input we_i,
	input [3:0] sel_i,
	input [31:0]dat_i,
	input [31:0]adr_i,
	output ack_o,
	output [31:0]dat_o,
	inout [31:0]DRAM_DQ,
	output [12:0]oDRAM0_A,
	output [12:0]oDRAM1_A,
	output oDRAM0_LDQM0, 
	output oDRAM0_UDQM1,
	output oDRAM1_LDQM0,
	output oDRAM1_UDQM1,
	output oDRAM0_WE_N,
	output oDRAM1_WE_N,
	output oDRAM0_CAS_N,
	output oDRAM1_CAS_N,
	output oDRAM0_RAS_N,
	output oDRAM1_RAS_N,
	output oDRAM0_CS_N,
	output oDRAM1_CS_N,
	output [1:0]oDRAM0_BA,
	output [1:0]oDRAM1_BA,
	output oDRAM0_CLK,
	output oDRAM1_CLK,
	output oDRAM0_CKE,
	output oDRAM1_CKE
);
	wire dram_dq;
	reg ack;
	reg [31:0]ram2bus_data_buf;
	reg [12:0]dram_a;
	
	
	wire dram_we_n;
	wire dram_cas_n;
	wire dram_ras_n;
	wire dram_cs_n;
	
	reg [3:0] Command;
	reg [3:0]dram_dqm;
	reg [1:0]dram_ba;
	
	reg [2:0]external_state;
	reg [2:0]internal_state;
	
	reg [4:0]counter;
	reg [14:0]timer;
	
	localparam INIT=3'd0,RUN=3'd1,READ=3'd2,WRITE=3'd3,PRECHARGE=3'd4;
	localparam C_NOP=4'b0111,C_DESL=4'b1000,C_PRE=4'b0010,C_REF=4'b0001,C_MRS=4'b0000,C_READ=4'b0101,C_WRITE=4'b0100,C_ACT=4'b0011;
	
	
	wire cs_i = stb_i & cyc_i;
	always @ (posedge clk_sys) begin
		if (rst_i) begin
			external_state <= INIT;
			internal_state <= 3'd0;
			counter <= 5'd0;
			timer <= 15'd0;
			ack <= 1'b0;
		end
		else
			begin
				case(external_state)
					INIT:begin
						case(internal_state)
						3'd0: begin		/* 200us C_NOP */
							timer <= timer + 1'b1;
							if (timer == 15'd20000) begin   //refresh interval 20000
								internal_state <= 3'd1;
								timer <= 15'd0;
							end
						end
						3'd1: internal_state <= 3'd2;
						3'd2: internal_state <= 3'd3;
						3'd3: begin				
							counter <= counter + 1'b1;
							if (counter == 5'd7) begin
								counter <= 5'd0;
								timer <= timer + 1'b1;
							end
									
							if (timer == 15'd8) begin
								timer <= 15'd0;
								counter <= 5'd0;
								internal_state <=  3'd4;
							end
						end
						3'd4: internal_state <= 3'd5;
						3'd5:begin	/*DELAY*/
							external_state <= RUN;
							internal_state <= 3'd0;
						end	
						default: internal_state <= 3'd0;
						endcase
					end
					
					RUN: begin	//run
						case(internal_state)
							3'd0: begin
								timer <= timer + 1'b1;
								if (timer >= 700) begin   //750
									timer <= 15'd0;
									internal_state <= 3'd1;
								end
								else begin
									if(!cs_i) ack <= 0;
									else begin
										if(cs_i && !ack)
											if (we_i == 1'b0) begin
													external_state <= READ;
													internal_state <= 3'd0;
											end
											else begin
													external_state <= WRITE;
													internal_state <= 3'd0;
											end
									end
								end
							end
							3'd1: begin	
								counter <= counter + 1'b1;
								if (counter >= 5'd7) begin
									internal_state <= 3'd0;
									counter <= 5'd0;
								end
							end
							default: internal_state <= 3'd0;
						endcase
					end
					
					READ: begin //read
						timer <= timer + 1'b1;
						case(internal_state)
						3'd0: internal_state <= 3'd1;
						3'd1: internal_state <= 3'd2;
						3'd2: internal_state <= 3'd3;
						3'd3: begin internal_state <= 3'd4;	end
						3'd4: begin internal_state <= 3'd5;	end
						3'd5: begin
							ram2bus_data_buf <= DRAM_DQ;
							internal_state <= 3'd0;
							external_state <= PRECHARGE;
						end
						default: internal_state <= 3'd0;
						endcase
					end
					
					WRITE: begin //write
						timer <= timer + 1'b1;
						case(internal_state)
						3'd0:	internal_state <= 3'd1;
						3'd1:	internal_state <= 3'd2;
						3'd2: begin
							counter <= counter + 1'b1;
							if (counter >= 5'd2) begin
								counter <= 5'd0;
								internal_state <= 3'd0;
								external_state <= PRECHARGE;
							end
						end
						endcase
					end
					
					PRECHARGE: begin   /* PRECHARGE process */
						timer <= timer + 1'b1;
						case(internal_state)
							3'd0:	internal_state <= 3'd1;
							3'd1:begin
									ack <= 1'b1;
									external_state <= RUN;
									internal_state <= 3'b0;
									end	
						endcase		
					end
					
					default: begin
						external_state <=INIT;
						internal_state <= 3'b0;
					end
				
				endcase
			end	
	end
	
	always @ (*) begin
	begin
		Command = C_NOP;
		dram_a=13'b0;
		dram_dqm = 4'b1111;
		dram_ba=2'b0;
		case(external_state)
			INIT:begin	
					case(internal_state)
					3'd0: begin		/* 200us C_NOP */
						Command = C_NOP;		/* C_NOP */
						dram_dqm = 4'b1111;
					end
					3'd1: begin  /* C_PRECHARGE all banks */
						Command = C_PRE;
						dram_a[10] = 1'b1;
					end
					3'd2:	Command = C_NOP;		
					3'd3: begin				/* 8 refresh*/
						if(counter == 5'd0 && timer!=8)
							Command = C_REF;
						else	
							Command = C_NOP;
					end
					3'd4: begin   /* Set MODE Register*/
						Command = C_MRS;
						dram_ba = 2'b00;
						dram_a[12:0] = 13'b0001000100000;   //CAS latency 2
					end
					3'd5:	Command = C_NOP;
					default:	Command = C_NOP;
			   endcase
			end
			
			RUN: begin	//run
				case(internal_state)
					3'd0: Command = C_NOP;
					3'd1: begin						/* refresh */
						if(counter== 5'd0)
							Command = C_REF;		
						else	
							Command = C_NOP;		
					end
					default:Command = C_NOP;		
				endcase
			end
			
			READ: begin //read
				case(internal_state)
					3'd0: begin
						Command = C_ACT;		      /* command activation */
						dram_a[12:0] = adr_i[23:11];
						dram_ba = adr_i[25:24];
					end
					3'd1:	Command = C_NOP;
					3'd2: begin							/* Command read*/
						dram_dqm = 0;
						Command = C_READ;
						dram_a[8:0] = adr_i[10:2];	
						dram_a[10] = 1'b0;
						dram_ba = adr_i[25:24];					
					end
					3'd3:begin
							Command = C_NOP;
							dram_dqm = 0;
						end
					default:Command = C_NOP;
				endcase
			end
			
			WRITE: begin //write
				case(internal_state)
					3'd0: begin									/* command activation */
						Command = C_ACT;		
						dram_a[12:0] = adr_i[23:11];
						dram_ba = adr_i[25:24];		
					end
					3'd1:	Command = C_NOP;	
					3'd2: begin									/* Command write*/					
						if(counter == 5'd0)					
							Command = C_WRITE;	
						else
							Command = C_NOP;
						dram_dqm = ~sel_i;
						dram_a[8:0] = adr_i[10:2];
						dram_a[10] = 1'b0;
						dram_ba = adr_i[25:24];
					end
					default:Command = C_NOP;
				endcase
			end
			
			PRECHARGE: begin   /* PRECHARGE process */
				case(internal_state)
					3'd0:begin
						Command = C_PRE;	  /* Command precharge */
						dram_a[10] = 1'b1;
					end
					3'd1:	Command = C_NOP;
					default:Command = C_NOP;
				endcase		
			end
			default: ;
		endcase
	end	
end


	assign {dram_cs_n,dram_ras_n,dram_cas_n,dram_we_n} = Command;
	assign dram_dq = (external_state == WRITE);
	assign DRAM_DQ = dram_dq ? dat_i : 32'bZ;
	assign dat_o = ram2bus_data_buf;
	assign oDRAM0_A = dram_a;
	assign oDRAM1_A = dram_a;
	assign oDRAM0_LDQM0 = dram_dqm[0];
	assign oDRAM0_UDQM1 = dram_dqm[1];
	assign oDRAM1_LDQM0 = dram_dqm[2];
	assign oDRAM1_UDQM1 = dram_dqm[3];
	assign oDRAM0_WE_N = dram_we_n;
	assign oDRAM1_WE_N = dram_we_n;
	assign oDRAM0_CAS_N = dram_cas_n;
	assign oDRAM1_CAS_N = dram_cas_n;
	assign oDRAM0_RAS_N = dram_ras_n;
	assign oDRAM1_RAS_N = dram_ras_n;
	assign oDRAM0_CS_N = dram_cs_n;
	assign oDRAM1_CS_N = dram_cs_n;
	assign oDRAM0_BA = dram_ba;
	assign oDRAM1_BA = dram_ba;
	assign oDRAM0_CLK = clk_ram;
	assign oDRAM1_CLK = clk_ram;
	assign oDRAM0_CKE = 1'b1;
	assign oDRAM1_CKE = 1'b1;
	
	assign ack_o = ack;
endmodule
