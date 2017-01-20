/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_CalcBufAddr_3BUF.v
* Abstract: This is the verilog file that calculate the address of BUF0~2
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
* Modified on 2012-04-17 for various code length in LTE
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_CalcBufAddr_3BUF(
	//input
	clk,reset,initDir,initFlag,CmpCounter,final_BUF_flag,q_up,r,
	//output
	Ad_3BUF//,dir_3BUF
    );
	//input
	input clk;
	input reset;
	input initDir;
	input [1:0] initFlag;
	input [`CmpCounter_width-1:0] CmpCounter;
//	input [`window_width:0] B;//1000000共7bits，window_width=6
	input final_BUF_flag;
	input [3:0] q_up;
	input [`window_width-1:0] r;
	//output
	output [`window_width-1:0] Ad_3BUF;
	//output dir_3BUF;
	
	reg [`window_width-1:0] Ad_3BUF;
	reg dir_3BUF;
	reg [1:0] Flag;
	wire [`CmpCounter_width-1:0] CmpCounter_sub_1;
	wire [`CmpCounter_width-1:0] CmpCounter_sub_2;
	//add for various code length
	wire [`window_width+3:0] q_up_add_1_mul_B;
	wire [`window_width+1:0] B_sub_r;
	assign q_up_add_1_mul_B = (q_up+1'b1) << `window_width;
	assign B_sub_r = 8'b01000000 + {2'b11,~r[`window_width-1:0]+1'b1};
	
	assign CmpCounter_sub_1 = CmpCounter - 1'b1;
	assign CmpCounter_sub_2 = CmpCounter - 2'b10;
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			dir_3BUF <= 0;
			Flag <= 0;
		end
		else if(CmpCounter == 0)
		begin
			dir_3BUF <= initDir;
			Flag <= initFlag;
		end
		else
		begin
			if(CmpCounter_sub_1[`window_width-1:0] == 6'b0 && CmpCounter > 1)////修改此处，使得3块数据BUF的dir_3BUF和Flag提前或后延
			begin
				if(Flag==2'b10)
				begin
					dir_3BUF <= ~dir_3BUF;
					Flag <= 2'b00;
				end
				else
				begin
					Flag <= Flag + 2'b01;
				end
			end
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Ad_3BUF <= 6'b0;
		end
		else if(CmpCounter_sub_2[`window_width-1:0] == 6'b0)////修改此处，使得3块数据BUF的Ad_3BUF提前或后延
		begin
		//add
			if(r!=0 && final_BUF_flag==1'b1 && CmpCounter_sub_2==q_up_add_1_mul_B)
			begin
				Ad_3BUF <= dir_3BUF ? B_sub_r : (r-1'b1);
			end
		//add
			else
			begin
				Ad_3BUF <= dir_3BUF ? 6'b0 : 6'b111111;
			end
		end
		else
		begin
			if(dir_3BUF == 0)
			begin
				Ad_3BUF <= Ad_3BUF - 1'b1;
			end
			else
			begin
				Ad_3BUF <= Ad_3BUF + 1'b1;
			end
		end
	end
				


endmodule
