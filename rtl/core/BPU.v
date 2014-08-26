module BPU(
	input clk,
	input reset,
	input pause_i,
	input [31:0]if_pc_4_out,
	input [1:0]id_bpu_wen,
	input [31:0]if_new_pc,
	input [31:0]id_pc_4_out,
	input [4:0]id_bpu_index,
	output [31:0]if_bpu_pc,
	output [4:0]if_bpu_index
);

	reg [31:0]saved_pc_4[31:0];
	reg [31:0]branch_target[31:0];
	reg predict_bit[31:0];
	reg [4:0]random_index;
	
	reg matched;
	reg [4:0]matched_index;
	
	reg has_zero;
	reg [4:0]first_zero_index;

initial 
begin:loop_initial
	integer i;
	random_index = 0;
	for (i=0;i<32;i=i+1)
	begin
		saved_pc_4[i] = 0;
	end
end
	
	
	//每个时钟上升沿增加随机寄存器的值，
	//随机寄存器用于指示当BPU预测位全为1时，
	//新写入的项的位置
	always @(posedge clk) 
		random_index = random_index + 1'b1;
		
	always @(posedge clk)
	begin
	//复位信号有效时，将所有预测位置为1
		if (reset)
		begin:loop_reset
			integer i;
			for (i=0;i<32;i=i+1)
			begin
				predict_bit[i] = 0;
			end
		end
		else
	//写入位有效时，将输入的项写入BPU中
	//其中id_bpu_index是前一周期输出的if_bpu_index
		if (id_bpu_wen[1] && !pause_i)
		begin
			saved_pc_4[id_bpu_index] = id_pc_4_out;
			branch_target[id_bpu_index] = if_new_pc;
			predict_bit[id_bpu_index] = id_bpu_wen[0];
		end
	end
	
	//读取时，查找匹配的项的index
	//若存在项与输入的if_pc_4_out相等
	//matched置为1，matched_index置为第一个匹配的项的index
	always @(*)
	begin
		matched = 0;
		matched_index = 5'bxxxxx;
		begin:loop1
			integer i;
			for (i=0;i<32;i=i+1)
			begin
				if (saved_pc_4[i] == if_pc_4_out)
				begin
					matched = 1;
					matched_index = i[4:0];
					disable loop1;
				end
			end
		end
	end
	
	//找到第一个预测位为0的项，
	//若找不到则has_zero置为0
	always @(*)
	begin
		has_zero = 0;
		first_zero_index = 5'bxxxxx;
		begin:loop2
			integer i;
			for (i=0;i<32;i=i+1)
			begin
				if (predict_bit[i] == 0)
				begin
					has_zero = 1;
					first_zero_index = i[4:0];
					disable loop2;
				end
			end
		end
	end
	
	//如果存在匹配项，并且匹配项的预测位为1
	//输出BPU中保存的跳转目标
	//否则直接输出if段的PC+4
	assign if_bpu_pc = matched&predict_bit[matched_index]?
									branch_target[matched_index]:
									if_pc_4_out;
	//如果存在匹配项，输出的index就是匹配的index
	//否则，如果存在预测位为0的项，输出的第一个预测位为0项的地址
	//否则，输出随机寄存器的地址
	assign if_bpu_index = matched?matched_index:
									has_zero?first_zero_index:random_index;
endmodule
