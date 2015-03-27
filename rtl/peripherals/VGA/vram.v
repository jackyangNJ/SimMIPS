module vram(
    input wire [18:0] addra,        // Write address bus, width determined from RAM_DEPTH
    input wire [18:0] addrb,        // Read address bus, width determined from RAM_DEPTH
    input wire [7:0] dina,          // RAM input data
    input wire clka,                // Clock
    input wire wea,                 // Write enable
    output wire [7:0] douta,        // RAM output data
    output wire [7:0] doutb         // RAM output data
);


    
    wire vrama_wea = wea & (!addra[18]);
    wire vramb_wea = wea & addra[18];
    wire[7:0] vrama_data_a,vrama_data_b;
    wire[7:0] vramb_data_a,vramb_data_b;
    
    dual_port_ram  #(
        .RAM_WIDTH(8),
        .RAM_DEPTH(262143),
        .INIT_FILE("E:/Project/verilog/videl_a7/videl_a7.srcs/sources_1/new/ram_init.txt")
    )
    vrama(
        .clka   (clka),
        .wea    (vrama_wea),
        .addra  (addra[17:0]),
        .addrb  (addrb[17:0]),
        .enb    (1'b1),
        .rstb   (0),
        .regceb (0),
        .dina   (dina),
        .douta  (vrama_data_a),
        .doutb  (vrama_data_b)
    );
    
    dual_port_ram  #(
        .RAM_WIDTH(8),
        .RAM_DEPTH(65535),
        .INIT_FILE("")
    )
    vramb(
        .clka   (clka),
        .wea    (vramb_wea),
        .addra  (addra[15:0]),
        .addrb  (addrb[15:0]),
        .enb    (1'b1),
        .rstb   (0),
        .regceb (0),
        .dina   (dina),
        .douta  (vramb_data_a),
        .doutb  (vramb_data_b)
    );

   assign douta = addra[18] ? vramb_data_a : vrama_data_a;
   assign doutb = addrb[18] ? vramb_data_b : vrama_data_b;
   
endmodule