/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_Deinterleave.v
* Abstract: This is the verilog file for deinterleave the input data
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps

module Modu_Deinterleave(
   //input
   clk,resortSE_id,data_in,
   //output
   data_out
  );
	parameter width = 5'd0;
	input clk;
	input	[2:0] resortSE_id;
	input	[width-1:0] data_in;
	output [width*8-1:0] data_out;
	wire b_0;
	
	assign b_0 = 1'b0;
	
	reg [width*8-1:0] data_out;
		
 	always @(posedge clk)
  	begin
			case(resortSE_id)//注意，Verilog中直接用<=0只能对低32位赋0值，其余位不变
 	         3'b000: 
				begin
						data_out[width*8-1:width*7] <= 16'b0;
						data_out[width*7-1:width*6] <= 16'b0;
						data_out[width*6-1:width*5] <= 16'b0;
						data_out[width*5-1:width*4] <= 16'b0;
						data_out[width*4-1:width*3] <= 16'b0;
						data_out[width*3-1:width*2] <= 16'b0;
						data_out[width*2-1:width*1] <= 16'b0;
						data_out[width-1:0] <= data_in;
				end
 	         3'b001: 
				begin
						data_out[width*8-1:width*7] <= 16'b0;
						data_out[width*7-1:width*6] <= 16'b0;
						data_out[width*6-1:width*5] <= 16'b0;
						data_out[width*5-1:width*4] <= 16'b0;
						data_out[width*4-1:width*3] <= 16'b0;
						data_out[width*3-1:width*2] <= 16'b0;
						data_out[width*2-1:width*1] <= data_in;
						data_out[width-1:0] <= 16'b0;
				end
				3'b010: 
				begin
						data_out[width*8-1:width*7] <= 16'b0;
						data_out[width*7-1:width*6] <= 16'b0;
						data_out[width*6-1:width*5] <= 16'b0;
						data_out[width*5-1:width*4] <= 16'b0;
						data_out[width*4-1:width*3] <= 16'b0;
						data_out[width*3-1:width*2] <= data_in;
						data_out[width*2-1:width*1] <= 16'b0;
						data_out[width-1:0] <= 16'b0;
				end
 	         3'b011:
				begin	
						data_out[width*8-1:width*7] <= 16'b0;
						data_out[width*7-1:width*6] <= 16'b0;
						data_out[width*6-1:width*5] <= 16'b0;
						data_out[width*5-1:width*4] <= 16'b0;
						data_out[width*4-1:width*3] <= data_in;
						data_out[width*3-1:width*2] <= 16'b0;
						data_out[width*2-1:width*1] <= 16'b0;
						data_out[width-1:0] <= 16'b0;
				end
 	         3'b100: 
				begin
						data_out[width*8-1:width*7] <= 16'b0;
						data_out[width*7-1:width*6] <= 16'b0;
						data_out[width*6-1:width*5] <= 16'b0;
						data_out[width*5-1:width*4] <= data_in;
						data_out[width*4-1:width*3] <= 16'b0;
						data_out[width*3-1:width*2] <= 16'b0;
						data_out[width*2-1:width*1] <= 16'b0;
						data_out[width-1:0] <= 16'b0;
				end
 	         3'b101: 
				begin
						data_out[width*8-1:width*7] <= 16'b0;
						data_out[width*7-1:width*6] <= 16'b0;
						data_out[width*6-1:width*5] <= data_in;
						data_out[width*5-1:width*4] <= 16'b0;
						data_out[width*4-1:width*3] <= 16'b0;
						data_out[width*3-1:width*2] <= 16'b0;
						data_out[width*2-1:width*1] <= 16'b0;
						data_out[width-1:0] <= 16'b0;
				end
 	         3'b110: 
				begin
						data_out[width*8-1:width*7] <= 16'b0;
						data_out[width*7-1:width*6] <= data_in;
						data_out[width*6-1:width*5] <= 16'b0;
						data_out[width*5-1:width*4] <= 16'b0;
						data_out[width*4-1:width*3] <= 16'b0;
						data_out[width*3-1:width*2] <= 16'b0;
						data_out[width*2-1:width*1] <= 16'b0;
						data_out[width-1:0] <= 16'b0;
				end
 	         3'b111: 
				begin
						data_out[width*8-1:width*7] <= data_in;
						data_out[width*7-1:width*6] <= 16'b0;
						data_out[width*6-1:width*5] <= 16'b0;
						data_out[width*5-1:width*4] <= 16'b0;
						data_out[width*4-1:width*3] <= 16'b0;
						data_out[width*3-1:width*2] <= 16'b0;
						data_out[width*2-1:width*1] <= 16'b0;
						data_out[width-1:0] <= 16'b0;
				end
			endcase
	end

endmodule
