module gpio_top(
    input clk_i,
    input rst_i,
    input        cyc_i,
    input        stb_i,
    input [31:0] adr_i,
    input        we_i, 
    input [3:0]  sel_i,
    input [31:0] dat_i,
    output[31:0] dat_o,
    output       ack_o,
    inout [31:0]  gpio_pin
);

 
    parameter PORT_NUM = 10; //The maximum port num should be less than 128
  
    reg [2*PORT_NUM-1:0] gpio;
  

    // WISHBONE interface
    wire cs_i = cyc_i & stb_i;            // WISHBONE access
    reg ack;
    
    integer i;
    always @(posedge clk_i)
    begin
        if(rst_i)
            begin
                gpio <=  0; //default direction is input
                ack <= 0;
            end
        else
            if(cs_i)    /* wb write */
                begin
                    ack <= 1'b1;
                    if(we_i)
                        for(i=0;i<4;i=i+1)
                            if(sel_i[i]) gpio[(32*adr_i[4:2]+i*8) +:8] <= dat_i[i*8 +:8];
                end
            else
                begin
                    ack <= 0;
                    for(i=0; i < PORT_NUM; i = i + 1)
                        if(!gpio[i*2])
                            gpio[i*2+1] <=  gpio_pin[i*2];
                end
    end

    generate
         genvar ii;
         for(ii=0; ii<PORT_NUM ; ii=ii+1) 
         begin :assign_trig
               assign gpio_pin[ii] = gpio[ii*2] ? gpio[ii*2+1] : 1'bz;
         end
    endgenerate

    assign dat_o = gpio[(32*adr_i[4:2]) +:32];
    assign ack_o = ack;
    
endmodule

