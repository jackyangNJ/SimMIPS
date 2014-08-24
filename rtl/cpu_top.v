module cpu_top
#(
	parameter EXT_CLOCK_FREQ = 50000000
)
(
	input external_clk_i,
	input clk_sdram,
	input external_rst_i,
	input uart_rx_i,
	output uart_tx_o,
	inout[31:0] gpio_pin,
	input kb_clk_i,
	input kb_dat_i,
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
	inout [31:0]SRAM_DQ,
	inout [3:0]SRAM_DPA,
	output  oSRAM_ADSP_N,
	output  oSRAM_ADV_N,
	output  oSRAM_CE2,
	output  oSRAM_CE3_N,
	output  oSRAM_CLK,
	output  oSRAM_GW_N,
	output  [18:0]oSRAM_A,
	output  oSRAM_ADSC_N,
	output [3:0]oSRAM_BE_N,
	output  oSRAM_CE1_N,
	output  oSRAM_OE_N,
	output  oSRAM_WE_N
);


/*globa signals*/
wire clk_core = external_clk_i;
// wire clk_bus  = external_clk_i;
wire clk_per  = external_clk_i;

wire rst = external_rst_i;

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
	.reset(rst),
	
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
	.rst_i(rst),
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
/*RamOnChip*/
wire ram_ack_o;
wire[31:0] ram_dat_o;
/* sdram */
wire sdram_ack_o;
wire[31:0] sdram_dat_o;
/* ssram */
wire ssram_ack_o;
wire[31:0] ssram_dat_o;

/* ram on chip */
wire mbus_slave_0_cyc_o,mbus_slave_0_stb_o,mbus_slave_0_we_o;
wire[31:0] mbus_slave_0_adr_o,mbus_slave_0_dat_o;
wire[3:0] mbus_slave_0_sel_o;

/* sdram */
wire mbus_slave_1_cyc_o,mbus_slave_1_stb_o,mbus_slave_1_we_o;
wire[31:0] mbus_slave_1_adr_o,mbus_slave_1_dat_o;
wire[3:0] mbus_slave_1_sel_o;
/* ssram */
wire mbus_slave_2_cyc_o,mbus_slave_2_stb_o,mbus_slave_2_we_o;
wire[31:0] mbus_slave_2_adr_o,mbus_slave_2_dat_o;
wire[3:0] mbus_slave_2_sel_o;

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
	.slave_0_sel_o(mbus_slave_0_sel_o),
	
	.slave_1_dat_i(sdram_dat_o),
	.slave_1_ack_i(sdram_ack_o),
	.slave_1_stb_o(mbus_slave_1_stb_o),
	.slave_1_cyc_o(mbus_slave_1_cyc_o),
	.slave_1_we_o(mbus_slave_1_we_o),
	.slave_1_adr_o(mbus_slave_1_adr_o),
	.slave_1_dat_o(mbus_slave_1_dat_o),
	.slave_1_sel_o(mbus_slave_1_sel_o),
	
	.slave_2_dat_i(ssram_dat_o),
	.slave_2_ack_i(ssram_ack_o),
	.slave_2_stb_o(mbus_slave_2_stb_o),
	.slave_2_cyc_o(mbus_slave_2_cyc_o),
	.slave_2_we_o(mbus_slave_2_we_o),
	.slave_2_adr_o(mbus_slave_2_adr_o),
	.slave_2_dat_o(mbus_slave_2_dat_o),
	.slave_2_sel_o(mbus_slave_2_sel_o)
	);
//
// memory components
//
RamOnChip ram(
	.clk_i(clk_per),
	.rst_i(rst),
	.cyc_i(mbus_slave_0_cyc_o),
	.stb_i(mbus_slave_0_stb_o),
	.sel_i(mbus_slave_0_sel_o),
	.adr_i(mbus_slave_0_adr_o),
	.we_i(mbus_slave_0_we_o),
	.dat_i(mbus_slave_0_dat_o),
	.dat_o(ram_dat_o),
	.ack_o(ram_ack_o)
);

