/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_SaveLeInitWriteAddr_3BUF.v
* Abstract: This is the verilog file that store the initial address value to store
* the soft and hard output of the decoder
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
* Modified on 2012-04-17 for the various code lenght in LTE
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_SaveLeInitWriteAddr_3BUF(
	//input
	clk,reset,CmpCounter,r,q_up,blockSize,
	Req_A,Req_Rg,Req_Qg,Req_Rf,Req_Qf,
	//output
	Le_A_init_2,Le_Rf_init_2,Le_Qf_init_2,Le_Rg_init_2,Le_Qg_init_2
    );
	
	//input
	input clk;
	input reset;
	input [`CmpCounter_width-1:0] CmpCounter;
	input [`window_width-1:0] r;
	input [3:0] q_up;
	input [`Data_Addr_width-1:0] blockSize;
	input [`Data_Addr_width-1:0] Req_A;
	input [`Data_Addr_width-1:0] Req_Rf;
	input [23:0] Req_Qf;
	input [`Data_Addr_width-1:0] Req_Rg;
	input [23:0] Req_Qg;
	
	//output
	output [`Data_Addr_width-1:0] Le_A_init_2;
	output [`Data_Addr_width-1:0] Le_Rf_init_2;
	output [23:0] Le_Qf_init_2;
	output [`Data_Addr_width-1:0] Le_Rg_init_2;
	output [23:0] Le_Qg_init_2;
	
	reg [`Data_Addr_width-1:0] Le_A_init_1;
	reg [`Data_Addr_width-1:0] Le_A_init_2;
	reg [`Data_Addr_width-1:0] Le_Rf_init_1;
	reg [`Data_Addr_width-1:0] Le_Rf_init_2;
	reg [23:0] Le_Qf_init_1;
	reg [23:0] Le_Qf_init_2;
	reg [`Data_Addr_width-1:0] Le_Rg_init_1;
	reg [`Data_Addr_width-1:0] Le_Rg_init_2;
	reg [23:0] Le_Qg_init_1;
	reg [23:0] Le_Qg_init_2;
	
	//由于Verilog中的非阻塞赋值相当于延迟一个clk，则此处相比较与C程序，均修改了增减的量(减量和增量均减一)
	//正是由于上述原因，在C中在q_up*B-2和q_up*B-1时即得到q_up*B-2和q_up*B-1的相应地址值，在Verilog中需要到
	//q_up*B-1和q_up*B才能得到上述的所需值q_up*B-2和q_up*B-1，编程时需要注意
	wire [`CmpCounter_width-1:0] CmpCounter_add_1;
	wire [`CmpCounter_width-1:0] CmpCounter_add_2;
	wire [`Data_Addr_width-1:0] blockSize_sub_1;
	wire [`Data_Addr_width-1:0] blockSize_sub_2;
	wire [`window_width+3:0] q_up_mul_B;
	
	assign CmpCounter_add_1 = CmpCounter + 1'b1;
	assign CmpCounter_add_2 = CmpCounter + 2'b10;
	assign blockSize_sub_1 = blockSize - 1'b1;
	assign blockSize_sub_2 = blockSize - 2'b10;
	assign q_up_mul_B = q_up << `window_width;
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Le_Rg_init_1 <= 0;
			Le_Rg_init_2 <= 0;
			Le_Qg_init_1 <= 0;
			Le_Qg_init_2 <= 0;
		end
		//else if(CmpCounter_add_2[`window_width-1:0] == 0 || CmpCounter == blockSize_sub_2)
		//begin
			//if(r == 0 || CmpCounter_add_2 != q_up_mul_B)
		else if((r==0 && CmpCounter_add_2[`window_width-1:0]==0) || (r!=0 && (CmpCounter==blockSize_sub_2 || (CmpCounter_add_2[`window_width-1:0]==0 && CmpCounter_add_2!=q_up_mul_B))))
		begin
			Le_Rg_init_2 <= Le_Rg_init_1;
			Le_Rg_init_1 <= Req_Rg;
			Le_Qg_init_2 <= Le_Qg_init_1;
			Le_Qg_init_1 <= Req_Qg;
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Le_A_init_1 <= 0;
			Le_A_init_2 <= 0;
			Le_Rf_init_1 <= 0;
			Le_Rf_init_2 <= 0;
			Le_Qf_init_1 <= 0;
			Le_Qf_init_2 <= 0;
		end
		//else if(CmpCounter_add_1[`window_width-1:0] == 0 || CmpCounter == blockSize_sub_1)
		//begin
			//if(r == 0 || CmpCounter_add_1 != q_up_mul_B)
		else if((r==0 && CmpCounter_add_1[`window_width-1:0]==0) || (r!=0 && (CmpCounter==blockSize_sub_1 || (CmpCounter_add_1[`window_width-1:0]==0 && CmpCounter_add_1!=q_up_mul_B))))
		begin
			Le_A_init_2 <= Le_A_init_1;
			Le_A_init_1 <= Req_A;
			Le_Rf_init_2 <= Le_Rf_init_1;
			Le_Rf_init_1 <= Req_Rf;
			Le_Qf_init_2 <= Le_Qf_init_1;
			Le_Qf_init_1 <= Req_Qf;
		end
	end


endmodule
