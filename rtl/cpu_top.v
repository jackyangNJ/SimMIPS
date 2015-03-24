`include "Defines.v"

module cpu_top
#(
    parameter EXT_CLOCK_FREQ = 100000000
)
(
    input clk_i,
    input rst_i,
    /* uart */
    input uart_rx_i,
    output uart_tx_o,
    /* gpio */
    inout[`GPIO_PORT_NUM-1:0] gpio_pin,
    /* keyboard */
    input kb_clk_i,
    input kb_dat_i,
    
`ifdef MIPS_SDRAM
    /* SDRAM */
    input clk_sdram_i,
    input clk_sdram_controller_i,
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
    output oDRAM1_CKE,
`endif

    /* SRAM */
`ifdef MIPS_SRAM
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
    input        Mem_Wait,
`endif
    /* SPI */
    output [3:0] spi_ss_o,
    output spi_sck_o,
    output spi_mosi_o,
    input  spi_miso_i,
    /* VGA */
    input vga_clk_i,
    output blank_N_o,
    output sync_N_o,
    output [9:0] color_r_o,
    output [9:0] color_g_o,
    output [9:0] color_b_o,
    output vga_clk_o,
    output h_syn_o,
    output v_syn_o
);


/* global signals */
wire clk_core = clk_i;
/* clock for peripheral */
wire clk_per  = clk_i;



wire[31:0] core_dphy_addr_o,core_iphy_addr_o;
wire[31:0] core_data_o;
wire       core_data_wr_o;
wire[1:0]  core_data_type_o;

wire core_ibus_memory_en_o,core_dbus_memory_en_o,core_dbus_peripheral_en_o;
wire core_icache_en_o,core_dcache_en_o;

wire biu_ibus_memory_data_ready_o,biu_dbus_memory_data_ready_o,biu_dbus_peripheral_data_ready_o;
wire[31:0] biu_ibus_memory_data_o,biu_dbus_peripheral_data_o,biu_dbus_memory_data_o;

wire[31:0] mbus_dat_o,pbus_dat_o;
wire mbus_ack_o,pbus_ack_o;

wire pic_master_int_o;