sdram_top sdram(
	.clk_sys(clk_per),
	.clk_ram(clk_sdram),
	.rst_i(rst),
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

ssram_top ssram(
	.clk_i(clk_per),
	.rst_i(rst),
	.cyc_i(mbus_slave_2_cyc_o),
	.stb_i(mbus_slave_2_stb_o),
	.sel_i(mbus_slave_2_sel_o),
	.adr_i(mbus_slave_2_adr_o),
	.we_i (mbus_slave_2_we_o),
	.dat_i(mbus_slave_2_dat_o),
	.dat_o(ssram_dat_o),
	.ack_o(ssram_ack_o),
	/* SRAM signal */
	.SRAM_DQ(SRAM_DQ),
	.SRAM_DPA(SRAM_DPA),
	.oSRAM_ADSP_N(oSRAM_ADSP_N),
	.oSRAM_ADV_N(oSRAM_ADV_N),
	.oSRAM_CE2(oSRAM_CE2),
	.oSRAM_CE3_N(oSRAM_CE3_N),
	.oSRAM_CLK(oSRAM_CLK),
	.oSRAM_GW_N(oSRAM_GW_N),
	.oSRAM_A(oSRAM_A),
	.oSRAM_ADSC_N(oSRAM_ADSC_N),
	.oSRAM_BE_N(oSRAM_BE_N),
	.oSRAM_CE1_N(oSRAM_CE1_N),
	.oSRAM_OE_N(oSRAM_OE_N),
	.oSRAM_WE_N(oSRAM_WE_N)
);
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
wire pic_slave_int_o;
wire[31:0] pic_slave_dat_o;
wire pic_slave_ack_o;

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
	
	.slave_6_dat_i(pic_slave_dat_o),
	.slave_6_ack_i(pic_slave_ack_o),
	.slave_6_stb_o(pbus_slave_6_stb_o),
	.slave_6_cyc_o(pbus_slave_6_cyc_o),
	.slave_6_we_o (pbus_slave_6_we_o),
	.slave_6_adr_o(pbus_slave_6_adr_o),
	.slave_6_dat_o(pbus_slave_6_dat_o),
	.slave_6_sel_o(pbus_slave_6_sel_o)
);

gpio_top gpio(
	.clk_i(clk_per),
	.rst_i(rst),
	.cyc_i(pbus_slave_0_cyc_o),
	.stb_i(pbus_slave_0_stb_o),
	.adr_i(pbus_slave_0_adr_o),
	.we_i (pbus_slave_0_we_o), 
	.sel_i(pbus_slave_0_sel_o),
	.dat_i(pbus_slave_0_dat_o),
	.dat_o(gpio_dat_o),
	.ack_o(gpio_ack_o),
	.gpio_pin(gpio_pin)
);


	
uart_top uart_16550(
	.wb_clk_i(clk_per), 
	// Wishbone signals
	.wb_rst_i(rst),
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
	.rst_i(rst),
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
	.rst_i(rst),
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
	.rst_i(rst),
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
	.rst_i(rst),
	.stb_i(pbus_slave_5_stb_o),
	.cyc_i(pbus_slave_5_cyc_o),
	.sel_i(pbus_slave_5_sel_o),
	.we_i (pbus_slave_5_we_o),
	.adr_i(pbus_slave_5_adr_o),
	.dat_i(pbus_slave_5_dat_o),
	.ack_o(pic_master_ack_o),
	.dat_o(pic_master_dat_o),
	.int_o(pic_master_int_o),
	.irq_i({3'b0,uart_int_o,1'b0,pic_slave_int_o,kb_int_o,pit_int_o})
);

pic_top pic_slave(
	.clk_i(clk_per),
	.rst_i(rst),
	.stb_i(pbus_slave_6_stb_o),
	.cyc_i(pbus_slave_6_cyc_o),
	.sel_i(pbus_slave_6_sel_o),
	.we_i (pbus_slave_6_we_o),
	.adr_i(pbus_slave_6_adr_o),
	.dat_i(pbus_slave_6_dat_o),
	.ack_o(pic_slave_ack_o),
	.dat_o(pic_slave_dat_o),
	.int_o(pic_slave_int_o),
	.irq_i(8'b0)
);
endmodule

