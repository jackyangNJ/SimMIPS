module cellram_ctrl_top(
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
    cellram_ctrl cellram_ctrl_inst
  (
   .wb_clk_i(clk_i),
   .wb_rst_i(rst_i),
   .wb_dat_i(dat_i), 
   .wb_adr_i(adr_i),
   .wb_stb_i(stb_i), 
   .wb_cyc_i(cyc_i),
   .wb_we_i(we_i), 
   .wb_sel_i(sel_i),
   .wb_dat_o(dat_o), 
   .wb_ack_o(ack_o),

   .cellram_dq_io(Mem_DQ),
   .cellram_adr_o(Mem_A),
   .cellram_adv_n_o(Mem_ADV),
   .cellram_ce_n_o(Mem_CEN),
   .cellram_clk_o(Mem_CLK),
   .cellram_oe_n_o(Mem_OEN),
   .cellram_rst_n_o(),
   .cellram_wait_i(Mem_Wait),
   .cellram_we_n_o(Mem_WEN),
   .cellram_wp_n_o(),
   .cellram_cre_o(Mem_CRE),
   .cellram_lb_n_o(Mem_LB),
   .cellram_ub_n_o(Mem_UB)
   );

endmodule