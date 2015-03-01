///////////////////////////////////////////////////////////////////////////////
// This module implements SSRAM controller for CellularRAM on Nexys4 and it is
// compatible with wishbone.
///////////////////////////////////////////////////////////////////////////////

module Ram_Nexys4_top(
    input       clk_i,
    input       rst_i,
    //wishbone
    input        stb_i,
    input        we_i,
    input        cyc_i,
    input [3:0]  sel_i,
    input [31:0] dat_i,
    input [31:0] adr_i,
    output[31:0] dat_o,
    output       ack_o,
    //CellularRAM
    output[22:0] Mem_A,
    inout [15:0] Mem_DQ,
    output       Mem_CEN,
    output       Mem_OEN,
    output       Mem_WEN,
    output       Mem_UB,
    output       Mem_LB,
    output       Mem_ADV,
    output       Mem_CLK,
    output       Mem_CRE,
    input        Mem_Wait
);

    wire cs_i = stb_i & cyc_i;
    wire psram_rd_ack,psram_wr_ack;
    wire [15:0] Mem_DQ_O,Mem_DQ_I,Mem_DQ_T;
    
    PsramCntrl PsramCntrl_inst(
        .clk_i      (clk_i),
        .rst_i      (rst_i),
        .rnw_i      (we_i),
        .be_i       (sel_i),
        .addr_i     (adr_i),
        .data_i     (dat_i),
        .cs_i       (cs_i),
        .data_o     (dat_o),
        .rd_ack_o   (psram_rd_ack),
        .wr_ack_o   (psram_wr_ack),
        .Mem_A      (Mem_A),
        .Mem_DQ_O   (Mem_DQ_O),
        .Mem_DQ_I   (Mem_DQ_I),
        .Mem_DQ_T   (Mem_DQ_T),
        .Mem_CEN    (Mem_CEN),
        .Mem_OEN    (Mem_OEN),
        .Mem_WEN    (Mem_WEN),
        .Mem_UB     (Mem_UB),
        .Mem_LB     (Mem_LB),
        .Mem_ADV    (Mem_ADV),
        .Mem_CLK    (Mem_CLK),
        .Mem_CRE    (Mem_CRE),
        .Mem_Wait   (Mem_Wait)
    );
    
    
    generate
        genvar i;
        for(i=0;i<16;i=i+1)
            IOBUF mem_q_iobuf(
                .I(Mem_DQ_O[i]),
                .IO(Mem_DQ[i]),
                .O(Mem_DQ_I[i]),
                .T(Mem_DQ_T[i])
            );
    endgenerate
    //ack signal
    assign ack_o = psram_rd_ack & psram_wr_ack;
    
endmodule
