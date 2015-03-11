`include "Configuration.v"
//global defines
`define RstEnable       1'b1
`define RstDisable      1'b0
`define WriteEnable     1'b1
`define WriteDisable    1'b0
`define ReadEnable      1'b1
`define ReadDisable     1'b0
`define ChipEnable      1'b1
`define ChipDisable     1'b0


/*
 * CP0 Registers address
 */
`define CP0_INDEX_ADDR      5'd0
`define CP0_RANDOM_ADDR     5'd1
`define CP0_ENTRYLO0_ADDR   5'd2
`define CP0_ENTRYLO1_ADDR   5'd3
`define CP0_CONTEXT_ADDR    5'd4
`define CP0_PAGEMASK_ADDR   5'd5
`define CP0_WIRED_ADDR      5'd6
`define CP0_BADVADDR_ADDR   5'd8
`define CP0_COUNT_ADDR      5'd9
`define CP0_ENTRYHI_ADDR    5'd10
`define CP0_COMPARE_ADDR    5'd11
`define CP0_STATUS_ADDR     5'd12
`define CP0_CAUSE_ADDR      5'd13
`define CP0_EPC_ADDR        5'd14
`define CP0_PRID_ADDR       5'd15
`define CP0_CONFIG_ADDR     5'd16
`define CP0_LLADDR_ADDR     5'd17
`define CP0_ERRCTL_ADDR     5'd26
`define CP0_TAGLO_ADDR      5'd28
`define CP0_ERROREPC_ADDR   5'd30

/* CP0 exceptions */
`define EXC_Int     5'd0
`define EXC_Mod     5'd1
`define EXC_TLBL    5'd2
`define EXC_TLBS    5'd3
`define EXC_AdEL    5'd4
`define EXC_AdES    5'd5
`define EXC_Sys     5'd8
`define EXC_Ov      5'd12

/* MDU Op constants */
`define MDU_OP_NOP      (4'd0)
`define MDU_OP_DIV      (4'd1)
`define MDU_OP_DIVU     (4'd2)
`define MDU_OP_MUL      (4'd3)
`define MDU_OP_MULT     (4'd4)
`define MDU_OP_MULTU    (4'd5)
`define MDU_OP_MFHI     (4'd6)
`define MDU_OP_MFLO     (4'd7)
`define MDU_OP_MTHI     (4'd8)
`define MDU_OP_MTLO     (4'd9)

/* 
 * instruction code
 */

`define OP_REGIMM    (6'b000001)
`define OP_J         (6'b000010)
`define OP_JAL       (6'b000011)
`define OP_BEQ       (6'b000100)
`define OP_BNE       (6'b000101)
`define OP_BLEZ      (6'b000110)
`define OP_BGTZ      (6'b000111)
`define OP_ADDI      (6'b001000)
`define OP_ADDIU     (6'b001001)
`define OP_SLTI      (6'b001010)
`define OP_SLTIU     (6'b001011)
`define OP_ANDI      (6'b001100)
`define OP_ORI       (6'b001101)
`define OP_XORI      (6'b001110)
`define OP_COP0      (6'b010000)
`define OP_SPECIAL   (6'b000000)
`define OP_SPECIAL2  (6'b011100)
`define OP_LUI       (6'b001111)
`define OP_LB        (6'b100000)
`define OP_LBU       (6'b100100)
`define OP_LH        (6'b100001)
`define OP_LHU       (6'b100101)
`define OP_LW        (6'b100011)
`define OP_SB        (6'b101000)
`define OP_SH        (6'b101001)
`define OP_SW        (6'b101011)

//末6位字段常量
`define TAIL_SLL     (6'b000000)
`define TAIL_SRL     (6'b000010)
`define TAIL_SRA     (6'b000011)
`define TAIL_SLLV    (6'b000100)
`define TAIL_SRLV    (6'b000110)
`define TAIL_SRAV    (6'b000111)
`define TAIL_JR      (6'b001000)
`define TAIL_JALR    (6'b001001)
`define TAIL_MOVZ    (6'b001010)
`define TAIL_MOVN    (6'b001011)
`define TAIL_SYSCALL (6'b001100)
`define TAIL_MFHI    (6'b010000)
`define TAIL_MTHI    (6'b010001)
`define TAIL_MFLO    (6'b010010)
`define TAIL_MTLO    (6'b010011)
`define TAIL_ERET    (6'b011000)
`define TAIL_ADD     (6'b100000)
`define TAIL_ADDU    (6'b100001)
`define TAIL_CLO     (6'b100001)
`define TAIL_CLZ     (6'b100000)
`define TAIL_XOR     (6'b100110)
`define TAIL_SUB     (6'b100010)
`define TAIL_SUBU    (6'b100011)
`define TAIL_AND     (6'b100100)
`define TAIL_NOR     (6'b100111)
`define TAIL_OR      (6'b100101)
`define TAIL_SLT     (6'b101010)
`define TAIL_SLTU    (6'b101011)
`define TAIL_MULT    (6'b011000)
`define TAIL_MULTU   (6'b011001)
`define TAIL_MUL     (6'b000010)
`define TAIL_DIV     (6'b011010)
`define TAIL_DIVU    (6'b011011)
`define TAIL_TLBR    (6'b000001)
`define TAIL_TLBWI   (6'b000010)
`define TAIL_TLBWR   (6'b000110)
`define TAIL_TLBP    (6'b001000)

`define RT_BGEZ      (5'b00001)
`define RT_BGEZAL    (5'b10001)
`define RT_BLTZ      (5'b00000)
`define RT_BLTZAL    (5'b10000)
`define RS_MF        (5'b00000)
`define RS_MT        (5'b00100)