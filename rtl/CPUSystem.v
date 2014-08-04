module CPUSystem(
	input external_clk_i,
	input external_rst_i,
	
	inout[7:0] gpio_pin
);

/*globa signals*/
wire clk_core = external_clk_i;
// wire clk_bus  = external_clk_i;
wire clk_per  = external_clk_i;
wire rst = external_rst_i;
wire[31:0] core_dphy_addr_o,core_iphy_addr_o;
wire[31:0] core_data_o;
wire       core_data_wr_o;
wire[3:0]  core_data_bytesel_o;

wire core_ibus_memory_en_o,core_dbus_memory_en_o,core_dbus_peripheral_en_o;
wire core_icache_en_o,core_dcache_en_o;

wire biu_ibus_memory_data_ready_o,biu_dbus_memory_data_ready_o,biu_dbus_peripheral_data_ready_o;
wire[31:0] biu_ibus_memory_data_o,biu_dbus_peripheral_data_o,biu_dbus_memory_data_o;

wire[31:0] mbus_dat_o,pbus_dat_o;
wire mbus_ack_o,pbus_ack_o;

pipeline_cpu core(
	.clk(clk_core),
	.reset(rst),
	
	.dphy_addr_o(core_dphy_addr_o),
	.iphy_addr_o(core_iphy_addr_o),
	.data_o(core_data_o),
	.data_wr_o(core_data_wr_o),
	.data_bytesel_o(core_data_bytesel_o),
	
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
	.hw_interrupt0_i(1'b0),
	.hw_interrupt1_i(1'b0),
	.hw_interrupt2_i(1'b0),
	.hw_interrupt3_i(1'b0),
	.hw_interrupt4_i(1'b0),
	.hw_interrupt5_i(1'b0)
);


wire biu_bus_mem_stb_o,biu_bus_mem_we_o;
wire[31:0] biu_bus_mem_adr_o,biu_bus_mem_dat_o;
wire[3:0] biu_bus_mem_bytesel_o;
wire biu_bus_per_stb_o,biu_bus_per_we_o;
wire[31:0] biu_bus_per_adr_o,biu_bus_per_dat_o;
wire[3:0] biu_bus_per_bytesel_o;

BIU biu(
	.clk_i(clk_core),
	.rst_i(rst),
	.dphy_addr_i(core_dphy_addr_o),
	.iphy_addr_i(core_iphy_addr_o),
	.data_i(core_data_o),
	.data_wr_i(core_data_wr_o),
	.data_bytesel_i(core_data_bytesel_o),
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
	.bus_mem_bytesel_o(biu_bus_mem_bytesel_o),
	
	.bus_per_dat_i(pbus_dat_o),
	.bus_per_ack_i(pbus_ack_o),
	.bus_per_stb_o(biu_bus_per_stb_o),
	.bus_per_we_o(biu_bus_per_we_o),
	.bus_per_adr_o(biu_bus_per_adr_o),
	.bus_per_dat_o(biu_bus_per_dat_o),
	.bus_per_bytesel_o(biu_bus_per_bytesel_o)
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
	.master_sel_i(biu_bus_mem_bytesel_o),
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

wire gpio_ack_o;
wire[31:0] gpio_dat_o;
wire pbus_adr_err_o;


wire pbus_slave_0_cyc_o,pbus_slave_0_stb_o,pbus_slave_0_we_o;
wire[31:0] pbus_slave_0_adr_o,pbus_slave_0_dat_o;
wire[3:0] pbus_slave_0_sel_o;

BusSwitchPer Bus_Switch_Per(
	.adr_err_o(pbus_adr_err_o),
	.master_stb_i(biu_bus_per_stb_o),
	.master_we_i(biu_bus_per_we_o),
	.master_adr_i(biu_bus_per_adr_o),
	.master_dat_i(biu_bus_per_dat_o),
	.master_sel_i(biu_bus_per_bytesel_o),
	.master_dat_o(pbus_dat_o),
	.master_ack_o(pbus_ack_o),
	
	.slave_0_dat_i(gpio_dat_o),
	.slave_0_ack_i(gpio_ack_o),
	.slave_0_stb_o(pbus_slave_0_stb_o),
	.slave_0_cyc_o(pbus_slave_0_cyc_o),
	.slave_0_we_o(pbus_slave_0_we_o),
	.slave_0_adr_o(pbus_slave_0_adr_o),
	.slave_0_dat_o(pbus_slave_0_dat_o),
	.slave_0_sel_o(pbus_slave_0_sel_o)
);

GPIO gpio(
	.clk_i(clk_per),
	.rst_i(rst),
	.cyc_i(pbus_slave_0_cyc_o),
	.stb_i(pbus_slave_0_stb_o),
	.adr_i(pbus_slave_0_adr_o),
	.we_i(pbus_slave_0_we_o), 
	.sel_i(pbus_slave_0_sel_o),
	.dat_i(pbus_slave_0_dat_o),
	.dat_o(gpio_dat_o),
	.ack_o(gpio_ack_o),
	.gpio_pin(gpio_pin)
);
endmodule

