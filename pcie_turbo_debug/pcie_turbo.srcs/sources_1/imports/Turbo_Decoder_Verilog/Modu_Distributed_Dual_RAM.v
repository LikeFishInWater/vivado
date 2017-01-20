/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_Distributed_Dual_RAM.v
* Abstract: This is the verilog file that define the distributes block dual-port RAM. The address_width
* and data_width can be set as wanted.BUFA uses this module
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
//`define RAM_STYLE = "{AUTO | DISTRIBUTED | PIPE_DISTRIBUTED}"

/*
//调用格式为：
Modu_Distributed_Dual_RAM #(RAM_WIDTH,RAM_ADDR_BITS) Dual_RAM_0(input,output)
*/
module Modu_Distributed_Dual_RAM(
	//input
	clk,write_address,write_enable,input_data,
	read_address,
	//output
	output_data
	);
	parameter RAM_WIDTH = 8'b00000000;
	parameter RAM_ADDR_BITS = 7'b0000000;
	//input
	input clk;
	input [RAM_ADDR_BITS-1:0] write_address;
	input write_enable;
	input [RAM_WIDTH-1:0] input_data;
	input [RAM_ADDR_BITS-1:0] read_address;
	//output
	output [RAM_WIDTH-1:0] output_data;
	
	reg [RAM_WIDTH-1:0] output_data;

   reg [RAM_WIDTH-1:0] Dual_RAM [(2**RAM_ADDR_BITS)-1:0];

   always @(posedge clk)
	begin
		if (write_enable)
          Dual_RAM[write_address] <= input_data;
	end
	
	always @(posedge clk)
	begin
		output_data <= Dual_RAM[read_address];
	end
      


endmodule
