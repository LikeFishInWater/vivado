/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_3BUF_w.v
* Abstract: This is the verilog file that provide the write_enable signals for BUF0~2
* and the choosen flags of BPU and FPU
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_3BUF_w(
	//input
	clk,reset,Init_flag,CmpCounter,B,
	//output
	BUF0_w,BUF1_w,BUF2_w,
	id_FPU,id_BPU
	);
	//input
	input clk;
	input reset;
	input Init_flag;
	input [`CmpCounter_width-1:0] CmpCounter;
	input [`window_width:0] B;
	//output
	output BUF0_w;
	output BUF1_w;
	output BUF2_w;
	output [1:0] id_FPU;
	output [1:0] id_BPU;
	
	reg BUF0_w;
	reg BUF1_w;
	reg BUF2_w;
	reg [1:0] Flag;
	reg [1:0] id_FPU;
	reg [1:0] id_BPU;
	wire [`CmpCounter_width-1:0] CmpCounter_sub_3;
	wire [`CmpCounter_width-1:0] CmpCounter_sub_2;
	wire [`CmpCounter_width-1:0] CmpCounter_sub_1;
	assign CmpCounter_sub_3 = CmpCounter - 2'b11;
	assign CmpCounter_sub_2 = CmpCounter - 2'b10;
	assign CmpCounter_sub_1 = CmpCounter - 1'b1;
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			BUF0_w <= 1'b0;
			BUF1_w <= 1'b0;
			BUF2_w <= 1'b0;
		end
		else if(CmpCounter_sub_2[`window_width-1:0] == 6'b0)
		begin
			if(Flag == 2'b00)
			begin
				BUF0_w <= 1'b1;
				BUF1_w <= 1'b0;
				BUF2_w <= 1'b0;
			end
			if(Flag == 2'b01)
			begin
				BUF0_w <= 1'b0;
				BUF1_w <= 1'b1;
				BUF2_w <= 1'b0;
			end
			if(Flag == 2'b10)
			begin
				BUF0_w <= 1'b0;
				BUF1_w <= 1'b0;
				BUF2_w <= 1'b1;
			end
		end
		else
		begin
			BUF0_w <= BUF0_w;
			BUF1_w <= BUF1_w;
			BUF2_w <= BUF2_w;
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Flag <= 2'b00;
		end
		else if(Init_flag == 1'b1)
		begin
			Flag <= 2'b00;
		end
		else if(CmpCounter_sub_1[`window_width-1:0] == 6'b0 && CmpCounter > 1)
		begin
			if(Flag == 2'b10)
				Flag <= 2'b00;
			else
				Flag <= Flag + 1'b1;
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			id_FPU <= 2'b00;
		end
		else if(Init_flag == 1'b1)
		begin
			id_FPU <= 2'b01;
		end
		else if(CmpCounter_sub_3[`window_width-1:0] == 6'b0)
		begin
			if(id_FPU == 2'b10)
				id_FPU <= 2'b00;
			else
				id_FPU <= id_FPU + 1'b1;
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			id_BPU <= 2'b00;
		end
		else if(Init_flag == 1'b1)
		begin
			id_BPU <= 2'b00;
		end
		else if(CmpCounter_sub_3[`window_width-1:0] == 6'b0)
		begin
			if(id_BPU == 2'b10)
				id_BPU <= 2'b00;
			else
				id_BPU <= id_BPU + 1'b1;
		end
	end


endmodule
