module SSRAM
(
	input clk_i,
	input rst_i,
	input cs_i,
	input we_i,
	input [31:0]dat_i,
	input [31:0]adr_i,
	output reg [31:0] dat_o,
	output reg ack_o,
	/* SRAM signal */
	inout [31:0]SRAM_DQ,
	inout [3:0]SRAM_DPA,
	output  oSRAM_ADSP_N,
	output  oSRAM_ADV_N,
	output  oSRAM_CE2,
	output  oSRAM_CE3_N,
	output  oSRAM_CLK,
	output  oSRAM_GW_N,
	output reg [18:0]oSRAM_A,
	output reg oSRAM_ADSC_N,
	output [3:0]oSRAM_BE_N,
	output reg oSRAM_CE1_N,
	output reg oSRAM_OE_N,
	output reg oSRAM_WE_N
);


	reg [2:0]counter;
	parameter IDLE = 3'd0, WRITE1 = 3'd1, WRITE2 = 3'd2, READ1 = 3'd3, READ2 = 3'd4, READ3 = 3'd5, WAIT = 3'd6;
	reg dataout;

	always @ (posedge clk_i) begin
	if(rst_i)
	begin
		counter<=0;
		ack_o <= 1'b0;
	end	
	else
	begin
		case (counter)
		IDLE: begin			
			if (cs_i) begin
				if (we_i)
					counter <= WRITE1;
				else
					counter <= READ1;
			end
		end
		WRITE1: begin
			counter <= WRITE2;
		end
		WRITE2: begin
			counter <= WAIT;
		end
		READ1: begin
			counter <= READ2;
		end
		READ2: begin
			counter <= READ3;
		end
		READ3: begin
			dat_o <= SRAM_DQ;
			counter <= WAIT;
		end
		WAIT: begin
			ack_o <= 1'b1;
			if(!cs_i)
			begin
				counter <= IDLE;
				ack_o <= 1'b0;
			end	
		end
		endcase
	end	
	end
	always@(*)
	begin
		oSRAM_ADSC_N = 1'b1;
		oSRAM_WE_N = 1'b1;
		oSRAM_CE1_N = 1'b1;
		dataout = 1'b0;
		oSRAM_OE_N = 1'b0;
		oSRAM_A = 19'b0;
		case(counter)
		IDLE:begin
			oSRAM_ADSC_N = 1'b1;
			oSRAM_WE_N = 1'b1;
			oSRAM_CE1_N = 1'b1;
			oSRAM_OE_N = 1'b1;
			dataout = 1'b0;
		end
		WRITE1: begin
			oSRAM_ADSC_N = 1'b0;
			oSRAM_A = adr_i[20:2];
			oSRAM_CE1_N = 1'b0;
			oSRAM_OE_N = 1'b1;
			dataout = 1'b0;
		end
		WRITE2: begin
			oSRAM_ADSC_N = 1'b1;
			oSRAM_WE_N = 1'b0;
			oSRAM_OE_N = 1'b1;
			oSRAM_CE1_N = 1'b0;
			dataout = 1'b1;
		end
		READ1: begin
			oSRAM_ADSC_N = 1'b0;
			oSRAM_A = adr_i[20:2];
			oSRAM_WE_N = 1'b1;
			oSRAM_CE1_N = 1'b0;
			oSRAM_OE_N = 1'b1;
			dataout = 1'b0;
		end
		READ2: begin
			oSRAM_ADSC_N = 1'b1;
			oSRAM_WE_N = 1'b1;
			oSRAM_OE_N = 1'b0;
			oSRAM_CE1_N = 1'b0;
			dataout = 1'b0;
		end
		READ3: begin
			oSRAM_ADSC_N = 1'b1;
			oSRAM_WE_N = 1'b1;
			oSRAM_CE1_N = 1'b1;
			oSRAM_OE_N = 1'b0;
			dataout = 1'b0;
		end
		WAIT: begin
			oSRAM_ADSC_N = 1'b1;
			oSRAM_WE_N = 1'b1;
			oSRAM_CE1_N = 1'b1;
			dataout = 1'b0;
		end
		endcase
	end
	assign SRAM_DQ = dataout ? dat_i : 32'dz;
	assign oSRAM_CE2 = ~oSRAM_CE1_N;
	assign oSRAM_CE3_N = oSRAM_CE1_N;
	assign SRAM_DPA = 4'dz;
	assign oSRAM_CLK = clk_i;
	assign oSRAM_ADV_N = 1'b1;
	assign oSRAM_ADSP_N = 1'b1;
	assign oSRAM_GW_N = 1'b1;
	assign oSRAM_BE_N = 4'b0;
	
endmodule
