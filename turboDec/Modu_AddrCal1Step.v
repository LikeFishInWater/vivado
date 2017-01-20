/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_AddrCal1Step.v
* Abstract: This is the verilog file that calculate the address in the address control
* unit. This mode only calculate for one step foward of backward once according to CmpDirection
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_AddrCal1Step(
	//input
	clk,reset,Init_flag,CmpDirection,blockSize,decNum,Rf2,Qf2,
	Req_Rf_Init,Req_Qf_Init,Req_Rg_Init,Req_Qg_Init,
	//output
	Next_Req_Rf,Next_Req_Qf,Next_Req_Rg,Next_Req_Qg	
    );
	
	//input
	input clk;
	input reset;
	input Init_flag;
	input CmpDirection;
	input [`Data_Addr_width-1:0] blockSize;
	input [3:0] decNum;
	input [`Data_Addr_width-1:0] Rf2;
	input [2:0] Qf2;
	input [`Data_Addr_width-1:0] Req_Rf_Init;
	input [2:0] Req_Qf_Init;
	input [`Data_Addr_width-1:0] Req_Rg_Init;
	input [2:0] Req_Qg_Init;
	
	//output
	output [`Data_Addr_width-1:0] Next_Req_Rf;
	output [2:0] Next_Req_Qf;
	output [`Data_Addr_width-1:0] Next_Req_Rg;
	output [2:0] Next_Req_Qg;
	
	reg [`Data_Addr_width-1:0] Next_Req_Rf;
	reg [2:0] Next_Req_Qf;
	reg [`Data_Addr_width-1:0] Next_Req_Rg;
	reg [2:0] Next_Req_Qg;
	
	wire [`Data_Addr_width-1:0] cRf;
	wire [2:0] cQf;
	wire [`Data_Addr_width-1:0] cRg;
	wire [2:0] cQg;
	wire [`Data_Addr_width+1:0] cRf_add_cRg;
	wire [`Data_Addr_width+1:0] cRf_add_cRg_sub_bs;
	wire [`Data_Addr_width+1:0] cRg_add_Rf2;
	wire [`Data_Addr_width+1:0] cRg_add_Rf2_sub_bs;
	wire [4:0] cQf_add_cQg_add_KRf;
	wire [4:0] cQf_add_cQg_add_KRf_sub_dec;
	wire [4:0] cQg_add_Qf2_add_KRg;
	wire [4:0] cQg_add_Qf2_add_KRg_sub_dec;
	wire [`Data_Addr_width+1:0] cRf_sub_cRg;
	wire [`Data_Addr_width+1:0] cRf_sub_cRg_add_bs;
	wire [`Data_Addr_width+1:0] cRg_sub_Rf2;
	wire [`Data_Addr_width+1:0] cRg_sub_Rf2_add_bs;
	wire [4:0] cQf_sub_cQg_sub_KRf;
	wire [4:0] cQf_sub_cQg_sub_KRf_add_dec;
	wire [4:0] cQg_sub_Qf2_sub_KRg;
	wire [4:0] cQg_sub_Qf2_sub_KRg_add_dec;
	wire KRf_0,KRf_1;
	wire KQf_0,KQf_1;
	wire KRg_0,KRg_1;
	wire KQg_0,KQg_1;
	wire [`Data_Addr_width-1:0] nextRf_0,nextRf_1;
	wire [2:0] nextQf_0,nextQf_1;
	wire [`Data_Addr_width-1:0] nextRg_0,nextRg_1;
	wire [2:0] nextQg_0,nextQg_1;
	
	//前向递推地址参数
	assign cRf_add_cRg = {2'b0,Next_Req_Rf} + {2'b0,Next_Req_Rg};
	assign cRf_add_cRg_sub_bs = cRf_add_cRg - {2'b0,blockSize};
	assign KRf_0 = ~cRf_add_cRg_sub_bs[`Data_Addr_width+1];
	assign cRg_add_Rf2 = {2'b0,Next_Req_Rg} + {2'b0,Rf2};
	assign cRg_add_Rf2_sub_bs = cRg_add_Rf2 - {2'b0,blockSize};
	assign KRg_0 = ~cRg_add_Rf2_sub_bs[`Data_Addr_width+1];
	assign cQf_add_cQg_add_KRf = {2'b0,Next_Req_Qf} + {2'b0,Next_Req_Qg} + {3'b0,KRf_0};
	assign cQf_add_cQg_add_KRf_sub_dec = cQf_add_cQg_add_KRf - {1'b0,decNum};
	assign KQf_0 = ~cQf_add_cQg_add_KRf_sub_dec[4];
	assign cQg_add_Qf2_add_KRg = {2'b0,Next_Req_Qg} + {2'b0,Qf2} + {3'b0,KRg_0};
	assign cQg_add_Qf2_add_KRg_sub_dec = cQg_add_Qf2_add_KRg - {1'b0,decNum};
	assign KQg_0 = ~cQg_add_Qf2_add_KRg_sub_dec[4];
	
	//后向递推地址参数
	assign cRf_sub_cRg = {2'b0,Next_Req_Rf} - {2'b0,Next_Req_Rg};
	assign cRf_sub_cRg_add_bs = cRf_sub_cRg + {2'b0,blockSize};
	assign KRf_1 = cRf_sub_cRg[`Data_Addr_width+1];
	assign cRg_sub_Rf2 = {2'b0,Next_Req_Rg} - {2'b0,Rf2};
	assign cRg_sub_Rf2_add_bs = cRg_sub_Rf2 + {2'b0,blockSize};
	assign KRg_1 = cRg_sub_Rf2[`Data_Addr_width+1];
	assign cQf_sub_cQg_sub_KRf = {2'b0,Next_Req_Qf} - {2'b0,Next_Req_Qg} - {3'b0,KRf_1};
	assign cQf_sub_cQg_sub_KRf_add_dec = cQf_sub_cQg_sub_KRf + {1'b0,decNum};
	assign KQf_1 = cQf_sub_cQg_sub_KRf[4];
	assign cQg_sub_Qf2_sub_KRg = {2'b0,Next_Req_Qg} - {2'b0,Qf2} - {3'b0,KRg_1};
	assign cQg_sub_Qf2_sub_KRg_add_dec = cQg_sub_Qf2_sub_KRg + {1'b0,decNum};
	assign KQg_1 = cQg_sub_Qf2_sub_KRg[4];
	
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Next_Req_Rf <= 0;
			Next_Req_Qf <= 0;
			Next_Req_Rg <= 0;
			Next_Req_Qg <= 0;
		end
		else if(Init_flag == 1'b1)
		begin
			Next_Req_Rf <= Req_Rf_Init;
			Next_Req_Qf <= Req_Qf_Init;
			Next_Req_Rg <= Req_Rg_Init;
			Next_Req_Qg <= Req_Qg_Init;
		end
		else
		begin
			if(CmpDirection == 1'b1)
			begin
				if(KRf_0 == 1'b0)
				begin
					Next_Req_Rf <= cRf_add_cRg[`Data_Addr_width-1:0];
				end
				else
				begin
					Next_Req_Rf <= cRf_add_cRg_sub_bs[`Data_Addr_width-1:0];
				end
				
				if(KRg_0 == 1'b0)
				begin
					Next_Req_Rg <= cRg_add_Rf2[`Data_Addr_width-1:0];
				end
				else
				begin
					Next_Req_Rg <= cRg_add_Rf2_sub_bs[`Data_Addr_width-1:0];
				end
				
				if(KQf_0 == 1'b0)
				begin
					Next_Req_Qf <= cQf_add_cQg_add_KRf[2:0];
				end
				else
				begin
					Next_Req_Qf <= cQf_add_cQg_add_KRf_sub_dec[2:0];
				end
				
				if(KQg_0 == 1'b0)
				begin
					Next_Req_Qg <= cQg_add_Qf2_add_KRg[2:0];
				end
				else
				begin
					Next_Req_Qg <= cQg_add_Qf2_add_KRg_sub_dec[2:0];
				end
			end
			
			else
			begin
				if(KRf_1 == 1'b0)
				begin
					Next_Req_Rf <= cRf_sub_cRg[`Data_Addr_width-1:0];
				end
				else
				begin
					Next_Req_Rf <= cRf_sub_cRg_add_bs[`Data_Addr_width-1:0];
				end
				
				if(KRg_1 == 1'b0)
				begin
					Next_Req_Rg <= cRg_sub_Rf2[`Data_Addr_width-1:0];
				end
				else
				begin
					Next_Req_Rg <= cRg_sub_Rf2_add_bs[`Data_Addr_width-1:0];
				end
				
				if(KQf_1 == 1'b0)
				begin
					Next_Req_Qf <= cQf_sub_cQg_sub_KRf[2:0];
				end
				else
				begin
					Next_Req_Qf <= cQf_sub_cQg_sub_KRf_add_dec[2:0];
				end
				
				if(KQg_1 == 1'b0)
				begin
					Next_Req_Qg <= cQg_sub_Qf2_sub_KRg[2:0];
				end
				else
				begin
					Next_Req_Qg <= cQg_sub_Qf2_sub_KRg_add_dec[2:0];
				end
			end
		end
	end


endmodule
