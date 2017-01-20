/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_multiply_opt.v
* Abstract: This is the verilog file that multiply the opt value on the soft-output
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_multiply_opt(
	//input
	clk,data_In,
	//output
	data_Out
	);
	input clk;
	input [`beta_alpha_width+2:0] data_In;//2的补码形式
	output [`beta_alpha_width+2:0] data_Out;
	
	reg flag1,flag2;
	reg [`beta_alpha_width+2:0] data_Out;
	reg [`beta_alpha_width+3:0] add1;
	reg [`beta_alpha_width+3:0] add2;
	reg [`beta_alpha_width+3:0] sub3;
	reg [`beta_alpha_width+3:0] sub3_delay;
	reg [`beta_alpha_width+3:0] sum12;
	wire [`beta_alpha_width+3:0] sum123;
	
	wire [`beta_alpha_width+3:0] extend_data_In;
	wire [`beta_alpha_width+3:0] abs_data_In;
	
	assign extend_data_In = {data_In[`beta_alpha_width+2],data_In};
	assign abs_data_In = extend_data_In[`beta_alpha_width+3] ? ((~extend_data_In[`beta_alpha_width+3:0])+1'b1) : extend_data_In;
	
	always @(posedge clk)//*0.25
	begin
		add1 <= {2'b00,abs_data_In[`beta_alpha_width+3:2]};
	end
	
	always @(posedge clk)//*0.125
	begin
		add2 <= {3'b000,abs_data_In[`beta_alpha_width+3:3]};
	end
	
	always @(posedge clk)
	begin
		sub3 <= {6'b000000,abs_data_In[`beta_alpha_width+3:6]};
	end
	
	always @(posedge clk)
	begin
		sub3_delay <= sub3;
	end
	
	always @(posedge clk)
	begin
		sum12 <= add1 +add2;
	end
	
	assign sum123 = sum12 - sub3_delay;
	
	always @(posedge clk)
	begin
		flag1 <= data_In[`beta_alpha_width+2];
		flag2 <= flag1;
	end
	
	always @(posedge clk)
	begin
		if(flag2 == 1'b1)//负
		begin
			data_Out <= {~sum123[`beta_alpha_width+2:0]}+1'b1;
		end
		else
		begin
			data_Out <= sum123[`beta_alpha_width+2:0];
		end
	end


endmodule
