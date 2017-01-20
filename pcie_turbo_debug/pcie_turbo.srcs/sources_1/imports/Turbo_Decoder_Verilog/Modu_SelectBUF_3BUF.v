/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_SelectBUF_3BUF.v
* Abstract: This is the verilog file that select the right data from the output of
* the 3 data BUF
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_SelectBUF_3BUF(
	//input
	clk,id_FPU,id_BPU,Iter,decMode,data_BUF0,data_BUF1,data_BUF2,
	//output
	data_out_FPU,data_out_BPU
	);
	
	input clk;
	input [1:0] id_FPU;
	input [1:0] id_BPU;
	input [3:0] Iter;
	input decMode;
	input [`sys_par_width*2+`Le_sys_par_width-1:0] data_BUF0;
	input [`sys_par_width*2+`Le_sys_par_width-1:0] data_BUF1;
	input [`sys_par_width*2+`Le_sys_par_width-1:0] data_BUF2;
	output [`sys_par_width*2+`Le_sys_par_width-1:0] data_out_FPU;
	output [`sys_par_width*2+`Le_sys_par_width-1:0] data_out_BPU;
	
	wire [`sys_par_width*2+`Le_sys_par_width-1:0] data_out_BUF0;
	wire [`sys_par_width*2+`Le_sys_par_width-1:0] data_out_BUF1;
	wire [`sys_par_width*2+`Le_sys_par_width-1:0] data_out_BUF2;
	reg [`sys_par_width*2+`Le_sys_par_width-1:0] data_out_FPU;
	reg [`sys_par_width*2+`Le_sys_par_width-1:0] data_out_BPU;
	
	assign data_out_BUF0 = (Iter==0 && decMode==1'b0) ? 
	{{`Le_sys_par_width{1'b0}},data_BUF0[`sys_par_width*2-1:0]} : data_BUF0;
	
	assign data_out_BUF1 = (Iter==0 && decMode==1'b0) ? 
	{{`Le_sys_par_width{1'b0}},data_BUF1[`sys_par_width*2-1:0]} : data_BUF1;
	
	assign data_out_BUF2 = (Iter==0 && decMode==1'b0) ? 
	{{`Le_sys_par_width{1'b0}},data_BUF2[`sys_par_width*2-1:0]} : data_BUF2;
	
	always @(posedge clk)
  	begin
		case(id_FPU)
			2'b00:
				data_out_FPU <= data_out_BUF0;
			2'b01:
				data_out_FPU <= data_out_BUF1;
			2'b10:
				data_out_FPU <= data_out_BUF2;
		endcase
	end
	
	always @(posedge clk)
  	begin
		case(id_BPU)
			2'b00:
				data_out_BPU <= data_out_BUF0;
			2'b01:
				data_out_BPU <= data_out_BUF1;
			2'b10:
				data_out_BPU <= data_out_BUF2;
		endcase
	end
	
endmodule
