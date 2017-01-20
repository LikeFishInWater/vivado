/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_CalcBufAddr_3BUF.v
* Abstract: This is the verilog file that calculate the address of BUFA
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
* Modified on 2012-04-17 for various code length in LTE
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_CalcBufA_Addr(
	//input
	clk,reset,initDir,CmpCounter,B,q_up,r,
	//output
	Ad_BUFA,dir_BUFA
	);
	//input
	input clk;
	input reset;
	input initDir;
	input [`CmpCounter_width-1:0] CmpCounter;
	input [`window_width:0] B;//1000000¹²7bits£¬window_width=6
	input [3:0] q_up;
	input [`window_width-1:0] r;
	//output
	output [`window_width-1:0] Ad_BUFA;
	output dir_BUFA;
	
	reg [`window_width-1:0] Ad_BUFA;
	reg dir_BUFA;
	wire [`CmpCounter_width-1:0] CmpCounter_sub_4;
	wire [`CmpCounter_width-1:0] CmpCounter_sub_3;
	// add for various code length
	wire [`window_width+3:0] q_up_add_1_mul_B;
	wire [`window_width+1:0] B_sub_r;
	
	assign CmpCounter_sub_4 = CmpCounter - 3'b100;
	assign CmpCounter_sub_3 = CmpCounter - 2'b11;
	assign q_up_add_1_mul_B = (q_up + 2'b01) << `window_width;
	assign B_sub_r = 8'b01000000 + {2'b11,~r[`window_width-1:0]+1'b1};
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			//Ad_BUFA <= 0;
			dir_BUFA <= 0;
		end
		else if(CmpCounter == 3)
		begin
			dir_BUFA <= initDir;
		end
		else if(CmpCounter_sub_3[`window_width-1:0] == 6'b0)
		begin
			dir_BUFA <= ~dir_BUFA;
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Ad_BUFA <= 0;
		end
		else if(CmpCounter_sub_4[`window_width-1:0] == 6'b0)
		begin
		//add
			if(CmpCounter_sub_4 == q_up_add_1_mul_B && r != 0)
			begin
				Ad_BUFA <= dir_BUFA ? B_sub_r : (r-1'b1);
			end
		//add
			else
			begin
				Ad_BUFA <= dir_BUFA ? 6'b0 : 6'b111111;
			end
		end
		else
		begin
			if(dir_BUFA == 1'b1)
			begin
				Ad_BUFA <= Ad_BUFA + 1'b1;
			end
			else
			begin
				Ad_BUFA <= Ad_BUFA - 1'b1;
			end
		end
	end

endmodule
