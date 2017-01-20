/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_LLR.v
* Abstract: This is the verilog file that compute the soft-output and the hard-output
* in the BPU module
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_LLR(
	//input
	clk,System,Parity,La,Beta,Alpha,
	//output
	Le_sys,Le_par,D
	);
	//input
	input clk;
	input [`sys_par_width-1:0] System;
	input [`sys_par_width-1:0] Parity;
	input [`Le_sys_par_width-1:0] La;
	input [`beta_alpha_width*8-1:0] Beta;
	input [`beta_alpha_width*8-1:0] Alpha;
	//output
	output [`Le_sys_par_width-1:0] Le_sys;
	output [`Le_sys_par_width-1:0] Le_par;
	output D;
	
	wire [`Le_sys_par_width:0] Sys_add_La;
	wire [`Le_sys_par_width+1:0] Sys_add_La_mul_2;
	wire [`Le_sys_par_width+1:0] Sys_add_La_mul_2_delay3;
	wire [`beta_alpha_width-1:0] A7,A6,A5,A4,A3,A2,A1,A0;
	wire [`beta_alpha_width-1:0] B7,B6,B5,B4,B3,B2,B1,B0;
	
	wire [`beta_alpha_width+1:0] A0_add_B0_add_par,A4_add_B1_add_par,A1_add_B2_sub_par,A5_add_B3_sub_par,
										  A6_add_B4_sub_par,A2_add_B5_sub_par,A7_add_B6_add_par,A3_add_B7_add_par;
	wire [`beta_alpha_width+1:0] A4_add_B0_sub_par,A0_add_B1_sub_par,A5_add_B2_add_par,A1_add_B3_add_par,
										  A2_add_B4_add_par,A6_add_B5_add_par,A3_add_B6_sub_par,A7_add_B7_sub_par;
	wire [`beta_alpha_width+1:0] Max8_Le_sys1,Max8_Le_sys2;
	
	wire [`beta_alpha_width+1:0] A0_add_B0_add_sysAddLe,A4_add_B1_add_sysAddLe,A5_add_B2_sub_sysAddLe,A1_add_B3_sub_sysAddLe,
										  A2_add_B4_sub_sysAddLe,A6_add_B5_sub_sysAddLe,A7_add_B6_add_sysAddLe,A3_add_B7_add_sysAddLe;
	wire [`beta_alpha_width+1:0] A4_add_B0_sub_sysAddLe,A0_add_B1_sub_sysAddLe,A1_add_B2_add_sysAddLe,A5_add_B3_add_sysAddLe,
										  A6_add_B4_add_sysAddLe,A2_add_B5_add_sysAddLe,A3_add_B6_sub_sysAddLe,A7_add_B7_sub_sysAddLe;
	wire [`beta_alpha_width+1:0] Max8_Le_par1,Max8_Le_par2;
	
	wire [`beta_alpha_width+2:0] Le_sys_temp;
	wire [`beta_alpha_width+2:0] Le_par_temp;
	wire [`beta_alpha_width+2:0] Le_sys_temp_mul_opt;
	wire [`beta_alpha_width+2:0] Le_par_temp_mul_opt;
	wire [`beta_alpha_width+3:0] D_temp;
	reg [`Le_sys_par_width-1:0] Le_sys;
	reg [`Le_sys_par_width-1:0] Le_par;
	reg D;
	
	assign A0 = Alpha[`beta_alpha_width-1:0];
	assign A1 = Alpha[`beta_alpha_width*2-1:`beta_alpha_width];
	assign A2 = Alpha[`beta_alpha_width*3-1:`beta_alpha_width*2];
	assign A3 = Alpha[`beta_alpha_width*4-1:`beta_alpha_width*3];
	assign A4 = Alpha[`beta_alpha_width*5-1:`beta_alpha_width*4];
	assign A5 = Alpha[`beta_alpha_width*6-1:`beta_alpha_width*5];
	assign A6 = Alpha[`beta_alpha_width*7-1:`beta_alpha_width*6];
	assign A7 = Alpha[`beta_alpha_width*8-1:`beta_alpha_width*7];
	assign B0 = Beta[`beta_alpha_width-1:0];
	assign B1 = Beta[`beta_alpha_width*2-1:`beta_alpha_width];
	assign B2 = Beta[`beta_alpha_width*3-1:`beta_alpha_width*2];
	assign B3 = Beta[`beta_alpha_width*4-1:`beta_alpha_width*3];
	assign B4 = Beta[`beta_alpha_width*5-1:`beta_alpha_width*4];
	assign B5 = Beta[`beta_alpha_width*6-1:`beta_alpha_width*5];
	assign B6 = Beta[`beta_alpha_width*7-1:`beta_alpha_width*6];
	assign B7 = Beta[`beta_alpha_width*8-1:`beta_alpha_width*7];
	
	/*16 values for the Le_sys computation*/
	assign A0_add_B0_add_par = {{2{A0[`beta_alpha_width-1]}},A0}+{{2{B0[`beta_alpha_width-1]}},B0}
										+ {{(`beta_alpha_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	assign A4_add_B1_add_par = {{2{A4[`beta_alpha_width-1]}},A4}+{{2{B1[`beta_alpha_width-1]}},B1}
										+ {{(`beta_alpha_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	assign A1_add_B2_sub_par = {{2{A1[`beta_alpha_width-1]}},A1}+{{2{B2[`beta_alpha_width-1]}},B2}
										- {{(`beta_alpha_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	assign A5_add_B3_sub_par = {{2{A5[`beta_alpha_width-1]}},A5}+{{2{B3[`beta_alpha_width-1]}},B3}
										- {{(`beta_alpha_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	assign A6_add_B4_sub_par = {{2{A6[`beta_alpha_width-1]}},A6}+{{2{B4[`beta_alpha_width-1]}},B4}
										- {{(`beta_alpha_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	assign A2_add_B5_sub_par = {{2{A2[`beta_alpha_width-1]}},A2}+{{2{B5[`beta_alpha_width-1]}},B5}
										- {{(`beta_alpha_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	assign A7_add_B6_add_par = {{2{A7[`beta_alpha_width-1]}},A7}+{{2{B6[`beta_alpha_width-1]}},B6}
										+ {{(`beta_alpha_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	assign A3_add_B7_add_par = {{2{A3[`beta_alpha_width-1]}},A3}+{{2{B7[`beta_alpha_width-1]}},B7}
										+ {{(`beta_alpha_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	
	assign A4_add_B0_sub_par = {{2{A4[`beta_alpha_width-1]}},A4}+{{2{B0[`beta_alpha_width-1]}},B0}
										- {{(`beta_alpha_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	assign A0_add_B1_sub_par = {{2{A0[`beta_alpha_width-1]}},A0}+{{2{B1[`beta_alpha_width-1]}},B1}
										- {{(`beta_alpha_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	assign A5_add_B2_add_par = {{2{A5[`beta_alpha_width-1]}},A5}+{{2{B2[`beta_alpha_width-1]}},B2}
										+ {{(`beta_alpha_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	assign A1_add_B3_add_par = {{2{A1[`beta_alpha_width-1]}},A1}+{{2{B3[`beta_alpha_width-1]}},B3}
										+ {{(`beta_alpha_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	assign A2_add_B4_add_par = {{2{A2[`beta_alpha_width-1]}},A2}+{{2{B4[`beta_alpha_width-1]}},B4}
										+ {{(`beta_alpha_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	assign A6_add_B5_add_par = {{2{A6[`beta_alpha_width-1]}},A6}+{{2{B5[`beta_alpha_width-1]}},B5}
										+ {{(`beta_alpha_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	assign A3_add_B6_sub_par = {{2{A3[`beta_alpha_width-1]}},A3}+{{2{B6[`beta_alpha_width-1]}},B6}
										- {{(`beta_alpha_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	assign A7_add_B7_sub_par = {{2{A7[`beta_alpha_width-1]}},A7}+{{2{B7[`beta_alpha_width-1]}},B7}
										- {{(`beta_alpha_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	
	/*16 values for the Le_par computation*/
	assign A0_add_B0_add_sysAddLe = {{2{A0[`beta_alpha_width-1]}},A0}+{{2{B0[`beta_alpha_width-1]}},B0}
							+ {{(`beta_alpha_width+1-`Le_sys_par_width){Sys_add_La[`Le_sys_par_width]}},Sys_add_La};
	assign A4_add_B1_add_sysAddLe = {{2{A4[`beta_alpha_width-1]}},A4}+{{2{B1[`beta_alpha_width-1]}},B1}
							+ {{(`beta_alpha_width+1-`Le_sys_par_width){Sys_add_La[`Le_sys_par_width]}},Sys_add_La};
	assign A5_add_B2_sub_sysAddLe = {{2{A5[`beta_alpha_width-1]}},A5}+{{2{B2[`beta_alpha_width-1]}},B2}
							- {{(`beta_alpha_width+1-`Le_sys_par_width){Sys_add_La[`Le_sys_par_width]}},Sys_add_La};
	assign A1_add_B3_sub_sysAddLe = {{2{A1[`beta_alpha_width-1]}},A1}+{{2{B3[`beta_alpha_width-1]}},B3}
							- {{(`beta_alpha_width+1-`Le_sys_par_width){Sys_add_La[`Le_sys_par_width]}},Sys_add_La};
	assign A2_add_B4_sub_sysAddLe = {{2{A2[`beta_alpha_width-1]}},A2}+{{2{B4[`beta_alpha_width-1]}},B4}
							- {{(`beta_alpha_width+1-`Le_sys_par_width){Sys_add_La[`Le_sys_par_width]}},Sys_add_La};
	assign A6_add_B5_sub_sysAddLe = {{2{A6[`beta_alpha_width-1]}},A6}+{{2{B5[`beta_alpha_width-1]}},B5}
							- {{(`beta_alpha_width+1-`Le_sys_par_width){Sys_add_La[`Le_sys_par_width]}},Sys_add_La};
	assign A7_add_B6_add_sysAddLe = {{2{A7[`beta_alpha_width-1]}},A7}+{{2{B6[`beta_alpha_width-1]}},B6}
							+ {{(`beta_alpha_width+1-`Le_sys_par_width){Sys_add_La[`Le_sys_par_width]}},Sys_add_La};
	assign A3_add_B7_add_sysAddLe = {{2{A3[`beta_alpha_width-1]}},A3}+{{2{B7[`beta_alpha_width-1]}},B7}
							+ {{(`beta_alpha_width+1-`Le_sys_par_width){Sys_add_La[`Le_sys_par_width]}},Sys_add_La};
	
	assign A4_add_B0_sub_sysAddLe = {{2{A4[`beta_alpha_width-1]}},A4}+{{2{B0[`beta_alpha_width-1]}},B0}
							- {{(`beta_alpha_width+1-`Le_sys_par_width){Sys_add_La[`Le_sys_par_width]}},Sys_add_La};
	assign A0_add_B1_sub_sysAddLe = {{2{A0[`beta_alpha_width-1]}},A0}+{{2{B1[`beta_alpha_width-1]}},B1}
							- {{(`beta_alpha_width+1-`Le_sys_par_width){Sys_add_La[`Le_sys_par_width]}},Sys_add_La};
	assign A1_add_B2_add_sysAddLe = {{2{A1[`beta_alpha_width-1]}},A1}+{{2{B2[`beta_alpha_width-1]}},B2}
							+ {{(`beta_alpha_width+1-`Le_sys_par_width){Sys_add_La[`Le_sys_par_width]}},Sys_add_La};
	assign A5_add_B3_add_sysAddLe = {{2{A5[`beta_alpha_width-1]}},A5}+{{2{B3[`beta_alpha_width-1]}},B3}
							+ {{(`beta_alpha_width+1-`Le_sys_par_width){Sys_add_La[`Le_sys_par_width]}},Sys_add_La};
	assign A6_add_B4_add_sysAddLe = {{2{A6[`beta_alpha_width-1]}},A6}+{{2{B4[`beta_alpha_width-1]}},B4}
							+ {{(`beta_alpha_width+1-`Le_sys_par_width){Sys_add_La[`Le_sys_par_width]}},Sys_add_La};
	assign A2_add_B5_add_sysAddLe = {{2{A2[`beta_alpha_width-1]}},A2}+{{2{B5[`beta_alpha_width-1]}},B5}
							+ {{(`beta_alpha_width+1-`Le_sys_par_width){Sys_add_La[`Le_sys_par_width]}},Sys_add_La};
	assign A3_add_B6_sub_sysAddLe = {{2{A3[`beta_alpha_width-1]}},A3}+{{2{B6[`beta_alpha_width-1]}},B6}
							- {{(`beta_alpha_width+1-`Le_sys_par_width){Sys_add_La[`Le_sys_par_width]}},Sys_add_La};
	assign A7_add_B7_sub_sysAddLe = {{2{A7[`beta_alpha_width-1]}},A7}+{{2{B7[`beta_alpha_width-1]}},B7}
							- {{(`beta_alpha_width+1-`Le_sys_par_width){Sys_add_La[`Le_sys_par_width]}},Sys_add_La};
	
	
	assign Sys_add_La = {{(`Le_sys_par_width+1-`sys_par_width){System[`sys_par_width-1]}},System}
	+ {{La[`Le_sys_par_width-1]},La};
	assign Sys_add_La_mul_2 = Sys_add_La << 1;
	
	//SRL16 Sys_add_La_mul_2_Delay [`Le_sys_par_width+1:0](.Q(Sys_add_La_mul_2_delay3),.A0(1'b0),.A1(1'b1),
 	//      .A2(1'b0),.A3(1'b0),.CLK(clk),.D(Sys_add_La_mul_2));
	Modu_Shift_Reg8	//delay 3
	#(`Le_sys_par_width+2) Sys_add_La_mul_2_Delay(.clk(clk),.delay(3'b010),.data_in(Sys_add_La_mul_2),.data_out(Sys_add_La_mul_2_delay3));
			
	Modu_Max8_Function Max_8_Le_sys1(
	//input
	.clk(clk),
	.data_in_0(A0_add_B0_add_par),.data_in_1(A4_add_B1_add_par),.data_in_2(A1_add_B2_sub_par),.data_in_3(A5_add_B3_sub_par),
	.data_in_4(A6_add_B4_sub_par),.data_in_5(A2_add_B5_sub_par),.data_in_6(A7_add_B6_add_par),.data_in_7(A3_add_B7_add_par),
	//output
	.data_out_max(Max8_Le_sys1)
	);
	Modu_Max8_Function Max_8_Le_sys2(
	//input
	.clk(clk),
	.data_in_0(A4_add_B0_sub_par),.data_in_1(A0_add_B1_sub_par),.data_in_2(A5_add_B2_add_par),.data_in_3(A1_add_B3_add_par),
	.data_in_4(A2_add_B4_add_par),.data_in_5(A6_add_B5_add_par),.data_in_6(A3_add_B6_sub_par),.data_in_7(A7_add_B7_sub_par),
	//output
	.data_out_max(Max8_Le_sys2)
	);
	
	Modu_Max8_Function Max_8_Le_par1(
	//input
	.clk(clk),
	.data_in_0(A0_add_B0_add_sysAddLe),.data_in_1(A4_add_B1_add_sysAddLe),.data_in_2(A5_add_B2_sub_sysAddLe),.data_in_3(A1_add_B3_sub_sysAddLe),
	.data_in_4(A2_add_B4_sub_sysAddLe),.data_in_5(A6_add_B5_sub_sysAddLe),.data_in_6(A7_add_B6_add_sysAddLe),.data_in_7(A3_add_B7_add_sysAddLe),
	//output
	.data_out_max(Max8_Le_par1)
	);
	Modu_Max8_Function Max_8_Le_par2(
	//input
	.clk(clk),
	.data_in_0(A4_add_B0_sub_sysAddLe),.data_in_1(A0_add_B1_sub_sysAddLe),.data_in_2(A1_add_B2_add_sysAddLe),.data_in_3(A5_add_B3_add_sysAddLe),
	.data_in_4(A6_add_B4_add_sysAddLe),.data_in_5(A2_add_B5_add_sysAddLe),.data_in_6(A3_add_B6_sub_sysAddLe),.data_in_7(A7_add_B7_sub_sysAddLe),
	//output
	.data_out_max(Max8_Le_par2)
	);

	assign Le_sys_temp = {Max8_Le_sys1[`beta_alpha_width+1],Max8_Le_sys1}
							 - {Max8_Le_sys2[`beta_alpha_width+1],Max8_Le_sys2};
	assign Le_par_temp = {Max8_Le_par1[`beta_alpha_width+1],Max8_Le_par1}
							 - {Max8_Le_par2[`beta_alpha_width+1],Max8_Le_par2};
	assign D_temp = {Le_sys_temp[`beta_alpha_width+2],Le_sys_temp}
					  + {{(`beta_alpha_width+2-`Le_sys_par_width){Sys_add_La_mul_2_delay3[`Le_sys_par_width+1]}},Sys_add_La_mul_2_delay3}; 
	
	always @(posedge clk)
	begin
		D <= D_temp[`beta_alpha_width+3] ? 1'b1 : 1'b0;
	end
	
	Modu_multiply_opt Le_sys_mul_opt(.clk(clk),.data_In(Le_sys_temp),.data_Out(Le_sys_temp_mul_opt));
	Modu_multiply_opt Le_par_mul_opt(.clk(clk),.data_In(Le_par_temp),.data_Out(Le_par_temp_mul_opt));
	
	always @(posedge clk)
	begin
		if((|(Le_sys_temp_mul_opt[`beta_alpha_width+2:`Le_sys_par_width-1])) == 1'b0	//positive limited
		|| (&(Le_sys_temp_mul_opt[`beta_alpha_width+2:`Le_sys_par_width-1])) == 1'b1	//negative limited
		)
		begin
			Le_sys <= Le_sys_temp_mul_opt[`Le_sys_par_width-1:0];
		end
		else
		begin
			if(Le_sys_temp_mul_opt[`beta_alpha_width+2] == 1'b1)
			begin
				Le_sys <= {1'b1,{(`Le_sys_par_width-1){1'b0}}};
			end
			else
			begin
				Le_sys <= {1'b0,{(`Le_sys_par_width-1){1'b1}}};
			end
		end
	end
	
	always @(posedge clk)
	begin
		if((|(Le_par_temp_mul_opt[`beta_alpha_width+2:`Le_sys_par_width-1])) == 1'b0	//positive limited
		|| (&(Le_par_temp_mul_opt[`beta_alpha_width+2:`Le_sys_par_width-1])) == 1'b1	//negative limited
		)
		begin
			Le_par <= Le_par_temp_mul_opt[`Le_sys_par_width-1:0];
		end
		else
		begin
			if(Le_par_temp_mul_opt[`beta_alpha_width+2] == 1'b1)
			begin
				Le_par <= {1'b1,{(`Le_sys_par_width-1){1'b0}}};
			end
			else
			begin
				Le_par <= {1'b0,{(`Le_sys_par_width-1){1'b1}}};
			end
		end
	end
	
endmodule
