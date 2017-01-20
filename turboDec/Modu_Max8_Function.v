/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_Max8_Function.v
* Abstract: This is the verilog file that choose the maximum value of the 8 inputs
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_Max8_Function(
	//input
	clk,data_in_0,data_in_1,data_in_2,data_in_3,data_in_4,data_in_5,data_in_6,data_in_7,
	//output
	data_out_max
	);
	//input
	input clk;
	input [`beta_alpha_width+1:0] data_in_0;
	input [`beta_alpha_width+1:0] data_in_1;
	input [`beta_alpha_width+1:0] data_in_2;
	input [`beta_alpha_width+1:0] data_in_3;
	input [`beta_alpha_width+1:0] data_in_4;
	input [`beta_alpha_width+1:0] data_in_5;
	input [`beta_alpha_width+1:0] data_in_6;
	input [`beta_alpha_width+1:0] data_in_7;
	//output
	output [`beta_alpha_width+1:0] data_out_max;
	
	reg [`beta_alpha_width+1:0] data_out_max;
	
	wire [`beta_alpha_width+1:0] max01;
	wire [`beta_alpha_width+1:0] max23;
	wire [`beta_alpha_width+1:0] max45;
	wire [`beta_alpha_width+1:0] max67;
	wire [`beta_alpha_width+1:0] max0123;
	wire [`beta_alpha_width+1:0] max4567;
	wire [`beta_alpha_width+1:0] max01234567;
	reg [`beta_alpha_width+1:0] reg_max01;
	reg [`beta_alpha_width+1:0] reg_max23;
	reg [`beta_alpha_width+1:0] reg_max45;
	reg [`beta_alpha_width+1:0] reg_max67;
	reg [`beta_alpha_width+1:0] reg_max0123;
	reg [`beta_alpha_width+1:0] reg_max4567;
	
	always @(posedge clk)
	begin
		reg_max01 <= max01;
		reg_max23 <= max23;
		reg_max45 <= max45;
		reg_max67 <= max67;
		reg_max0123 <= max0123;
		reg_max4567 <= max4567;
		data_out_max <= max01234567;
	end
	
	Modu_MaxFunction MaxFunction01(.data_in_0(data_in_0),.data_in_1(data_in_1),.data_out_max(max01));
	Modu_MaxFunction MaxFunction23(.data_in_0(data_in_2),.data_in_1(data_in_3),.data_out_max(max23));
	Modu_MaxFunction MaxFunction45(.data_in_0(data_in_4),.data_in_1(data_in_5),.data_out_max(max45));
	Modu_MaxFunction MaxFunction67(.data_in_0(data_in_6),.data_in_1(data_in_7),.data_out_max(max67));
	
	Modu_MaxFunction MaxFunction0123(.data_in_0(reg_max01),.data_in_1(reg_max23),.data_out_max(max0123));
	Modu_MaxFunction MaxFunction4567(.data_in_0(reg_max45),.data_in_1(reg_max67),.data_out_max(max4567));
	
	Modu_MaxFunction MaxFunction01234567(.data_in_0(reg_max0123),.data_in_1(reg_max4567),.data_out_max(max01234567));
	


endmodule
