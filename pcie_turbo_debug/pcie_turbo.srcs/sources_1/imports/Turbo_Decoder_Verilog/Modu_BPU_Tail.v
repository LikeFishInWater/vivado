/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_BPU_Tail.v
* Abstract: This is the verilog file that do the backward computation for the 12 tail-bits,
* and give the Init_Value module its results
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_BPU_Tail(
	//input
	clk,Init_Flag_BPU_tail,BPU_tail_data_In,
	//output
	Beta_temp
	);
	//input
	input clk;
	input Init_Flag_BPU_tail;
	input [`sys_par_width*2-1:0] BPU_tail_data_In;
	//output
	output [`beta_alpha_width*8-1:0] Beta_temp;
	
	wire [`beta_alpha_width*8-1:0] Beta_temp;
	reg [`beta_alpha_width-1:0] B0,B1,B2,B3,B4,B5,B6,B7;
	wire [`beta_alpha_width-1:0] B_temp0,B_temp1,B_temp2,B_temp3,B_temp4,B_temp5,B_temp6,B_temp7;
	wire [`beta_alpha_width-1:0] Normalize_Value;
	wire [`sys_par_width-1:0] System_bit;
	wire [`sys_par_width-1:0] parity_bit;
	wire [`Le_sys_par_width-1:0] La_bit;
	wire [`Le_sys_par_width+1:0] sysAddLePar0,sysAddLePar1,Neg_sysAddLePar0,Neg_sysAddLePar1;
	
	assign System_bit = BPU_tail_data_In[`sys_par_width-1:0];
	assign parity_bit = BPU_tail_data_In[`sys_par_width*2-1:`sys_par_width];
	assign La_bit = {`Le_sys_par_width{1'b0}};
	assign Normalize_Value = B1;
	assign Beta_temp = {B_temp7,B_temp6,B_temp5,B_temp4,B_temp3,B_temp2,B_temp1,B_temp0};
	
	Modu_sysAddLePar_Compute sysAddLePar_Compute_BPU_tail(//计算分支度量，占用一个clk
	//input
	.clk(clk),.System(System_bit),.Parity(parity_bit),.La(La_bit),
	//output
	.sysAddLePar0(sysAddLePar0),.sysAddLePar1(sysAddLePar1),
	.Neg_sysAddLePar0(Neg_sysAddLePar0),.Neg_sysAddLePar1(Neg_sysAddLePar1)
	);
	
	Modu_Butterfly Butterfly_01_04(
	//input
	.cValue0(B0),.cValue1(B1),.sysAddLePar(sysAddLePar0),.Neg_sysAddLePar(Neg_sysAddLePar0),.Normalize_Value(Normalize_Value),
	//output
	.Out_Value0(B_temp0),.Out_Value1(B_temp4)
	);
	
	Modu_Butterfly Butterfly_23_15(
	//input
	.cValue0(B2),.cValue1(B3),.sysAddLePar(sysAddLePar1),.Neg_sysAddLePar(Neg_sysAddLePar1),.Normalize_Value(Normalize_Value),
	//output
	.Out_Value0(B_temp1),.Out_Value1(B_temp5)
	);
	
	Modu_Butterfly Butterfly_45_26(
	//input
	.cValue0(B4),.cValue1(B5),.sysAddLePar(Neg_sysAddLePar1),.Neg_sysAddLePar(sysAddLePar1),.Normalize_Value(Normalize_Value),
	//output
	.Out_Value0(B_temp2),.Out_Value1(B_temp6)
	);
	
	Modu_Butterfly Butterfly_67_37(
	//input
	.cValue0(B6),.cValue1(B7),.sysAddLePar(Neg_sysAddLePar0),.Neg_sysAddLePar(sysAddLePar0),.Normalize_Value(Normalize_Value),
	//output
	.Out_Value0(B_temp3),.Out_Value1(B_temp7)
	);
	
	always @(posedge clk)
	begin
		if(Init_Flag_BPU_tail == 1'b1)
		begin
			B0 <= {`beta_alpha_width{1'b0}};
			B1 <= {2'b11,{(`beta_alpha_width-2){1'b0}}};
			B2 <= {2'b11,{(`beta_alpha_width-2){1'b0}}};
			B3 <= {2'b11,{(`beta_alpha_width-2){1'b0}}};
			B4 <= {2'b11,{(`beta_alpha_width-2){1'b0}}};
			B5 <= {2'b11,{(`beta_alpha_width-2){1'b0}}};
			B6 <= {2'b11,{(`beta_alpha_width-2){1'b0}}};
			B7 <= {2'b11,{(`beta_alpha_width-2){1'b0}}};
		end
		else
		begin
			B0 <= B_temp0;
			B1 <= B_temp1;
			B2 <= B_temp2;
			B3 <= B_temp3;
			B4 <= B_temp4;
			B5 <= B_temp5;
			B6 <= B_temp6;
			B7 <= B_temp7;
		end
	end


endmodule
