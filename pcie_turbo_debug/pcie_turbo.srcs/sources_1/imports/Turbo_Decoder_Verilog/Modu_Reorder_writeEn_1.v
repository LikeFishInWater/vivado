/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_Reorder_writeEn_1.v
* Abstract: This is the verilog file that reorder the input of a RAM
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

/*前仿测试结果正确*/
module Modu_Reorder_writeEn_1(//调用格式为Modu_Reorder_writeEn_1 #(width) Reorder_writeEn_1{}
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
	
	wire [width*8-1:0] d0,d1,d2,d3,d4,d5,d6,d7;
	
	assign data_out = d0 ^ d1 ^ d2 ^ d3 ^ d4 ^ d5 ^ d6 ^ d7;
	
	//Sort and choose the correct store address for the Le of subdecoder_0
	Modu_Deinterleave #(width) Deinterleave_0(
   //input
   .clk(clk),.resortSE_id(resortSE[2:0]),.data_in(data_in[width-1:0]),
   //output
   .data_out(d0)
	);
	
	//Sort and choose the correct store address for the Le of subdecoder_1
	Modu_Deinterleave #(width) Deinterleave_1(
   //input
   .clk(clk),.resortSE_id(resortSE[5:3]),.data_in(data_in[width*2-1:width]),
   //output
   .data_out(d1)
	);
	
	//Sort and choose the correct store address for the Le of subdecoder_2
	Modu_Deinterleave #(width) Deinterleave_2(
   //input
   .clk(clk),.resortSE_id(resortSE[8:6]),.data_in(data_in[width*3-1:width*2]),
   //output
   .data_out(d2)
	);
	
	//Sort and choose the correct store address for the Le of subdecoder_3
	Modu_Deinterleave #(width) Deinterleave_3(
   //input
   .clk(clk),.resortSE_id(resortSE[11:9]),.data_in(data_in[width*4-1:width*3]),
   //output
   .data_out(d3)
	);
	
	//Sort and choose the correct store address for the Le of subdecoder_4
	Modu_Deinterleave #(width) Deinterleave_4(
   //input
   .clk(clk),.resortSE_id(resortSE[14:12]),.data_in(data_in[width*5-1:width*4]),
   //output
   .data_out(d4)
	);
	
	//Sort and choose the correct store address for the Le of subdecoder_5
	Modu_Deinterleave #(width) Deinterleave_5(
   //input
   .clk(clk),.resortSE_id(resortSE[17:15]),.data_in(data_in[width*6-1:width*5]),
   //output
   .data_out(d5)
	);
	
	//Sort and choose the correct store address for the Le of subdecoder_6
	Modu_Deinterleave #(width) Deinterleave_6(
   //input
   .clk(clk),.resortSE_id(resortSE[20:18]),.data_in(data_in[width*7-1:width*6]),
   //output
   .data_out(d6)
	);
	
	//Sort and choose the correct store address for the Le of subdecoder_7
	Modu_Deinterleave #(width) Deinterleave_7(
   //input
   .clk(clk),.resortSE_id(resortSE[23:21]),.data_in(data_in[width*8-1:width*7]),
   //output
   .data_out(d7)
	);

endmodule
