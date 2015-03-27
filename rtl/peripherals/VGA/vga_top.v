`timescale 1ns / 1ps
module vga_top(
    input        wb_clk_i,
    input        wb_rst_i,
    input        wb_cyc_i,
    input        wb_stb_i,
    input [31:0] wb_adr_i,
    input        wb_we_i, 
    input [3:0]  wb_sel_i,
    input [31:0] wb_dat_i,
    output[31:0] wb_dat_o,
    output       wb_ack_o,
    
    input        vga_clk_i,
    output [3:0] vga_r_o,
    output [3:0] vga_g_o,
    output [3:0] vga_b_o,
    output       vga_hs_o,
    output       vga_vs_o
);

    wire wb_cs = wb_stb_i & wb_cyc_i;
    reg  ack;
    
    always@(posedge wb_clk_i)
    begin
        if(wb_rst_i)
            ack <= 0;
        else
            if(wb_cs)
                ack <= 1'b1;
            else
                ack <= 1'b0;
    end
    
    //VGA control module
    wire vga_envalid;
    wire [9:0] vga_pos_x,vga_pos_y;
    wire [7:0] vram_data;
    vga_ctrl vga_ctrl(
        .clk_i(vga_clk_i),
        .reset_i(wb_rst_i),
        .vga_hs_o(vga_hs_o),
        .vga_vs_o(vga_vs_o),
        .envalid_o(vga_envalid),
        .pos_x(vga_pos_x),
        .pos_y(vga_pos_y)
    );
    
    //VRAM
    wire [18:0] vga_addr = vga_pos_y * 640 + vga_pos_x;
    vram vram_inst(
        .clka(wb_clk_i),
        .wea(wb_we_i & wb_cs & !ack),
        .addra(wb_adr_i[18:0]),
        .addrb(vga_addr),
        .dina(wb_dat_i[7:0]),
        .douta(wb_dat_o[7:0]),
        .doutb(vram_data)
    );
    
    //pallet
    wire pallet_en = wb_adr_i[19];
    wire [11:0] pallet_data,vga_data;
    pallet pallet_inst(
        .clk(wb_clk_i),
        .wena(pallet_en & wb_we_i & wb_cs & !ack),
        .addra(wb_adr_i[7:0]),
        .addrb(vram_data),
        .din(wb_dat_i[11:0]),
        .douta(pallet_data),
        .doutb(vga_data)
    );
    
    assign {vga_r_o,vga_g_o,vga_b_o} = vga_data;
    assign wb_ack_o = ack;
    assign wb_dat_o = pallet_en ? {20'b0,pallet_data} : {24'b0,vram_data};

endmodule

