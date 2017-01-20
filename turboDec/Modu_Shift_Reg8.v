/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_Shift_Reg8.v
* Abstract: This is the verilog file that delays the value as you set it. The time is
* ranging from 1 to 8, the input data width can be set
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps

module Modu_Shift_Reg8(
	//input
	clk,delay,data_in,
	data_out
	);
   parameter data_width = 4'b0000;
	
	//input
	input clk;
	input [2:0] delay;
	input [data_width-1:0] data_in;
	output [data_width-1:0] data_out;
	wire [data_width-1:0] data_out;
	
	reg [data_width-1:0] store [7:0];
	
	assign data_out = store[delay];
	
	always @(posedge clk)
	begin
		store[0] <= data_in;
		store[1] <= store[0];
		store[2] <= store[1];
		store[3] <= store[2];
		store[4] <= store[3];
		store[5] <= store[4];
		store[6] <= store[5];
		store[7] <= store[6];
	end
	
endmodule
