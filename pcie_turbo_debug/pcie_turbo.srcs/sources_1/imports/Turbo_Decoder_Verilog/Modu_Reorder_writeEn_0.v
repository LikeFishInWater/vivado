/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_Reorder_writeEn_0.v
* Abstract: This is the verilog file that reorder the output of a RAM
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

/*前仿测试结果正确*/
module Modu_Reorder_writeEn_0(
	//input
	clk,data_in,resortSE,
	//output
	data_out
    );
	parameter width = 5'd00001;
	
	input clk;
	input [width*8-1:0] data_in;
	input [23:0] resortSE;
	output [width*8-1:0] data_out;
	
	//reg [width*8-1:0] data_out;
	wire [width-1:0] d0,d1,d2,d3,d4,d5,d6,d7;

	assign data_out = {d7,d6,d5,d4,d3,d2,d1,d0};
	
	//Sort and choose the correct data for subdecoder_0
	Modu_Interleave #(width) Interleave_0(
	//input
	.clk(clk),.resortSE_id(resortSE[2:0]),.data_in(data_in),
	//output
	.data_out(d0)
	);
	
	//Sort and choose the correct data for subdecoder_1
	Modu_Interleave #(width) Interleave_1(
	//input
	.clk(clk),.resortSE_id(resortSE[5:3]),.data_in(data_in),
	//output
	.data_out(d1)
	);
	
	//Sort and choose the correct data for subdecoder_2
	Modu_Interleave #(width) Interleave_2(
	//input
	.clk(clk),.resortSE_id(resortSE[8:6]),.data_in(data_in),
	//output
	.data_out(d2)
	);
	
	//Sort and choose the correct data for subdecoder_3
	Modu_Interleave #(width) Interleave_3(
	//input
	.clk(clk),.resortSE_id(resortSE[11:9]),.data_in(data_in),
	//output
	.data_out(d3)
	);
	
	//Sort and choose the correct data for subdecoder_4
	Modu_Interleave #(width) Interleave_4(
	//input
	.clk(clk),.resortSE_id(resortSE[14:12]),.data_in(data_in),
	//output
	.data_out(d4)
	);
	
	//Sort and choose the correct data for subdecoder_5
	Modu_Interleave #(width) Interleave_5(
	//input
	.clk(clk),.resortSE_id(resortSE[17:15]),.data_in(data_in),
	//output
	.data_out(d5)
	);
	
	//Sort and choose the correct data for subdecoder_6
	Modu_Interleave #(width) Interleave_6(
	//input
	.clk(clk),.resortSE_id(resortSE[20:18]),.data_in(data_in),
	//output
	.data_out(d6)
	);
	
	//Sort and choose the correct data for subdecoder_7
	Modu_Interleave #(width) Interleave_7(
	//input
	.clk(clk),.resortSE_id(resortSE[23:21]),.data_in(data_in),
	//output
	.data_out(d7)
	);
		
endmodule

