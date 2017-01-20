/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_Butterfly.v
* Abstract: This is the verilog file that do butterfly computation in FPU and BPU
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"
module Modu_Butterfly(
	//input
	cValue0,cValue1,sysAddLePar,Neg_sysAddLePar,Normalize_Value,
	//output
	Out_Value0,Out_Value1
	);
	
	input [`beta_alpha_width-1:0] cValue0;
	input [`beta_alpha_width-1:0] cValue1;
	input [`Le_sys_par_width+1:0] sysAddLePar;
	input [`Le_sys_par_width+1:0] Neg_sysAddLePar;
	input [`beta_alpha_width-1:0] Normalize_Value;
	output [`beta_alpha_width-1:0] Out_Value0;
	output [`beta_alpha_width-1:0] Out_Value1;
	
	reg [`beta_alpha_width-1:0] Out_Value0;
	reg [`beta_alpha_width-1:0] Out_Value1;
	
	wire [`beta_alpha_width+1:0] Out_Value0_temp;
	wire [`beta_alpha_width+1:0] Out_Value1_temp;
	wire [`beta_alpha_width+1:0] Out_Value0_temp_norm;
	wire [`beta_alpha_width+1:0] Out_Value1_temp_norm;
	
	wire [`beta_alpha_width+1:0] temp1;//beta_alpha_width>Le_sys_par_width
	wire [`beta_alpha_width+1:0] temp2;
	wire [`beta_alpha_width+1:0] temp3;
	wire [`beta_alpha_width+1:0] temp4;
	
	assign temp1 = {{2{cValue0[`beta_alpha_width-1]}},cValue0} 
	+ {{(`beta_alpha_width-`Le_sys_par_width){sysAddLePar[`Le_sys_par_width+1]}},sysAddLePar};
	
	assign temp3 = {{2{cValue0[`beta_alpha_width-1]}},cValue0} 
	+ {{(`beta_alpha_width-`Le_sys_par_width){Neg_sysAddLePar[`Le_sys_par_width+1]}},Neg_sysAddLePar};
	
	assign temp2 = {{2{cValue1[`beta_alpha_width-1]}},cValue1} 
	+ {{(`beta_alpha_width-`Le_sys_par_width){Neg_sysAddLePar[`Le_sys_par_width+1]}},Neg_sysAddLePar};
	
	assign temp4 = {{2{cValue1[`beta_alpha_width-1]}},cValue1}
	+ {{(`beta_alpha_width-`Le_sys_par_width){sysAddLePar[`Le_sys_par_width+1]}},sysAddLePar};
	
	assign Out_Value0_temp_norm = Out_Value0_temp - {{2{Normalize_Value[`beta_alpha_width-1]}},Normalize_Value};
	assign Out_Value1_temp_norm = Out_Value1_temp - {{2{Normalize_Value[`beta_alpha_width-1]}},Normalize_Value};
	
	Modu_MaxFunction MaxFunction_Value0(
	//input
	.data_in_0(temp1),.data_in_1(temp2),
	//output
	.data_out_max(Out_Value0_temp)
	);
	
	Modu_MaxFunction MaxFunction_Value1(
	//input
	.data_in_0(temp3),.data_in_1(temp4),
	//output
	.data_out_max(Out_Value1_temp)
	);
	
	always @(Out_Value0_temp_norm)
	begin
		if((|(Out_Value0_temp_norm[`beta_alpha_width+1:`beta_alpha_width-1])) == 1'b0		//positive limited
		|| (&(Out_Value0_temp_norm[`beta_alpha_width+1:`beta_alpha_width-1])) == 1'b1)	//negative limited
		begin
			Out_Value0[`beta_alpha_width-1:0] <= Out_Value0_temp_norm[`beta_alpha_width-1:0];
		end
		else
		begin
			if(Out_Value0_temp_norm[`beta_alpha_width+1])//¸º
			begin
				Out_Value0[`beta_alpha_width-1:0] <= {1'b1,{(`beta_alpha_width-1){1'b0}}};
			end
			else
			begin
				Out_Value0[`beta_alpha_width-1:0] <= {1'b0,{(`beta_alpha_width-1){1'b1}}};
			end
		end
	end
	
	always @(Out_Value1_temp_norm)
	begin
		if((|(Out_Value1_temp_norm[`beta_alpha_width+1:`beta_alpha_width-1])) == 1'b0		//positive limited
		|| (&(Out_Value1_temp_norm[`beta_alpha_width+1:`beta_alpha_width-1])) == 1'b1)	//negative limited
		begin
			Out_Value1[`beta_alpha_width-1:0] <= Out_Value1_temp_norm[`beta_alpha_width-1:0];
		end
		else
		begin
			if(Out_Value1_temp_norm[`beta_alpha_width+1])
			begin
				Out_Value1[`beta_alpha_width-1:0] <= {1'b1,{(`beta_alpha_width-1){1'b0}}};
			end
			else
			begin
				Out_Value1[`beta_alpha_width-1:0] <= {1'b0,{(`beta_alpha_width-1){1'b1}}};
			end
		end
	end


endmodule
