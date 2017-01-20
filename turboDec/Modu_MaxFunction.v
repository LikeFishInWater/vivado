/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_MaxFunction.v
* Abstract: This is the verilog file that choose the maximum value of the 2 inputs
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_MaxFunction(
	//input
	data_in_0,data_in_1,
	//output
	data_out_max
	);
	input [`beta_alpha_width+1:0] data_in_0;
	input [`beta_alpha_width+1:0] data_in_1;
	output [`beta_alpha_width+1:0] data_out_max;
	reg [`beta_alpha_width+1:0] data_out_max;
	
	wire [`beta_alpha_width+1:0] in0_sub_in1;
	wire [`beta_alpha_width+1:0] data_out_max_temp;
	
	assign in0_sub_in1 = data_in_0[`beta_alpha_width+1:0] + {~data_in_1[`beta_alpha_width+1:0] + 1'b1};
	assign data_out_max_temp = in0_sub_in1[`beta_alpha_width+1] ? data_in_1 : data_in_0;
	
	always @(data_out_max_temp)
	begin
		data_out_max <= data_out_max_temp;
	end


endmodule
