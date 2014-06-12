/*
 * CP0
 */
`define CP0_INDEX_NUM 5'd0
`define CP0_RANDOM_NUM 5'd1
`define CP0_ENTRYLO0_NUM 5'd2
`define CP0_ENTRYLO1_NUM 5'd3
`define CP0_CONTEXT_NUM 5'd4
`define CP0_PAGEMASK_NUM 5'd5
`define CP0_WIRED_NUM 5'd6
`define CP0_BADVADDR_NUM 5'd8
`define CP0_COUNT_NUM 5'd9
`define CP0_ENTRYHI_NUM 5'd10
`define CP0_COMPARE_NUM 5'd11
`define CP0_STATUS_NUM 5'd12
`define CP0_CAUSE_NUM 5'd13
`define CP0_EPC_NUM 5'd14
`define CP0_PRID_NUM 5'd15
`define CP0_CONFIG_NUM 5'd16
`define CP0_LLADDR_NUM 5'd17
`define CP0_ERRCTL_NUM 5'd26
`define CP0_TAGLO_NUM 5'd28
`define CP0_ERROREPC_NUM 5'd30

//MDU
`define MDU_OP_NOP		(4'd0)
`define MDU_OP_DIV		(4'd1)
`define MDU_OP_DIVU		(4'd2)
`define MDU_OP_MUL		(4'd3)
`define MDU_OP_MULT		(4'd4)
`define MDU_OP_MULTU    (4'd5)
`define MDU_OP_MFHI		(4'd6)
`define MDU_OP_MFLO		(4'd7)
`define MDU_OP_MTHI		(4'd8)
`define MDU_OP_MTLO		(4'd9)