pipeline_core core(
    .clk(clk_core),
    .reset(rst_i),
    
    .dphy_addr_o(core_dphy_addr_o),
    .iphy_addr_o(core_iphy_addr_o),
    .data_o(core_data_o),
    .data_wr_o(core_data_wr_o),
    .data_type_o(core_data_type_o),
    
    .ibus_memory_en_o(core_ibus_memory_en_o),
    .ibus_memory_data_ready_i(biu_ibus_memory_data_ready_o),
    .ibus_memory_data_i(biu_ibus_memory_data_o),
    .dbus_memory_en_o(core_dbus_memory_en_o),
    .dbus_memory_data_ready_i(biu_dbus_memory_data_ready_o),
    .dbus_memory_data_i(biu_dbus_memory_data_o),
    .dbus_peripheral_en_o(core_dbus_peripheral_en_o),
    .dbus_peripheral_data_i(biu_dbus_peripheral_data_o),
    .dbus_peripheral_data_ready_i(biu_dbus_peripheral_data_ready_o),
    .icache_en_o(core_icache_en_o),
    .icache_data_i(32'b0),
    .icache_data_ready_i(1'b0),
    .dcache_en_o(core_dcache_en_o),
    .dcache_data_i(32'b0),
    .dcache_data_ready_i(1'b0),
    .hw_interrupt0_i(pic_master_int_o),
    .hw_interrupt1_i(1'b0),
    .hw_interrupt2_i(1'b0),
    .hw_interrupt3_i(1'b0),
    .hw_interrupt4_i(1'b0),
    .hw_interrupt5_i(1'b0)
);


wire biu_bus_mem_stb_o,biu_bus_mem_we_o;
wire[31:0] biu_bus_mem_adr_o,biu_bus_mem_dat_o;
wire[3:0] bus_mem_sel_o;
wire biu_bus_per_stb_o,biu_bus_per_we_o;
wire[31:0] biu_bus_per_adr_o,biu_bus_per_dat_o;
wire[3:0] bus_per_sel_o;

BIU biu(
    .clk_i(clk_core),
    .rst_i(rst_i),
    .dphy_addr_i(core_dphy_addr_o),
    .iphy_addr_i(core_iphy_addr_o),
    .data_i(core_data_o),
    .data_wr_i(core_data_wr_o),
    .data_type_i(core_data_type_o),
    .ibus_memory_en_i(core_ibus_memory_en_o),
    .ibus_memory_data_ready_o(biu_ibus_memory_data_ready_o),
    .ibus_memory_data_o(biu_ibus_memory_data_o),
    .dbus_memory_en_i(core_dbus_memory_en_o),
    .dbus_memory_data_o(biu_dbus_memory_data_o),
    .dbus_memory_data_ready_o(biu_dbus_memory_data_ready_o),
    .dbus_peripheral_en_i(core_dbus_peripheral_en_o),
    .dbus_peripheral_data_o(biu_dbus_peripheral_data_o),
    .dbus_peripheral_data_ready_o(biu_dbus_peripheral_data_ready_o),
    
    .bus_mem_dat_i(mbus_dat_o),
    .bus_mem_ack_i(mbus_ack_o),
    .bus_mem_stb_o(biu_bus_mem_stb_o),
    .bus_mem_we_o(biu_bus_mem_we_o),
    .bus_mem_adr_o(biu_bus_mem_adr_o),
    .bus_mem_dat_o(biu_bus_mem_dat_o),
    .bus_mem_sel_o(bus_mem_sel_o),
    
    .bus_per_dat_i(pbus_dat_o),
    .bus_per_ack_i(pbus_ack_o),
    .bus_per_stb_o(biu_bus_per_stb_o),
    .bus_per_we_o(biu_bus_per_we_o),
    .bus_per_adr_o(biu_bus_per_adr_o),
    .bus_per_dat_o(biu_bus_per_dat_o),
    .bus_per_sel_o(bus_per_sel_o)
);

//
// memory peripheral signals
//
/* ram on chip */
wire ram_ack_o;
wire[31:0] ram_dat_o;
wire mbus_slave_0_cyc_o,mbus_slave_0_stb_o,mbus_slave_0_we_o;
wire[31:0] mbus_slave_0_adr_o,mbus_slave_0_dat_o;
wire[3:0] mbus_slave_0_sel_o;

/* sdram */
`ifdef MIPS_SDRAM
    wire sdram_ack_o;
    wire[31:0] sdram_dat_o;
    wire mbus_slave_1_cyc_o,mbus_slave_1_stb_o,mbus_slave_1_we_o;
    wire[31:0] mbus_slave_1_adr_o,mbus_slave_1_dat_o;
    wire[3:0] mbus_slave_1_sel_o;
`endif

/* ssram */
`ifdef MIPS_SRAM
    wire ssram_ack_o;
    wire[31:0] ssram_dat_o;
    wire mbus_slave_2_cyc_o,mbus_slave_2_stb_o,mbus_slave_2_we_o;
    wire[31:0] mbus_slave_2_adr_o,mbus_slave_2_dat_o;
    wire[3:0] mbus_slave_2_sel_o;
`endif

BusSwitchMem Bus_Switch_Mem(
    .master_stb_i(biu_bus_mem_stb_o),
    .master_we_i(biu_bus_mem_we_o),
    .master_adr_i(biu_bus_mem_adr_o),
    .master_dat_i(biu_bus_mem_dat_o),
    .master_sel_i(bus_mem_sel_o),
    .master_dat_o(mbus_dat_o),
    .master_ack_o(mbus_ack_o),
    
    .slave_0_dat_i(ram_dat_o),
    .slave_0_ack_i(ram_ack_o),
    .slave_0_stb_o(mbus_slave_0_stb_o),
    .slave_0_cyc_o(mbus_slave_0_cyc_o),
    .slave_0_we_o(mbus_slave_0_we_o),
    .slave_0_adr_o(mbus_slave_0_adr_o),
    .slave_0_dat_o(mbus_slave_0_dat_o),
    .slave_0_sel_o(mbus_slave_0_sel_o)
    
`ifdef MIPS_SDRAM
    ,.slave_1_dat_i(sdram_dat_o),
    .slave_1_ack_i(sdram_ack_o),
    .slave_1_stb_o(mbus_slave_1_stb_o),
    .slave_1_cyc_o(mbus_slave_1_cyc_o),
    .slave_1_we_o(mbus_slave_1_we_o),
    .slave_1_adr_o(mbus_slave_1_adr_o),
    .slave_1_dat_o(mbus_slave_1_dat_o),
    .slave_1_sel_o(mbus_slave_1_sel_o)
`endif

`ifdef MIPS_SRAM
    ,.slave_2_dat_i(ssram_dat_o),
    .slave_2_ack_i(ssram_ack_o),
    .slave_2_stb_o(mbus_slave_2_stb_o),
    .slave_2_cyc_o(mbus_slave_2_cyc_o),
    .slave_2_we_o (mbus_slave_2_we_o),
    .slave_2_adr_o(mbus_slave_2_adr_o),
    .slave_2_dat_o(mbus_slave_2_dat_o),
    .slave_2_sel_o(mbus_slave_2_sel_o)
`endif
    );
//
// memory components
//
RamOnChip ram(
    .clk_i(clk_per),
    .rst_i(rst_i),
    .cyc_i(mbus_slave_0_cyc_o),
    .stb_i(mbus_slave_0_stb_o),
    .sel_i(mbus_slave_0_sel_o),
    .adr_i(mbus_slave_0_adr_o),
    .we_i(mbus_slave_0_we_o),
    .dat_i(mbus_slave_0_dat_o),
    .dat_o(ram_dat_o),
    .ack_o(ram_ack_o)
);

`ifdef MIPS_SDRAM
    sdram_top sdram(
        .clk_sys(clk_sdram_controller_i),
        .clk_ram(clk_sdram_i),
        .rst_i(rst_i),
        .cyc_i(mbus_slave_1_cyc_o),
        .stb_i(mbus_slave_1_stb_o),
        .sel_i(mbus_slave_1_sel_o),
        .adr_i(mbus_slave_1_adr_o),
        .we_i (mbus_slave_1_we_o),
        .dat_i(mbus_slave_1_dat_o),
        .dat_o(sdram_dat_o),
        .ack_o(sdram_ack_o),
        .DRAM_DQ     (DRAM_DQ),
        .oDRAM0_A    (oDRAM0_A),
        .oDRAM1_A    (oDRAM1_A),
        .oDRAM0_LDQM0(oDRAM0_LDQM0), 
        .oDRAM0_UDQM1(oDRAM0_UDQM1),
        .oDRAM1_LDQM0(oDRAM1_LDQM0),
        .oDRAM1_UDQM1(oDRAM1_UDQM1),
        .oDRAM0_WE_N (oDRAM0_WE_N),
        .oDRAM1_WE_N (oDRAM1_WE_N),
        .oDRAM0_CAS_N(oDRAM0_CAS_N),
        .oDRAM1_CAS_N(oDRAM1_CAS_N),
        .oDRAM0_RAS_N(oDRAM0_RAS_N),
        .oDRAM1_RAS_N(oDRAM1_RAS_N),
        .oDRAM0_CS_N (oDRAM0_CS_N),
        .oDRAM1_CS_N (oDRAM1_CS_N),
        .oDRAM0_BA   (oDRAM0_BA),
        .oDRAM1_BA   (oDRAM1_BA),
        .oDRAM0_CLK  (oDRAM0_CLK),
        .oDRAM1_CLK  (oDRAM1_CLK),
        .oDRAM0_CKE  (oDRAM0_CKE),
        .oDRAM1_CKE  (oDRAM1_CKE)
    );
`endif

`ifdef MIPS_SRAM
cellram_ctrl_top ssram(
    .clk_i(clk_per),
    .rst_i(rst_i),
    .cyc_i(mbus_slave_2_cyc_o),
    .stb_i(mbus_slave_2_stb_o),
    .sel_i(mbus_slave_2_sel_o),
    .adr_i(mbus_slave_2_adr_o),
    .we_i (mbus_slave_2_we_o),
    .dat_i(mbus_slave_2_dat_o),
    .dat_o(ssram_dat_o),
    .ack_o(ssram_ack_o),
    /* SRAM signal */
    .Mem_A      (Mem_A),
    .Mem_DQ     (Mem_DQ),
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
`endif
//
// peripheral signals
//

/* gpio */
wire gpio_ack_o;
wire[31:0] gpio_dat_o;

/* uart */
wire uart_ack_o;
wire[31:0] uart_dat_o;
wire uart_int_o;
/* keyboard */
wire kb_int_o;
wire[31:0] kb_dat_o;
wire kb_ack_o;
/* rtc */
wire rtc_ack_o;
wire[31:0] rtc_dat_o;
/* pit */
wire pit_int_o;
wire[31:0] pit_dat_o;
wire pit_ack_o;
/* pic master */
wire[31:0] pic_master_dat_o;
wire pic_master_ack_o;

/* pic slave */
wire spi_int_o;
wire[7:0] spi_dat_o;
wire spi_ack_o;

/* vga slave */
wire[31:0] vga_dat_o;
wire vga_ack_o;

/* slave 0 */
wire pbus_slave_0_cyc_o,pbus_slave_0_stb_o,pbus_slave_0_we_o;
wire[31:0] pbus_slave_0_adr_o,pbus_slave_0_dat_o;
wire[3:0] pbus_slave_0_sel_o;
/* slave 1 */
wire pbus_slave_1_cyc_o,pbus_slave_1_stb_o,pbus_slave_1_we_o;
wire[31:0] pbus_slave_1_adr_o,pbus_slave_1_dat_o;
wire[3:0] pbus_slave_1_sel_o;
/* slave 2 */
wire pbus_slave_2_cyc_o,pbus_slave_2_stb_o,pbus_slave_2_we_o;
wire[31:0] pbus_slave_2_adr_o,pbus_slave_2_dat_o;
wire[3:0] pbus_slave_2_sel_o;

/* slave 3 */
wire pbus_slave_3_cyc_o,pbus_slave_3_stb_o,pbus_slave_3_we_o;
wire[31:0] pbus_slave_3_adr_o,pbus_slave_3_dat_o;
wire[3:0] pbus_slave_3_sel_o;

/* slave 4 */
wire pbus_slave_4_cyc_o,pbus_slave_4_stb_o,pbus_slave_4_we_o;
wire[31:0] pbus_slave_4_adr_o,pbus_slave_4_dat_o;
wire[3:0] pbus_slave_4_sel_o;

/* slave 5 */
wire pbus_slave_5_cyc_o,pbus_slave_5_stb_o,pbus_slave_5_we_o;
wire[31:0] pbus_slave_5_adr_o,pbus_slave_5_dat_o;
wire[3:0] pbus_slave_5_sel_o;
/* slave 6 */
wire pbus_slave_6_cyc_o,pbus_slave_6_stb_o,pbus_slave_6_we_o;
wire[31:0] pbus_slave_6_adr_o,pbus_slave_6_dat_o;
wire[3:0] pbus_slave_6_sel_o;
/* slave 7 */
wire pbus_slave_7_cyc_o,pbus_slave_7_stb_o,pbus_slave_7_we_o;
wire[31:0] pbus_slave_7_adr_o,pbus_slave_7_dat_o;
wire[3:0] pbus_slave_7_sel_o;

BusSwitchPer Bus_Switch_Per(
    .master_stb_i(biu_bus_per_stb_o),
    .master_we_i (biu_bus_per_we_o),
    .master_adr_i(biu_bus_per_adr_o),
    .master_dat_i(biu_bus_per_dat_o),
    .master_sel_i(bus_per_sel_o),
    .master_dat_o(pbus_dat_o),
    .master_ack_o(pbus_ack_o),
    
    .slave_0_dat_i(gpio_dat_o),
    .slave_0_ack_i(gpio_ack_o),
    .slave_0_stb_o(pbus_slave_0_stb_o),
    .slave_0_cyc_o(pbus_slave_0_cyc_o),
    .slave_0_we_o (pbus_slave_0_we_o),
    .slave_0_adr_o(pbus_slave_0_adr_o),
    .slave_0_dat_o(pbus_slave_0_dat_o),
    .slave_0_sel_o(pbus_slave_0_sel_o),
    
    .slave_1_dat_i(uart_dat_o),
    .slave_1_ack_i(uart_ack_o),
    .slave_1_stb_o(pbus_slave_1_stb_o),
    .slave_1_cyc_o(pbus_slave_1_cyc_o),
    .slave_1_we_o (pbus_slave_1_we_o),
    .slave_1_adr_o(pbus_slave_1_adr_o),
    .slave_1_dat_o(pbus_slave_1_dat_o),
    .slave_1_sel_o(pbus_slave_1_sel_o),
    
    .slave_2_dat_i(kb_dat_o),
    .slave_2_ack_i(kb_ack_o),
    .slave_2_stb_o(pbus_slave_2_stb_o),
    .slave_2_cyc_o(pbus_slave_2_cyc_o),
    .slave_2_we_o (pbus_slave_2_we_o),
    .slave_2_adr_o(pbus_slave_2_adr_o),
    .slave_2_dat_o(pbus_slave_2_dat_o),
    .slave_2_sel_o(pbus_slave_2_sel_o),
    
    .slave_3_dat_i(rtc_dat_o),
    .slave_3_ack_i(rtc_ack_o),
    .slave_3_stb_o(pbus_slave_3_stb_o),
    .slave_3_cyc_o(pbus_slave_3_cyc_o),
    .slave_3_we_o (pbus_slave_3_we_o),
    .slave_3_adr_o(pbus_slave_3_adr_o),
    .slave_3_dat_o(pbus_slave_3_dat_o),
    .slave_3_sel_o(pbus_slave_3_sel_o),
    
    .slave_4_dat_i(pit_dat_o),
    .slave_4_ack_i(pit_ack_o),
    .slave_4_stb_o(pbus_slave_4_stb_o),
    .slave_4_cyc_o(pbus_slave_4_cyc_o),
    .slave_4_we_o (pbus_slave_4_we_o),
    .slave_4_adr_o(pbus_slave_4_adr_o),
    .slave_4_dat_o(pbus_slave_4_dat_o),
    .slave_4_sel_o(pbus_slave_4_sel_o),
    
    .slave_5_dat_i(pic_master_dat_o),
    .slave_5_ack_i(pic_master_ack_o),
    .slave_5_stb_o(pbus_slave_5_stb_o),
    .slave_5_cyc_o(pbus_slave_5_cyc_o),
    .slave_5_we_o (pbus_slave_5_we_o),
    .slave_5_adr_o(pbus_slave_5_adr_o),
    .slave_5_dat_o(pbus_slave_5_dat_o),
    .slave_5_sel_o(pbus_slave_5_sel_o),
    
    .slave_6_dat_i({24'b0,spi_dat_o}),
    .slave_6_ack_i(spi_ack_o),
    .slave_6_stb_o(pbus_slave_6_stb_o),
    .slave_6_cyc_o(pbus_slave_6_cyc_o),
    .slave_6_we_o (pbus_slave_6_we_o),
    .slave_6_adr_o(pbus_slave_6_adr_o),
    .slave_6_dat_o(pbus_slave_6_dat_o),
    .slave_6_sel_o(pbus_slave_6_sel_o),
    
    .slave_7_dat_i(vga_dat_o),
    .slave_7_ack_i(vga_ack_o),
    .slave_7_stb_o(pbus_slave_7_stb_o),
    .slave_7_cyc_o(pbus_slave_7_cyc_o),
    .slave_7_we_o (pbus_slave_7_we_o),
    .slave_7_adr_o(pbus_slave_7_adr_o),
    .slave_7_dat_o(pbus_slave_7_dat_o),
    .slave_7_sel_o(pbus_slave_7_sel_o)
);

gpio_top gpio(
    .clk_i(clk_per),
    .rst_i(rst_i),
    .wb_cyc_i(pbus_slave_0_cyc_o),
    .wb_stb_i(pbus_slave_0_stb_o),
    .wb_adr_i(pbus_slave_0_adr_o),
    .wb_we_i (pbus_slave_0_we_o), 
    .wb_sel_i(pbus_slave_0_sel_o),
    .wb_dat_i(pbus_slave_0_dat_o),
    .wb_dat_o(gpio_dat_o),
    .wb_ack_o(gpio_ack_o),
    .gpio_pin(gpio_pin)
);



uart_top uart_16550(
    .wb_clk_i(clk_per), 
    // Wishbone signals
    .wb_rst_i(rst_i),
    .wb_adr_i({2'b0,pbus_slave_1_adr_o[2:0]}),
    .wb_dat_i(pbus_slave_1_dat_o),
    .wb_we_i (pbus_slave_1_we_o),
    .wb_stb_i(pbus_slave_1_stb_o),
    .wb_cyc_i(pbus_slave_1_cyc_o),
    .wb_ack_o(uart_ack_o),
    .wb_sel_i(pbus_slave_1_sel_o),
    .wb_dat_o(uart_dat_o),
    .int_o(uart_int_o), // interrupt request
    // serial input/output
    .stx_pad_o(uart_tx_o),
    .srx_pad_i(uart_rx_i)
);

kb_top kb(
    .clk_i(clk_per),
    .rst_i(rst_i),
    .stb_i(pbus_slave_2_stb_o),
    .cyc_i(pbus_slave_2_cyc_o),
    .sel_i(pbus_slave_2_sel_o),
    .we_i (pbus_slave_2_we_o),
    .adr_i(pbus_slave_2_adr_o),
    .dat_i(pbus_slave_2_dat_o),
    .ack_o(kb_ack_o),
    .dat_o(kb_dat_o),
    .int_o(kb_int_o),
    /* KeyBoard */
    .kb_clk_i(kb_clk_i),
    .kb_dat_i(kb_dat_i)
);

rtc_top  
#(
    .CLOCK_FREQ (EXT_CLOCK_FREQ)
)rtc(
    .clk_i(clk_per),
    .rst_i(rst_i),
    .stb_i(pbus_slave_3_stb_o),
    .cyc_i(pbus_slave_3_cyc_o),
    .sel_i(pbus_slave_3_sel_o),
    .we_i (pbus_slave_3_we_o),
    .adr_i(pbus_slave_3_adr_o),
    .dat_i(pbus_slave_3_dat_o),
    .ack_o(rtc_ack_o),
    .dat_o(rtc_dat_o)
);

pit_top
#(
    .CLOCK_FREQ (EXT_CLOCK_FREQ)
) pit(
    .clk_i(clk_per),
    .rst_i(rst_i),
    .stb_i(pbus_slave_4_stb_o),
    .cyc_i(pbus_slave_4_cyc_o),
    .sel_i(pbus_slave_4_sel_o),
    .we_i (pbus_slave_4_we_o),
    .adr_i(pbus_slave_4_adr_o),
    .dat_i(pbus_slave_4_dat_o),
    .ack_o(pit_ack_o),
    .dat_o(pit_dat_o),
    .int_o(pit_int_o)
);

pic_top pic_master(
    .clk_i(clk_per),
    .rst_i(rst_i),
    .stb_i(pbus_slave_5_stb_o),
    .cyc_i(pbus_slave_5_cyc_o),
    .sel_i(pbus_slave_5_sel_o),
    .we_i (pbus_slave_5_we_o),
    .adr_i(pbus_slave_5_adr_o),
    .dat_i(pbus_slave_5_dat_o),
    .ack_o(pic_master_ack_o),
    .dat_o(pic_master_dat_o),
    .int_o(pic_master_int_o),
    .irq_i({2'b0,spi_int_o,uart_int_o,2'b0,kb_int_o,pit_int_o})
);

simple_spi_top spi(
    .clk_i(clk_per),
    .rst_i(~rst_i),
    .stb_i(pbus_slave_6_stb_o),
    .cyc_i(pbus_slave_6_cyc_o),
    .we_i (pbus_slave_6_we_o),
    .adr_i(pbus_slave_6_adr_o[4:2]),
    .dat_i(pbus_slave_6_dat_o[7:0]),
    .ack_o(spi_ack_o),
    .dat_o(spi_dat_o),
    .inta_o(spi_int_o),
    .ss_o(spi_ss_o),
    .sck_o(spi_sck_o),
    .mosi_o(spi_mosi_o),
    .miso_i(spi_miso_i)
);
vga_top vga(
    .bus_clk_i(clk_per),
    .reset_i(rst_i),
    .stb_i (pbus_slave_7_stb_o),
    .cyc_i (pbus_slave_7_cyc_o),
    .sel_i (pbus_slave_7_sel_o),
    .we_i  (pbus_slave_7_we_o),
    .adr_i (pbus_slave_7_adr_o),
    .dat_i (pbus_slave_7_dat_o),
    .dat_o (vga_dat_o),
    .ack_o (vga_ack_o),
    .vga_clk_i(vga_clk_i),
    .blank_N_o(blank_N_o),
    .sync_N_o (sync_N_o),
    .color_r_o(color_r_o),
    .color_g_o(color_g_o),
    .color_b_o(color_b_o),
    .vga_clk_o(vga_clk_o),
    .h_syn_o  (h_syn_o),
    .v_syn_o  (v_syn_o)
);
endmodule

