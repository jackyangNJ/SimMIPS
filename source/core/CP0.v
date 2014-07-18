module CP0(
	clk,
	reset,
	input [2:0]cp0_wen,
	input [31:0]id_b,
	input id_cp0_in_sel,
	input status_shift_sel,
	input [31:0]cause_in,
	input [31:0]epc_in,
	input [1:0]id_cp0_out_sel,
	output [31:0]id_cp0_out,
	output [31:0]status_out,
	output [31:0]epc_out,
	
	//normal r/w interface
	cp0_wen_i,
	cp0_addr_i,
	cp0_data_i,
	cp0_data_o,
	
	cp0_epc_o,
	cp0_status_o,
	cp0_config_o,
	cp0_cause_o,
	cp0_random_o,
	cp0_index_o,
	cp0_entryhi_o,
	cp0_entrylo0_o,
	cp0_entrylo1_o,
	
	cp0_status_i,
	cp0_status_wen_i,
	cp0_status_i,
	cp0_epc_i,
	cp0_epc_wen_i,
	cp0_eentryhi_i,
	cp0_entryhi_wen_i.
	cp0_entrylo0_i,
	cp0_entrylo0_wen_i,
	cp0_entrylo1_i,
	cp0_entrylo1_wen_i,
	
	pause
);
input clk,reset,pause;
//normal cp0 registers r/w
input cp0_wen_i;
input [4:0]cp0_addr_i;
input [31:0] cp0_data_i;
output [31:0] cp0_data_o;
//cp0 register input
input cp0_status_wen_i,cp0_epc_wen_i,cp0_entryhi_wen_i,cp0_entrylo0_wen_i,cp0_entrylo1_wen_i;
input [31:0] cp0_status_i
	reg [31:0]status;
	reg [31:0]cause;
	reg [31:0]epc;
	//CP0 Index
	// reg cp0_index_p;
	// reg [3:0] cp0_index_index;
	// CP0 Random
	// reg [3:0] cp0_random;
	// cp0 Wired
	// reg [3:0] cp0_wired;
	// CP0  EntryLo0,EntryLo1
	// reg [19:0] cp0_entrylo0_pfn;
	// reg [2:0] cp0_entrylo0_c;
	// reg cp0_entrylo0_d;
	// reg cp0_entrylo0_v;
	// reg cp0_entrylo0_g;
	// reg [19:0] cp0_entrylo1_pfn;
	// reg [2:0] cp0_entrylo1_c;
	// reg cp0_entrylo1_d;
	// reg cp0_entrylo1_v;
	// reg cp0_entrylo1_g;
	//CP0 status
	
	
	
	//CP0 Index
	// always@(posedge clk)
	// begin
		// if(!pause)
			// begin
				// if(tlb_probe_faled)
					// cp0_index_p <= 1'b1;
				// else
					// cp0_index_p <= 1'b0;
				// if(cp0_wen[`CP0_INDEX_NUM] && (id_cp0_in_sel ==`CP0_INDEX_NUM))
						// cp0_index_index <= cp0_data_i[3:0];
			// end
	// end
	// CP0 Random
	// always@(posedge clk)
	// begin
		// if(reset)
			// cp0_random <= 4'd15;
		// else
			// begin
				// if(cp0_random == 4'd15)
					// cp0_random <= cp0_wired;
				// else
					// cp0_random <= cp0_random + 1'b1;
			// end
	// end
	
	//CP0 Wired
	// always@(posedge clk)
	// begin
		// if(cp0_wen[`CP0_WIRED_NUM] && (id_cp0_in_sel ==`CP0_WIRED_NUM) && !pause)
			// cp0_wired <= cp0_data_i[3:0];
	// end
	
	always @ (posedge clk) begin
		if (reset) begin
			epc = 32'd0;
			cause = 32'd0;
			status = 32'd0;
		end
		else begin
			if(cp0_wen_i)
				begin
					case(cp0_addr_i)
						5'd0:
							begin
							end
						5'd1:
							begin
							end
						default:
							begin
							end
					endcase
				end
			if (cp0_wen[0] == 1'b1 && pause == 1'b0) begin
				if (id_cp0_in_sel)
					epc = epc_in;
				else
					epc = id_b;
			end
			if (cp0_wen[1] == 1'b1 && pause == 1'b0) begin
				if (id_cp0_in_sel)
					cause = cause_in;
				else
					cause = id_b;
			end
			if (cp0_wen[2] == 1'b1 && pause == 1'b0) begin
				if (id_cp0_in_sel && status_shift_sel)
					status = {2'b00, status[31:2]};
				else if (id_cp0_in_sel && !status_shift_sel)
					status = {status[29:0], 2'b00};
				else
					status = id_b;
			end
		end
	end

	/*
	 * cpo0 out sel
	 */
	 // always@(*)
	 // begin
		// case(id_cp0_in_sel)
			// `CP0_INDEX_NUM:
				// id_cp0_out
		// endcase
	 // end
	assign id_cp0_out = (id_cp0_out_sel==2'd2) ? epc : ((id_cp0_out_sel==2'd1) ? cause : status);
	assign status_out = status;
	assign epc_out = epc;
	
endmodule