module SubInterfaceJudger(
	input im_req_i,
	input dm_req_i,
	output im_cs_o,
	output dm_cs_o
);

	assign im_cs_o = im_req_i&~dm_req_i;
	assign dm_cs_o = dm_req_i;
	
endmodule
