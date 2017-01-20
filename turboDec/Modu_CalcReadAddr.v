/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_CalcReadAddr.v
* Abstract: This is the verilog file that calculate the read address of system and parity
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_CalcReadAddr(
	//input
	clk,reset,Init_flag,Req_A_Init,Req_Rf_Init,Req_Qf_Init,Req_Rg_Init,Req_Qg_Init,
	decNum,blockSize,decMode,Rf2,Qf2,
	//output
	Req_A,Req_Rf,Req_Qf,Req_Rg,Req_Qg,
	AddrP,resortP,AddrSL,resortSL
	);
	 
	input clk;
	input reset;
	input Init_flag;
	input [`Data_Addr_width-1:0]Req_A_Init;
	input [`Data_Addr_width-1:0]Req_Rf_Init;
	input [23:0]Req_Qf_Init;
	input [`Data_Addr_width-1:0]Req_Rg_Init;
	input [23:0]Req_Qg_Init;
	input [3:0] decNum;
	input [`Data_Addr_width-1:0] blockSize;
	input decMode;
	input [`Data_Addr_width-1:0] Rf2;
	input [2:0] Qf2;
	
	output [`Data_Addr_width-1:0] Req_A;
	output [`Data_Addr_width-1:0] Req_Rf;
	output [23:0] Req_Qf;
	output [`Data_Addr_width-1:0] Req_Rg;
	output [23:0] Req_Qg;
	output [`Data_Addr_width-1:0] AddrP;
	output [23:0] resortP;
	output [`Data_Addr_width-1:0] AddrSL;
	output [23:0] resortSL;
	
	 
	reg [`Data_Addr_width-1:0] Req_A;
	wire [`Data_Addr_width-1:0] Req_Rf;
	wire [23:0] Req_Qf;
	wire [`Data_Addr_width-1:0] Req_Rg;
	wire [23:0] Req_Qg;
	reg [`Data_Addr_width-1:0] AddrP;
	reg [23:0] resortP;
	reg [`Data_Addr_width-1:0] AddrSL;
	reg [23:0] resortSL;
	
	wire [`Data_Addr_width-1:0] Req_Rf_0,Req_Rf_1,Req_Rf_2,Req_Rf_3,Req_Rf_4,Req_Rf_5,Req_Rf_6,Req_Rf_7;
	wire [2:0] Req_Qf_0,Req_Qf_1,Req_Qf_2,Req_Qf_3,Req_Qf_4,Req_Qf_5,Req_Qf_6,Req_Qf_7;
	wire [`Data_Addr_width-1:0] Req_Rg_0,Req_Rg_1,Req_Rg_2,Req_Rg_3,Req_Rg_4,Req_Rg_5,Req_Rg_6,Req_Rg_7;
	wire [2:0] Req_Qg_0,Req_Qg_1,Req_Qg_2,Req_Qg_3,Req_Qg_4,Req_Qg_5,Req_Qg_6,Req_Qg_7;
		
	assign Req_Rf = Req_Rf_0;
	assign Req_Qf = {Req_Qf_7,Req_Qf_6,Req_Qf_5,Req_Qf_4,Req_Qf_3,Req_Qf_2,Req_Qf_1,Req_Qf_0};
	assign Req_Rg = Req_Rg_0;
	assign Req_Qg = {Req_Qg_7,Req_Qg_6,Req_Qg_5,Req_Qg_4,Req_Qg_3,Req_Qg_2,Req_Qg_1,Req_Qg_0};
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
				AddrP <= 0;
				resortP <= 0;
		end
		else
		begin
				AddrP <= Req_A;
				resortP <= {3'b111,3'b110,3'b101,3'b100,3'b011,3'b010,3'b001,3'b000};
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			AddrSL <= 0;
			resortSL <= 0;
		end
		else
		begin
			if(decMode == 0)
			begin
				AddrSL <= Req_A;
				resortSL <= {3'b111,3'b110,3'b101,3'b100,3'b011,3'b010,3'b001,3'b000};
			end
			else
			begin
				AddrSL <= Req_Rf_0;
				resortSL <= {Req_Qf_7,Req_Qf_6,Req_Qf_5,Req_Qf_4,Req_Qf_3,Req_Qf_2,Req_Qf_1,Req_Qf_0};
			end
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Req_A <= 0;
		end
		else
		begin
			if(Init_flag == 1'b1)
			begin
				Req_A <= Req_A_Init;
			end
			else
			begin
				if(Req_A >= blockSize-1)
				begin
					Req_A <= 0;
				end
				else
				begin
					Req_A <= Req_A+1'b1;
				end
			end
		end
	end
	
	//blockIndex == 0
	Modu_AddrCal1Step AddrCal1Step_forward0(
		//input
		.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpDirection(1'b1),
		.blockSize(blockSize),.decNum(decNum),.Rf2(Rf2),.Qf2(Qf2),
		.Req_Rf_Init(Req_Rf_Init),.Req_Qf_Init(Req_Qf_Init[2:0]),
		.Req_Rg_Init(Req_Rg_Init),.Req_Qg_Init(Req_Qg_Init[2:0]),
		//output
		.Next_Req_Rf(Req_Rf_0),.Next_Req_Qf(Req_Qf_0),.Next_Req_Rg(Req_Rg_0),.Next_Req_Qg(Req_Qg_0)
		);
		
	//blockIndex == 1
	Modu_AddrCal1Step AddrCal1Step_forward1(
		//input
		.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpDirection(1'b1),
		.blockSize(blockSize),.decNum(decNum),.Rf2(Rf2),.Qf2(Qf2),
		.Req_Rf_Init(Req_Rf_Init),.Req_Qf_Init(Req_Qf_Init[5:3]),
		.Req_Rg_Init(Req_Rg_Init),.Req_Qg_Init(Req_Qg_Init[5:3]),
		//output
		.Next_Req_Rf(Req_Rf_1),.Next_Req_Qf(Req_Qf_1),.Next_Req_Rg(Req_Rg_1),.Next_Req_Qg(Req_Qg_1)
		);
		
	//blockIndex == 2
	Modu_AddrCal1Step AddrCal1Step_forward2(
		//input
		.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpDirection(1'b1),
		.blockSize(blockSize),.decNum(decNum),.Rf2(Rf2),.Qf2(Qf2),
		.Req_Rf_Init(Req_Rf_Init),.Req_Qf_Init(Req_Qf_Init[8:6]),
		.Req_Rg_Init(Req_Rg_Init),.Req_Qg_Init(Req_Qg_Init[8:6]),
		//output
		.Next_Req_Rf(Req_Rf_2),.Next_Req_Qf(Req_Qf_2),.Next_Req_Rg(Req_Rg_2),.Next_Req_Qg(Req_Qg_2)
		);
	
	//blockIndex == 3
	Modu_AddrCal1Step AddrCal1Step_forward3(
		//input
		.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpDirection(1'b1),
		.blockSize(blockSize),.decNum(decNum),.Rf2(Rf2),.Qf2(Qf2),
		.Req_Rf_Init(Req_Rf_Init),.Req_Qf_Init(Req_Qf_Init[11:9]),
		.Req_Rg_Init(Req_Rg_Init),.Req_Qg_Init(Req_Qg_Init[11:9]),
		//output
		.Next_Req_Rf(Req_Rf_3),.Next_Req_Qf(Req_Qf_3),.Next_Req_Rg(Req_Rg_3),.Next_Req_Qg(Req_Qg_3)
		);
	
	//blockIndex == 4
	Modu_AddrCal1Step AddrCal1Step_forward4(
		//input
		.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpDirection(1'b1),
		.blockSize(blockSize),.decNum(decNum),.Rf2(Rf2),.Qf2(Qf2),
		.Req_Rf_Init(Req_Rf_Init),.Req_Qf_Init(Req_Qf_Init[14:12]),
		.Req_Rg_Init(Req_Rg_Init),.Req_Qg_Init(Req_Qg_Init[14:12]),
		//output
		.Next_Req_Rf(Req_Rf_4),.Next_Req_Qf(Req_Qf_4),.Next_Req_Rg(Req_Rg_4),.Next_Req_Qg(Req_Qg_4)
		);
		
	//blockIndex == 5
	Modu_AddrCal1Step AddrCal1Step_forward5(
		//input
		.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpDirection(1'b1),
		.blockSize(blockSize),.decNum(decNum),.Rf2(Rf2),.Qf2(Qf2),
		.Req_Rf_Init(Req_Rf_Init),.Req_Qf_Init(Req_Qf_Init[17:15]),
		.Req_Rg_Init(Req_Rg_Init),.Req_Qg_Init(Req_Qg_Init[17:15]),
		//output
		.Next_Req_Rf(Req_Rf_5),.Next_Req_Qf(Req_Qf_5),.Next_Req_Rg(Req_Rg_5),.Next_Req_Qg(Req_Qg_5)
		);
	
	//blockIndex == 6
	Modu_AddrCal1Step AddrCal1Step_forward6(
		//input
		.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpDirection(1'b1),
		.blockSize(blockSize),.decNum(decNum),.Rf2(Rf2),.Qf2(Qf2),
		.Req_Rf_Init(Req_Rf_Init),.Req_Qf_Init(Req_Qf_Init[20:18]),
		.Req_Rg_Init(Req_Rg_Init),.Req_Qg_Init(Req_Qg_Init[20:18]),
		//output
		.Next_Req_Rf(Req_Rf_6),.Next_Req_Qf(Req_Qf_6),.Next_Req_Rg(Req_Rg_6),.Next_Req_Qg(Req_Qg_6)
		);
	
	//blockIndex == 7
	Modu_AddrCal1Step AddrCal1Step_forward7(
		//input
		.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpDirection(1'b1),
		.blockSize(blockSize),.decNum(decNum),.Rf2(Rf2),.Qf2(Qf2),
		.Req_Rf_Init(Req_Rf_Init),.Req_Qf_Init(Req_Qf_Init[23:21]),
		.Req_Rg_Init(Req_Rg_Init),.Req_Qg_Init(Req_Qg_Init[23:21]),
		//output
		.Next_Req_Rf(Req_Rf_7),.Next_Req_Qf(Req_Qf_7),.Next_Req_Rg(Req_Rg_7),.Next_Req_Qg(Req_Qg_7)
		);
	
					


endmodule
