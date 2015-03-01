module gpio_top(
    clk_i,
    rst_i,
    wb_cyc_i,
    wb_stb_i,
    wb_we_i,
    wb_adr_i,
    wb_sel_i,
    wb_dat_i,
    wb_dat_o,
    wb_ack_o,
    gpio_pin
);

    /* parameter */
    parameter PORT_NUM = 32; //The maximum port num should be less than 128
    
    /* module interface*/
    input clk_i;
    input rst_i;
    input        wb_cyc_i;
    input        wb_stb_i;
    input [31:0] wb_adr_i;
    input        wb_we_i; 
    input [3:0]  wb_sel_i;
    input [31:0] wb_dat_i;
    output[31:0] wb_dat_o;
    output       wb_ack_o;
    inout [PORT_NUM-1:0]  gpio_pin;
  
    /* 
     * internal register
     * register map:
     * ....|pin1 data|pin1 control||pin0 data|pin0 control|
     * 每个针脚的控制位与数据位交替排列，从低地址依次往上排列
     * 控制位为0表示当前针脚处于高阻状态，用于输入信号，控制位为0的时候用于输出信号
     */
    reg [2*PORT_NUM-1:0] gpio;
    wire wb_cs = wb_cyc_i & wb_stb_i;            // WISHBONE access
    reg  ack;
    
    integer i;
    always @(posedge clk_i)
    begin
        if(rst_i)
            begin
                gpio <=  0; //default direction is input
                ack <= 0;
            end
        else
            if(wb_cs)    /* wb write */
                begin
                    ack <= 1'b1;
                    if(wb_we_i)
                        for(i = 0; i < 4; i = i + 1)
                            if(wb_sel_i[i]) gpio[(32*wb_adr_i[4:2]+i*8) +:8] <= wb_dat_i[i*8 +:8];
                end
            else
                begin
                    ack <= 0;
                    //sample signal on gpio pins
                    for(i=0; i < PORT_NUM; i = i + 1)  
                        if(!gpio[i*2])
                            gpio[i*2+1] <=  gpio_pin[i];
                end
    end

    generate
         genvar ii;
         for(ii=0; ii<PORT_NUM ; ii=ii+1) 
         begin :assign_trig
               assign gpio_pin[ii] = gpio[ii*2] ? gpio[ii*2+1] : 1'bz;
         end
    endgenerate

    assign wb_dat_o = gpio[(32*wb_adr_i[4:2]) +:32];
    assign wb_ack_o = ack;
    
endmodule

