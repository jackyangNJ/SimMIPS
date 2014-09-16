module SinglePortRam
(
    input clk_i,
    input we_i,
    input [12:0] adr_i, 
    input [3:0] be_i, 
    input [31:0] dat_i,
    output[31:0] dat_o
);
    
    // use a multi-dimensional packed array
    //to model individual bytes within the word
    // (* ram_init_file = "ram_init.mif" *) logic [3:0][7:0] ram[0:4095];
    logic [3:0][7:0] ram[0:8191];
    integer i;
    initial
    begin
        // for(i=0;i<8192;i=i+1)
            // ram[i] = 0;
        $readmemh("ram_init.txt", ram);
        

    end
    
    reg[31:0] q;
    always_ff@(posedge clk_i)
    begin
    if(we_i) 
        begin
            if(be_i[0]) ram[adr_i][0] <= dat_i[7:0];
            if(be_i[1]) ram[adr_i][1] <= dat_i[15:8];
            if(be_i[2]) ram[adr_i][2] <= dat_i[23:16];
            if(be_i[3]) ram[adr_i][3] <= dat_i[31:24];
        end
        q <= ram[adr_i];
    end
    
    assign dat_o = q;
endmodule
