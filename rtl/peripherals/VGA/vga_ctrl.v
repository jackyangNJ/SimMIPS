module vga_ctrl(
    input clk_i, // clock requirement:25MHz for 640*480
    input reset_i,
    output vga_hs_o,
    output vga_vs_o,
    output envalid_o,
    output [9:0] pos_x,
    output [9:0] pos_y
);
    //640 * 480 resolution
    parameter H_COUNT_CYC = 95;
    parameter X_START = 144;
    parameter X_END = 783;
    parameter H_COUNT_TOTAL = 799;
    parameter V_COUNT_CYC = 1;
    parameter Y_START = 35;
    parameter Y_END = 514;
    parameter V_COUNT_TOTAL = 524;

    //generate count
    reg [9:0] reg_h_count,reg_v_count;
    always@(posedge clk_i)
    begin
        if(reset_i == 1'b1) begin    //重置清零
            reg_h_count <= 10'b0;
            reg_v_count <= 10'b0;
        end
        else  begin
            if(reg_h_count[9:0] >= H_COUNT_TOTAL)   //h到达最大值
            begin
                reg_h_count[9:0] <= 10'b0;
                if(reg_v_count[9:0] >= V_COUNT_TOTAL)   //v到达最大值
                    reg_v_count[9:0] <= 10'b0;
                else
                    reg_v_count[9:0] <= reg_v_count[9:0] + 1'b1;
            end
            else
                reg_h_count[9:0] <= reg_h_count[9:0] + 1'b1;
        end
    end
    
    //行列消隐信号
    assign vga_hs_o = (reg_h_count[9:0] > H_COUNT_CYC);
    assign vga_vs_o = (reg_v_count[9:0] > V_COUNT_CYC);

    assign pos_x[9:0] = reg_h_count[9:0] - X_START[9:0];
    assign pos_y[9:0] = reg_v_count[9:0] - Y_START[9:0];

    //像素颜色使能
    assign envalid_o = (reg_h_count[9:0] >= X_START[9:0]) & (reg_h_count[9:0] <= X_END[9:0]) &
                       (reg_v_count[9:0] >= Y_START[9:0]) & (reg_v_count[9:0] <= Y_END[9:0]);
endmodule
