module VgaDeviceCtrl(
	input bus_clk_i,
	input reset_i,
	input cs_i,
	input we_i,
	input [31:0] addr_i,
	input [31:0] data_i,
	output [31:0] data_o,
	output ack_o,
	input vga_clk_i,
	output blank_N_o,
	output sync_N_o,
	output [9:0] color_r_o,
	output [9:0] color_g_o,
	output [9:0] color_b_o,
	output vga_clk_o,
	output h_syn_o,
	output v_syn_o
	//以下为测试时输出的中间变量
	//,output evalid_oo,
	//output [9:0] h_count_oo,
	//output [9:0] v_count_oo,
	//output [12:0] cur_char_addr_oo,
	//output [12:0] vga_raddr_oo,
	//output [7:0] vga_rdata_oo,
	//output c_flash_oo,
	//output [2:0] next_y_addr_oo,
	//output [9:0] word_raddr_oo,
	//output [7:0] word_rdata_oo
	);

	//各种连线
	wire bus_gm_en;				//总线读写控制与显存控制之间
	wire bus_gm_wren;
	wire [7:0] bus_gm_wdata;
	wire [12:0] bus_gm_addr;
	wire [7:0] bus_gm_rdata;
	wire bus_gm_ack;
	
	wire [1:0] bus_cursor_select;	//总线读写控制与光标寄存器组之间
	wire [7:0] bus_cursor_wdata;
	
	wire cursor_en;				//光标寄存器组输出
	wire [7:0] cursor_row;
	wire [7:0] cursor_col;
	
	wire [7:0] vga_gm_rdata;	//vga控制从显存中读出的数据
	
	wire [12:0] gm_bus_addr;	//显存控制与显存之间
	wire [12:0] gm_vga_addr;
	wire gm_bus_wren;
	wire gm_vga_wren;
	wire [7:0] gm_bus_wdata;
	wire [7:0] gm_vga_wdata;
	wire [7:0] gm_bus_rdata;
	wire [7:0] gm_vga_rdata;
	
	wire [9:0] h_count;	//vga计数输出
	wire [9:0] v_count;
	wire cursor_flash;
	
	wire envalid;			//vga控制输出
	wire [12:0] cur_char_addr;
	wire [2:0] x_addr;
	wire [2:0] y_addr;
	
	wire [12:0] next_char_addr;	//下一字符地址及字模内纵坐标
	wire [2:0] next_y_addr;
	
	wire [9:0] word_raddr;	//字模输出
	wire [7:0] word_rdata;
	
	wire [7:0] pixel_cache;	//像素缓存输出
	wire pixel_color;
	
	//总线读写控制
	BusVgaWrCtrl BVWC(
		.clk_i(bus_clk_i),
		.cs_i(cs_i),
		.wr_en_i(we_i),
		.wdata_i(data_i),
		.addr_i(addr_i),
		.rdata_o(data_o),
		.ack_o(ack_o),
		.gm_en_o(bus_gm_en),
		.gm_wr_en_o(bus_gm_wren),
		.gm_wdata_o(bus_gm_wdata),
		.gm_addr_o(bus_gm_addr),
		.gm_rdata_i(bus_gm_rdata),
		.gm_ack_i(bus_gm_ack),
		.c_w_select_o(bus_cursor_select),
		.c_wdata_o(bus_cursor_wdata),
		.c_en_i(cursor_en),
		.c_row_i(cursor_row),
		.c_col_i(cursor_col));
	
	//显存读写控制
	GraphicsCtrl GC(
		.bus_clk_i(bus_clk_i),
		.bus_en_i(bus_gm_en),
		.bus_wren_i(bus_gm_wren),
		.bus_wdata_i(bus_gm_wdata),
		.bus_addr_i(bus_gm_addr),
		.bus_rdata_o(bus_gm_rdata),
		.bus_ack_o(bus_gm_ack),
		.vga_raddr_i(next_char_addr),
		.vga_rdata_o(vga_gm_rdata),
		.gm_bus_addr_o(gm_bus_addr),
		.gm_vga_addr_o(gm_vga_addr),
		.gm_bus_data_o(gm_bus_wdata),
		.gm_vga_data_o(gm_vga_wdata),
		.gm_bus_wren_o(gm_bus_wren),
		.gm_vga_wren_o(gm_vga_wren),
		.gm_bus_data_i(gm_bus_rdata),
		.gm_vga_data_i(gm_vga_rdata));
		
	//显存
	GraphicsMem GM(
		.bus_addr_i(gm_bus_addr),
		.vga_addr_i(gm_vga_addr),
		.bus_clk_i(bus_clk_i),
		.vga_clk_i(vga_clk_i),
		.bus_data_i(gm_bus_wdata),
		.vga_data_i(gm_vga_wdata),
		.bus_wren_i(gm_bus_wren),
		.vga_wren_i(gm_vga_wren),
		.bus_data_o(gm_bus_rdata),
		.vga_data_o(gm_vga_rdata));
		
	//VGA计数
	Counters Cs(
		.clk_i(vga_clk_i),
		.reset_i(reset_i),
		.h_count_o(h_count),
		.v_count_o(v_count),
		.c_flash_o(cursor_flash));
		
	//光标寄存器组
	CursorRegs CR(
		.clk_i(bus_clk_i),
		.w_select_i(bus_cursor_select),
		.wdata_i(bus_cursor_wdata),
		.reset_i(reset_i),
		.c_en_o(cursor_en),
		.c_row_o(cursor_row),
		.c_col_o(cursor_col));
		
	//VGA控制
	VgaCtrl VC(
		.h_count_i(h_count),
		.v_count_i(v_count),
		.vga_hs_o(h_syn_o),
		.vga_vs_o(v_syn_o),
		.vga_blank_N_o(blank_N_o),
		.vga_sync_N_o(sync_N_o),
		.envalid_o(envalid),
		.char_addr_o(cur_char_addr),
		.x_addr_o(x_addr),
		.y_addr_o(y_addr));
		
	//下一字符地址计算
	NextCharAddr NCA(
		.char_addr_i(cur_char_addr),
		.h_count_i(h_count),
		.v_count_i(v_count),
		.y_addr_i(y_addr),
		.next_char_o(next_char_addr),
		.next_y_addr_o(next_y_addr));
		
	//像素缓存
	PixelCache PCc(
		.clk_i(vga_clk_i),
		.pixel_data_i(pixel_cache),
		.cache_rselect_i(cur_char_addr[0]),
		.cache_wselect_i(next_char_addr[0]),
		.x_addr_i(x_addr),
		.pixel_data_o(pixel_color));
		
	//字模存储
	WordMem WM(
		.clk_i(vga_clk_i),
		.read_addr_i(word_raddr),
		.read_data_o(word_rdata));
		
	//像素颜色生成
	PixelColor PCr(
		.pixel_color_i(pixel_color),
		.c_flash_i(cursor_flash),
		.char_addr_i(cur_char_addr),
		.cursor_en_i(cursor_en),
		.cursor_row_i(cursor_row),
		.cursor_col_i(cursor_col),
		.envalid_i(envalid),
		.color_R_o(color_r_o),
		.color_G_o(color_g_o),
		.color_B_o(color_b_o));
		
	//字模控制
	WordCtrl WC(
		.ascii_i(vga_gm_rdata),
		.row_addr_i(next_y_addr),
		.read_addr_o(word_raddr),
		.read_data_i(word_rdata),
		.read_data_o(pixel_cache));
		
	//输出VGA时钟
	assign vga_clk_o = vga_clk_i;
	
	//以下为测试时输出的中间变量
	/*assign evalid_oo = envalid;
	assign h_count_oo = h_count;
	assign v_count_oo = v_count;
	assign cur_char_addr_oo = cur_char_addr;
	assign vga_raddr_oo = gm_vga_addr;
	assign vga_rdata_oo = vga_gm_rdata;
	assign c_flash_oo = cursor_flash;
	assign next_y_addr_oo = next_y_addr;
	assign word_raddr_oo = word_raddr;
	assign word_rdata_oo = word_rdata;*/
	
endmodule
