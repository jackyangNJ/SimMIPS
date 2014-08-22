module cpu_top
#(
	parameter EXT_CLOCK_FREQ = 50000000
)
(
	input external_clk_i,
	input external_rst_i,
	input uart_rx_i,
	output uart_tx_o,
	inout[31:0] gpio_pin,
	input kb_clk_i,
	input kb_dat_i
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
wire ram_ack_o;
wire[31:0] ram_dat_o;



wire mbus_slave_0_cyc_o,mbus_slave_0_stb_o,mbus_slave_0_we_o;
wire[31:0] mbus_slave_0_adr_o,mbus_slave_0_dat_o;
wire[3:0] mbus_slave_0_sel_o;

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
	.CLOCK_FREQ (50000000)
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
	.CLOCK_FREQ (50000000)
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

