/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_Block_Dual_RAM.v
* Abstract: This is the verilog file that define the distributes block RAMs. The address_width
* and data_width can be set as wanted.
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
//`define RAM_STYLE="{AUTO | BLOCK |  BLOCK_POWER1 | BLOCK_POWER2}"

module Modu_Block_Dual_RAM(
	//input
	clk,write_enable,write_address,input_data,read_address,
	//output
	output_data	
	);
	parameter RAM_WIDTH = 8'b00000000;
   parameter RAM_ADDR_BITS = 8'b0000000;  // revised by shaxiaoshi 2016.05.05  7'b000 --> 8'b000
	//input
	input clk;
	input write_enable;
	input [RAM_ADDR_BITS-1:0] write_address;
	input [RAM_WIDTH-1:0] input_data;
	input [RAM_ADDR_BITS-1:0] read_address;
	//output
	output [RAM_WIDTH-1:0] output_data;
	
	reg [RAM_WIDTH-1:0] output_data;
	
	reg [RAM_WIDTH-1:0] Dual_RAM [(2**RAM_ADDR_BITS)-1:0];
	
	always @(posedge clk)
	begin
		if(write_enable)
			Dual_RAM[write_address] <= input_data;
	end
	
	always @(posedge clk)
	begin
		output_data <= Dual_RAM[read_address];
	end

endmodule
