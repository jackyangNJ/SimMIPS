module pallet #(
    parameter INIT_FILE = "E:/Project/verilog/videl_a7/videl_a7.srcs/sources_1/new/pallet_init.txt"
)(
    input wire clk,
    input wire wena,
    input wire  [7:0] addra,
    input wire  [7:0] addrb,
    input wire  [11:0] din,
    output wire [11:0] douta,
    output wire [11:0] doutb
);

    reg [11:0] pallet_reg [255:0];
    initial
    begin
        $readmemh(INIT_FILE, pallet_reg, 0, 256);
    end
    
    
    always@(posedge clk)begin
        if(wena)
            pallet_reg[addra] <= din;
    end
    
    assign douta = pallet_reg[addra];
    assign doutb = pallet_reg[addrb];
    
endmodule
