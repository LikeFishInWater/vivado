/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_Distributed_Single_RAM.v
* Abstract: This is the verilog file that define the distributes block single-port RAM. The address_width
* and data_width can be set as wanted.BUF0~2 uses this module
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
//`define RAM_STYLE="{AUTO | DISTRIBUTED | PIPE_DISTRIBUTED}"

/*
//调用格式为：
Modu_Distributed_Single_RAM #(RAM_WIDTH,RAM_ADDR_BITS) Single_RAM_0(input,output)
*/

module Modu_Distributed_Single_RAM(
	//input
	clk,write_enable,address,input_data,
	//output
	output_data
	);
	
	parameter RAM_WIDTH = 8'b00000000;
	parameter RAM_ADDR_BITS = 7'b0000000;
	//input
	input clk;
	input [RAM_ADDR_BITS-1:0] address;
	input write_enable;
	input [RAM_WIDTH-1:0] input_data;
	//output
	output [RAM_WIDTH-1:0] output_data;
	
	reg [RAM_WIDTH-1:0] output_data;

   reg [RAM_WIDTH-1:0] Single_RAM [(2**RAM_ADDR_BITS)-1:0];

   always @(posedge clk)
	begin
		if (write_enable)
          Single_RAM[address] <= input_data;
	end
	
	always @(posedge clk)
	begin
		output_data <= Single_RAM[address];
	end


endmodule
