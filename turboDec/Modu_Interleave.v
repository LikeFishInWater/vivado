/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_Interleave.v
* Abstract: This is the verilog file that do the interleaving of the input data
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_Interleave
  (
   //input
   clk,resortSE_id,data_in,
   //output
   data_out
  );
	parameter width = 5'd0;
	input clk;
	input	[2:0] resortSE_id;
	input	[width*8-1:0] data_in;
	output [width-1:0] data_out;
	
	reg [width-1:0] data_out;
		
 	always @(posedge clk)
  	begin
			case(resortSE_id)
 	         3'b000: 
 	         		data_out <= data_in[width-1:0];
 	         3'b001: 
 	         		data_out <= data_in[width*2-1:width];
 	         3'b010: 
 	         		data_out <= data_in[width*3-1:width*2];
 	         3'b011: 
 	         		data_out <= data_in[width*4-1:width*3];
 	         3'b100: 
 	         		data_out <= data_in[width*5-1:width*4];
 	         3'b101: 
 	         		data_out <= data_in[width*6-1:width*5];
 	         3'b110: 
 	         		data_out <= data_in[width*7-1:width*6];
 	         3'b111: 
 	         		data_out <= data_in[width*8-1:width*7];
  	     endcase
    end
	 
endmodule
