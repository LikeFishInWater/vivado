/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_FPU.v
* Abstract: This is the verilog file that do the farward computation in the parallel subdecoders.
* Description: alphaValueOut_next用来对下一滑窗的FPU计算赋初值。此处的设计和林炳的有些不同，其中的initAlpha
* 值由main_control单元提供，不需要本FPU计算单元进行选择
* 默认为max-log-MAP算法
* initAlpha的取值问题：
*1、对于第0个并行子译码器的第0个滑窗的FPU运算，其初值始终为0和-1236；
*2、对于第0个并行子译码器的其余滑窗的FPU运算，其初值有上一个滑窗提供；
*3、对于其余并行子译码器的第0个滑窗的FPU运算，首次内迭代时为0；后面的内迭代时由上一个并行子译码器的计算结果提供；
*4、对于其余子译码器的其余滑窗，其初值由相应的上一个滑窗提供
*5、Init_Flag_FPU信号每次内迭代只出现一次，即在每个子译码器的第0个滑窗的第0次计算FPU时。对于后续的滑窗，初值即为
*alphaValueOut_next
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"
module Modu_FPU(
	//input
	clk,Iter,blockIndex,Init_Flag_FPU,initAlpha,
	data_In_FPU,alphaValueOut,alphaValueOut_next
	);
	
	input clk;
	input [3:0] Iter;
	input [2:0] blockIndex;
	input Init_Flag_FPU;//每次内迭代只出现一次
	input [`beta_alpha_width*8-1:0] initAlpha;
	input [`sys_par_width*2+`Le_sys_par_width-1:0] data_In_FPU;
	output [`beta_alpha_width*8-1:0] alphaValueOut;
	output [`beta_alpha_width*8-1:0] alphaValueOut_next;
	
	reg  [`beta_alpha_width-1:0] A0,A1,A2,A3,A4,A5,A6,A7;
	
	wire [`beta_alpha_width*8-1:0] alphaValueOut;
	wire [`beta_alpha_width*8-1:0] alphaValueOut_next;
	wire [`Le_sys_par_width-1:0] La;
	wire [`sys_par_width-1:0] System;
	wire [`sys_par_width-1:0] Parity;
	wire [`Le_sys_par_width+1:0] sysAddLePar0,sysAddLePar1,Neg_sysAddLePar0,Neg_sysAddLePar1;
	wire [`beta_alpha_width-1:0] Normalize_Value;
	wire [`beta_alpha_width-1:0] A_temp0,A_temp1,A_temp2,A_temp3,A_temp4,A_temp5,A_temp6,A_temp7;
	
	assign System = data_In_FPU[`sys_par_width-1:0];
	assign Parity = data_In_FPU[`sys_par_width*2-1:`sys_par_width];
	assign La = data_In_FPU[`sys_par_width*2+`Le_sys_par_width-1:`sys_par_width*2];
	assign Normalize_Value = A1;
	assign alphaValueOut = {A7,A6,A5,A4,A3,A2,A1,A0};
	assign alphaValueOut_next = {A_temp7,A_temp6,A_temp5,A_temp4,A_temp3,A_temp2,A_temp1,A_temp0};
	
	Modu_sysAddLePar_Compute sysAddLePar_Compute_FPU(//计算分支度量，占用一个clk
	//input
	.clk(clk),.System(System),.Parity(Parity),.La(La),
	//output
	.sysAddLePar0(sysAddLePar0),.sysAddLePar1(sysAddLePar1),
	.Neg_sysAddLePar0(Neg_sysAddLePar0),.Neg_sysAddLePar1(Neg_sysAddLePar1)
	);
	
	Modu_Butterfly Butterfly_04_01(
	//input
	.cValue0(A0),.cValue1(A4),.sysAddLePar(sysAddLePar0),.Neg_sysAddLePar(Neg_sysAddLePar0),.Normalize_Value(Normalize_Value),
	//output
	.Out_Value0(A_temp0),.Out_Value1(A_temp1)
	);
	
	Modu_Butterfly Butterfly_15_23(
	//input
	.cValue0(A1),.cValue1(A5),.sysAddLePar(sysAddLePar1),.Neg_sysAddLePar(Neg_sysAddLePar1),.Normalize_Value(Normalize_Value),
	//output
	.Out_Value0(A_temp2),.Out_Value1(A_temp3)
	);
	
	Modu_Butterfly Butterfly_26_45(
	//input
	.cValue0(A2),.cValue1(A6),.sysAddLePar(Neg_sysAddLePar1),.Neg_sysAddLePar(sysAddLePar1),.Normalize_Value(Normalize_Value),
	//output
	.Out_Value0(A_temp4),.Out_Value1(A_temp5)
	);
	
	Modu_Butterfly Butterfly_37_67(
	//input
	.cValue0(A3),.cValue1(A7),.sysAddLePar(Neg_sysAddLePar0),.Neg_sysAddLePar(sysAddLePar0),.Normalize_Value(Normalize_Value),
	//output
	.Out_Value0(A_temp6),.Out_Value1(A_temp7)
	);
	
	always @(posedge clk)
	begin
		if(Init_Flag_FPU == 1'b1)
		begin
			if(blockIndex == 3'b000)
			begin
				A0 <= {`beta_alpha_width{1'b0}};
				A1 <= {2'b11,{(`beta_alpha_width-2){1'b0}}};
				A2 <= {2'b11,{(`beta_alpha_width-2){1'b0}}};
				A3 <= {2'b11,{(`beta_alpha_width-2){1'b0}}};
				A4 <= {2'b11,{(`beta_alpha_width-2){1'b0}}};
				A5 <= {2'b11,{(`beta_alpha_width-2){1'b0}}};
				A6 <= {2'b11,{(`beta_alpha_width-2){1'b0}}};
				A7 <= {2'b11,{(`beta_alpha_width-2){1'b0}}};
			end
			else
			begin
				A0 <= (Iter == 0) ? {`beta_alpha_width{1'b0}} : initAlpha[`beta_alpha_width-1:0];
				A1 <= (Iter == 0) ? {`beta_alpha_width{1'b0}} : initAlpha[`beta_alpha_width*2-1:`beta_alpha_width*1];
				A2 <= (Iter == 0) ? {`beta_alpha_width{1'b0}} : initAlpha[`beta_alpha_width*3-1:`beta_alpha_width*2];
				A3 <= (Iter == 0) ? {`beta_alpha_width{1'b0}} : initAlpha[`beta_alpha_width*4-1:`beta_alpha_width*3];
				A4 <= (Iter == 0) ? {`beta_alpha_width{1'b0}} : initAlpha[`beta_alpha_width*5-1:`beta_alpha_width*4];
				A5 <= (Iter == 0) ? {`beta_alpha_width{1'b0}} : initAlpha[`beta_alpha_width*6-1:`beta_alpha_width*5];
				A6 <= (Iter == 0) ? {`beta_alpha_width{1'b0}} : initAlpha[`beta_alpha_width*7-1:`beta_alpha_width*6];
				A7 <= (Iter == 0) ? {`beta_alpha_width{1'b0}} : initAlpha[`beta_alpha_width*8-1:`beta_alpha_width*7];
			end
		end
		else
		begin
			A0 <= A_temp0;
			A1 <= A_temp1;
			A2 <= A_temp2;
			A3 <= A_temp3;
			A4 <= A_temp4;
			A5 <= A_temp5;
			A6 <= A_temp6;
			A7 <= A_temp7;
		end
	end
	
endmodule

