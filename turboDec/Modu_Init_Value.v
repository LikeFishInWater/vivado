/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_Init_Value.v
* Abstract: This is the verilog file that store the results in one iteration,and output
* the result to initialize the computations in the next iteration
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_Init_Value(
	//input
	clk,q_up,decMode,decNum,
	BPU_Init_Req,FPU_Init_Req,Updata_BPUtail_beta,Updata_FPU_alpha,Updata_BPU_beta,Updata_FPU_alpha_delay,
	Updata_BPUtail_beta_delay,Beta_tail_In,
	Beta_BPU0_In,Beta_BPU1_In,Beta_BPU2_In,Beta_BPU3_In,Beta_BPU4_In,Beta_BPU5_In,Beta_BPU6_In,Beta_BPU7_In,
	Alph_FPU0_In,Alph_FPU1_In,Alph_FPU2_In,Alph_FPU3_In,Alph_FPU4_In,Alph_FPU5_In,Alph_FPU6_In,Alph_FPU7_In,
	//output
	Beta_out0,Beta_out1,Beta_out2,Beta_out3,Beta_out4,Beta_out5,Beta_out6,Beta_out7,
	Alph_out0,Alph_out1,Alph_out2,Alph_out3,Alph_out4,Alph_out5,Alph_out6,Alph_out7
	);
	//input
	input clk;
	input [3:0] q_up;
	input decMode;
	input [3:0] decNum;
	input BPU_Init_Req;
	input FPU_Init_Req;
	input Updata_BPUtail_beta;
	input Updata_FPU_alpha;
	input Updata_BPU_beta;
	input Updata_FPU_alpha_delay;
	input Updata_BPUtail_beta_delay;
	input [`beta_alpha_width*8-1:0] Beta_tail_In;
	input [`beta_alpha_width*8-1:0] Beta_BPU0_In;
	input [`beta_alpha_width*8-1:0] Beta_BPU1_In;
	input [`beta_alpha_width*8-1:0] Beta_BPU2_In;
	input [`beta_alpha_width*8-1:0] Beta_BPU3_In;
	input [`beta_alpha_width*8-1:0] Beta_BPU4_In;
	input [`beta_alpha_width*8-1:0] Beta_BPU5_In;
	input [`beta_alpha_width*8-1:0] Beta_BPU6_In;
	input [`beta_alpha_width*8-1:0] Beta_BPU7_In;
	input [`beta_alpha_width*8-1:0] Alph_FPU0_In;
	input [`beta_alpha_width*8-1:0] Alph_FPU1_In;
	input [`beta_alpha_width*8-1:0] Alph_FPU2_In;
	input [`beta_alpha_width*8-1:0] Alph_FPU3_In;
	input [`beta_alpha_width*8-1:0] Alph_FPU4_In;
	input [`beta_alpha_width*8-1:0] Alph_FPU5_In;
	input [`beta_alpha_width*8-1:0] Alph_FPU6_In;
	input [`beta_alpha_width*8-1:0] Alph_FPU7_In;
	
	output [`beta_alpha_width*8-1:0] Beta_out0;
	output [`beta_alpha_width*8-1:0] Beta_out1;
	output [`beta_alpha_width*8-1:0] Beta_out2;
	output [`beta_alpha_width*8-1:0] Beta_out3;
	output [`beta_alpha_width*8-1:0] Beta_out4;
	output [`beta_alpha_width*8-1:0] Beta_out5;
	output [`beta_alpha_width*8-1:0] Beta_out6;
	output [`beta_alpha_width*8-1:0] Beta_out7;
	
	output [`beta_alpha_width*8-1:0] Alph_out0;
	output [`beta_alpha_width*8-1:0] Alph_out1;
	output [`beta_alpha_width*8-1:0] Alph_out2;
	output [`beta_alpha_width*8-1:0] Alph_out3;
	output [`beta_alpha_width*8-1:0] Alph_out4;
	output [`beta_alpha_width*8-1:0] Alph_out5;
	output [`beta_alpha_width*8-1:0] Alph_out6;
	output [`beta_alpha_width*8-1:0] Alph_out7;
	
	reg [`beta_alpha_width*8-1:0] Beta_out0,Beta_out1,Beta_out2,Beta_out3,Beta_out4,Beta_out5,Beta_out6,Beta_out7;
	reg [`beta_alpha_width*8-1:0] Alph_out0,Alph_out1,Alph_out2,Alph_out3,Alph_out4,Alph_out5,Alph_out6,Alph_out7;
	
	reg [`beta_alpha_width*8-1:0] Beta_BPU_tail_reg;//暂时存放BPU_Tail的结果，等到第一个B的BPU完成后，和其余值一起更新初值存储单元
	reg [`beta_alpha_width*8-1:0] Alpha0_Reg,Alpha1_Reg,Alpha2_Reg,Alpha3_Reg;//暂时存放FPU的结果,到最后存储
	reg [`beta_alpha_width*8-1:0] Alpha4_Reg,Alpha5_Reg,Alpha6_Reg,Alpha7_Reg;//暂时存放FPU的结果,到最后存储
	
	reg [4:0] r_addr;
	reg w_en;
	reg [4:0] w_addr;
	wire [`beta_alpha_width*8-1:0] RAM_data_r0,RAM_data_r1,RAM_data_r2,RAM_data_r3,RAM_data_r4,RAM_data_r5,RAM_data_r6,RAM_data_r7;
	reg [`beta_alpha_width*8-1:0] RAM_data_w0,RAM_data_w1,RAM_data_w2,RAM_data_w3,RAM_data_w4,RAM_data_w5,RAM_data_w6,RAM_data_w7;
	reg flag_first_BPU_req;
	reg flag_BPU;
	
	Modu_Distributed_Dual_RAM #((`beta_alpha_width*8),5) RAM_Init0(.clk(clk),.write_address(w_addr),
	.write_enable(w_en),.input_data(RAM_data_w0),.read_address(r_addr),.output_data(RAM_data_r0));
	
	Modu_Distributed_Dual_RAM #((`beta_alpha_width*8),5) RAM_Init1(.clk(clk),.write_address(w_addr),
	.write_enable(w_en),.input_data(RAM_data_w1),.read_address(r_addr),.output_data(RAM_data_r1));
	
	Modu_Distributed_Dual_RAM #((`beta_alpha_width*8),5) RAM_Init2(.clk(clk),.write_address(w_addr),
	.write_enable(w_en),.input_data(RAM_data_w2),.read_address(r_addr),.output_data(RAM_data_r2));
	
	Modu_Distributed_Dual_RAM #((`beta_alpha_width*8),5) RAM_Init3(.clk(clk),.write_address(w_addr),
	.write_enable(w_en),.input_data(RAM_data_w3),.read_address(r_addr),.output_data(RAM_data_r3));
	
	Modu_Distributed_Dual_RAM #((`beta_alpha_width*8),5) RAM_Init4(.clk(clk),.write_address(w_addr),
	.write_enable(w_en),.input_data(RAM_data_w4),.read_address(r_addr),.output_data(RAM_data_r4));
	
	Modu_Distributed_Dual_RAM #((`beta_alpha_width*8),5) RAM_Init5(.clk(clk),.write_address(w_addr),
	.write_enable(w_en),.input_data(RAM_data_w5),.read_address(r_addr),.output_data(RAM_data_r5));
	
	Modu_Distributed_Dual_RAM #((`beta_alpha_width*8),5) RAM_Init6(.clk(clk),.write_address(w_addr),
	.write_enable(w_en),.input_data(RAM_data_w6),.read_address(r_addr),.output_data(RAM_data_r6));
	
	Modu_Distributed_Dual_RAM #((`beta_alpha_width*8),5) RAM_Init7(.clk(clk),.write_address(w_addr),
	.write_enable(w_en),.input_data(RAM_data_w7),.read_address(r_addr),.output_data(RAM_data_r7));
	

	/*Save the beta_BPU_tail and alpha in the inner registers*/
	always @(posedge clk)//Updata_BPUtail_beta在4时为1，其余均为0
	begin
		if(Updata_BPUtail_beta == 1'b1)
		begin
			Beta_BPU_tail_reg <= Beta_tail_In;
			flag_first_BPU_req <= 1'b1;
		end
		
		if(FPU_Init_Req == 1'b1)
		begin
			r_addr <= decMode ? ((q_up<<1)+1'b1) : q_up;
		end
		else if(BPU_Init_Req == 1'b1)
		begin
			if(flag_first_BPU_req == 1'b1)
			begin
				r_addr <= decMode ? (q_up+1'b1) : 5'b0;
				flag_first_BPU_req <= 1'b0;
			end
			else
			begin
				r_addr <= r_addr + 1'b1;
			end
		end
	end

	always @(posedge clk)
	begin
		if(Updata_FPU_alpha == 1'b1)
		begin
			Alpha0_Reg <= Alph_FPU0_In;Alpha1_Reg <= Alph_FPU1_In;Alpha2_Reg <= Alph_FPU2_In;Alpha3_Reg <= Alph_FPU3_In;			
			Alpha4_Reg <= Alph_FPU4_In;Alpha5_Reg <= Alph_FPU5_In;Alpha6_Reg <= Alph_FPU6_In;Alpha7_Reg <= Alph_FPU7_In;
		end
	end
	/*Save the beta_BPU_tail and alpha in the inner registers*/

	/*Read from the 8-reg-memories*/
	//r_addr set
/*	always @(posedge clk)
	begin
		if(FPU_Init_Req == 1'b1)
		begin
			r_addr <= decMode ? ((q_up<<1)+1) : q_up;
		end
		else if(BPU_Init_Req == 1'b1)
		begin
			if(flag_first_BPU_req == 1'b1)
			begin
				r_addr <= decMode ? (q_up+1) : 0;
				flag_first_BPU_req <= 1'b0;
			end
			else
			begin
				r_addr <= r_addr + 1;
			end
		end
	end*/
	
	//read RAM_data_r
/*	always @(posedge clk)
	begin
		RAM_data_r0 <= RAM_Init0[r_addr];RAM_data_r1 <= RAM_Init1[r_addr];
		RAM_data_r2 <= RAM_Init2[r_addr];RAM_data_r3 <= RAM_Init3[r_addr];
		RAM_data_r4 <= RAM_Init4[r_addr];RAM_data_r5 <= RAM_Init5[r_addr];
		RAM_data_r6 <= RAM_Init6[r_addr];RAM_data_r7 <= RAM_Init7[r_addr];
	end*/
	/*Read from the 8-reg-memories*/
	
	/*Write to the 8-reg-memories*/
	//w_en
	always @(posedge clk)
	begin
		if(Updata_BPU_beta == 1'b1 || Updata_FPU_alpha_delay == 1'b1)
		begin
			w_en <= 1'b1;
		end
		else
		begin
			w_en <= 1'b0;
		end
	end
	
	//RAM_data_w
	always @(posedge clk)
	begin
		if(Updata_BPU_beta == 1'b1)
		begin
			if(Updata_BPUtail_beta_delay == 1'b1)//首个滑窗的BPU结束，需要为本次内迭代的最后一个滑窗的BPU计算存储初值
			begin
				case(decNum)
					4'b1000:
					begin
						RAM_data_w0 <= Beta_BPU1_In;RAM_data_w1 <= Beta_BPU2_In;
						RAM_data_w2 <= Beta_BPU3_In;RAM_data_w3 <= Beta_BPU4_In;
						RAM_data_w4 <= Beta_BPU5_In;RAM_data_w5 <= Beta_BPU6_In;
						RAM_data_w6 <= Beta_BPU7_In;RAM_data_w7 <= Beta_BPU_tail_reg;
					end
					4'b0100:
					begin
						RAM_data_w0 <= Beta_BPU1_In;RAM_data_w1 <= Beta_BPU2_In;
						RAM_data_w2 <= Beta_BPU3_In;RAM_data_w3 <= Beta_BPU_tail_reg;
					end
					4'b0010:
					begin
						RAM_data_w0 <= Beta_BPU1_In;RAM_data_w1 <= Beta_BPU_tail_reg;
					end
					4'b0001:
					begin
						RAM_data_w0 <= Beta_BPU_tail_reg;
					end
				endcase
			end
			//else if(Updata_FPU_alpha_delay == 1'b1)//存储alpha初值
			//begin
			//	RAM_data_w0 <= 0;			  RAM_data_w1 <= Alpha0_Reg;RAM_data_w2 <= Alpha1_Reg;RAM_data_w3 <= Alpha2_Reg;
			//	RAM_data_w4 <= Alpha3_Reg;RAM_data_w5 <= Alpha4_Reg;RAM_data_w6 <= Alpha5_Reg;RAM_data_w7 <= Alpha6_Reg;
			//end
			else
			begin
				RAM_data_w0 <= Beta_BPU0_In;RAM_data_w1 <= Beta_BPU1_In;RAM_data_w2 <= Beta_BPU2_In;RAM_data_w3 <= Beta_BPU3_In;
				RAM_data_w4 <= Beta_BPU4_In;RAM_data_w5 <= Beta_BPU5_In;RAM_data_w6 <= Beta_BPU6_In;RAM_data_w7 <= Beta_BPU7_In;
			end
		end
		else if(Updata_FPU_alpha_delay == 1'b1)//存储alpha初值
		begin
			RAM_data_w0 <= 0;			  RAM_data_w1 <= Alpha0_Reg;RAM_data_w2 <= Alpha1_Reg;RAM_data_w3 <= Alpha2_Reg;
			RAM_data_w4 <= Alpha3_Reg;RAM_data_w5 <= Alpha4_Reg;RAM_data_w6 <= Alpha5_Reg;RAM_data_w7 <= Alpha6_Reg;
		end
	end
	
	//w_addr
	always @(posedge clk)
	begin
		if(Updata_BPU_beta == 1'b1 || Updata_FPU_alpha_delay == 1'b1)
		begin
			if(Updata_BPU_beta == 1'b1)
			begin
				if(Updata_BPUtail_beta_delay == 1'b1)
				begin
					w_addr <= decMode ? q_up<<1 : q_up-1'b1;
					flag_BPU <= 1'b1;
				end
				else if(flag_BPU == 1'b1)
				begin
					w_addr <= decMode ? q_up+1'b1 : 5'b0;
					flag_BPU <= 1'b0;
				end
				else
				begin
					w_addr <= w_addr + 1'b1;
				end
			end
			else if(Updata_FPU_alpha_delay == 1'b1)
			begin
				w_addr <= decMode ? (q_up<<1)+1'b1 : q_up;
			end
		end
	end
	
	//write
/*	always @(posedge clk)
	begin
		if(w_en == 1'b1)
		begin
			RAM_Init0[w_addr] <= RAM_data_w0;RAM_Init1[w_addr] <= RAM_data_w1;RAM_Init2[w_addr] <= RAM_data_w2;
			RAM_Init3[w_addr] <= RAM_data_w3;RAM_Init4[w_addr] <= RAM_data_w4;RAM_Init5[w_addr] <= RAM_data_w5;
			RAM_Init6[w_addr] <= RAM_data_w6;RAM_Init7[w_addr] <= RAM_data_w7;
		end
	end*/	
	/*Write to the 8-reg-memories*/
	
	/*output*/
	always @(posedge clk)
	begin
		Beta_out0 <= RAM_data_r0;Beta_out1 <= RAM_data_r1;Beta_out2 <= RAM_data_r2;Beta_out3 <= RAM_data_r3;
		Beta_out4 <= RAM_data_r4;Beta_out5 <= RAM_data_r5;Beta_out6 <= RAM_data_r6;Beta_out7 <= RAM_data_r7;
		
		Alph_out0 <= RAM_data_r0;Alph_out1 <= RAM_data_r1;Alph_out2 <= RAM_data_r2;Alph_out3 <= RAM_data_r3;
		Alph_out4 <= RAM_data_r4;Alph_out5 <= RAM_data_r5;Alph_out6 <= RAM_data_r6;Alph_out7 <= RAM_data_r7;
	end
	/*output*/

endmodule
