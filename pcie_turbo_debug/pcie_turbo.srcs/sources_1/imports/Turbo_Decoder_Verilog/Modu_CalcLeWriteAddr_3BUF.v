/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_CalcLeWriteAddr_3BUF.v
* Abstract: This is the verilog file that calculate the address for writing the 
* Le and D
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
* Modified on 2012-04-17 for various code length in LTE
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_CalcLeWriteAddr_3BUF(
	//input
	clk,reset,CmpCounter,decMode,r,q_up,decNum,blockSize,Rf2,Qf2,
	resortP,Le_A_init_2,Le_Rf_init_2,Le_Qf_init_2,Le_Rg_init_2,Le_Qg_init_2,
	//output
	Le_w_ad,Le_w_sort,
	w_ad_Le_par1// Add at 2012.10.18 2B+10时开始有效
    );
	
	//input
	input clk;
	input reset;
	input [`CmpCounter_width-1:0] CmpCounter;
	input decMode;
	input [`window_width-1:0] r;
	input [3:0] q_up;
	input [3:0] decNum;
	input [`Data_Addr_width-1:0] blockSize;
	input [`Data_Addr_width-1:0] Rf2;
	input [2:0] Qf2;
	input [23:0] resortP;
	input [`Data_Addr_width-1:0] Le_A_init_2;
	input [`Data_Addr_width-1:0] Le_Rf_init_2;
	input [23:0] Le_Qf_init_2;
	input [`Data_Addr_width-1:0] Le_Rg_init_2;
	input [23:0] Le_Qg_init_2;
	
	//output
	output [`Data_Addr_width-1:0] Le_w_ad;
	output [23:0] Le_w_sort;
	output [`Data_Addr_width-1:0] w_ad_Le_par1;// Add at 2012.10.18
	
	reg [`Data_Addr_width-1:0] Le_w_ad;
	reg [`Data_Addr_width-1:0] w_ad_Le_par1;// Add at 2012.10.18
	reg [23:0] Le_w_sort;
	reg [`Data_Addr_width-1:0] Le_A;
	reg [`Data_Addr_width-1:0] Le_A_delay;
	wire [`Data_Addr_width-1:0] Le_Rf;
	wire [23:0] Le_Qf;
	wire [`Data_Addr_width-1:0] Le_Rg;
	wire [23:0] Le_Qg;
	reg Init_flag;
	
	reg [`window_width-1:0] Counter_B;// Add at 2012.10.18
	reg [3:0] q_temp;// Add at 2012.10.18
	reg [`CmpCounter_width-1:0] qup_add1_mulB_add7;// Add at 2012.10.18
	reg [`CmpCounter_width-1:0] CmpCounter_min7;// Add at 2012.10.18
	
	wire [`CmpCounter_width-1:0] CmpCounter_add_r;
	wire [4:0] q_up_add_2;
	wire [10:0] q_up_add_2_mul_B;
	
	wire [`Data_Addr_width-1:0] Le_Rf_0,Le_Rf_1,Le_Rf_2,Le_Rf_3,Le_Rf_4,Le_Rf_5,Le_Rf_6,Le_Rf_7;
	wire [2:0] Le_Qf_0,Le_Qf_1,Le_Qf_2,Le_Qf_3,Le_Qf_4,Le_Qf_5,Le_Qf_6,Le_Qf_7;
	wire [`Data_Addr_width-1:0] Le_Rg_0,Le_Rg_1,Le_Rg_2,Le_Rg_3,Le_Rg_4,Le_Rg_5,Le_Rg_6,Le_Rg_7;
	wire [2:0] Le_Qg_0,Le_Qg_1,Le_Qg_2,Le_Qg_3,Le_Qg_4,Le_Qg_5,Le_Qg_6,Le_Qg_7;
	
	assign CmpCounter_add_r = CmpCounter + r;
	assign q_up_add_2 = {1'b0,q_up} + 2'b10;
	assign q_up_add_2_mul_B = q_up_add_2 << `window_width;
	
	assign Le_Rf = Le_Rf_0;
	assign Le_Qf = {Le_Qf_7,Le_Qf_6,Le_Qf_5,Le_Qf_4,Le_Qf_3,Le_Qf_2,Le_Qf_1,Le_Qf_0};
	assign Le_Rg = Le_Rg_0;
	assign Le_Qg = {Le_Qg_7,Le_Qg_6,Le_Qg_5,Le_Qg_4,Le_Qg_3,Le_Qg_2,Le_Qg_1,Le_Qg_0};
	
	always @(posedge clk)// Add at 2012.10.18
	begin
		qup_add1_mulB_add7 <= ((q_up + 1'b1) << `window_width) + 3'b111;
		CmpCounter_min7 <= CmpCounter - 3'b111;
	end
	
	always @(posedge clk or negedge reset)// Add at 2012.10.18
	begin
		if(reset == 1'b0)
		begin
			Counter_B <= {(`window_width){1'b0}};
		end
		else if(CmpCounter == qup_add1_mulB_add7)
		begin
			Counter_B <= (r == {(`window_width){1'b0}}) ? {(`window_width){1'b1}} : r - 1'b1;
		end
		else if(CmpCounter_min7[`window_width-1:0] == {(`window_width){1'b0}})
		begin
			Counter_B <= {(`window_width){1'b1}};
		end
		else if(Counter_B > 0)
		begin
			Counter_B <= Counter_B - 1'b1;
		end
	end
	
	always @(posedge clk or negedge reset)// Add at 2012.10.18
	begin
		if(reset == 1'b0 || CmpCounter == {{1'b1},{(`window_width){1'b0}}})
		begin
			q_temp <= 4'b0000;
		end
		else if(CmpCounter > {{2'b11},{(`window_width){1'b0}}})
		begin
			if(CmpCounter_min7[`window_width-1:0] == {(`window_width){1'b0}})
			begin
				q_temp <= q_temp + 1'b1;
			end
		end
	end
	
	always @(posedge clk)// Add at 2012.10.18
	begin
		w_ad_Le_par1 <= (q_temp << `window_width) + Counter_B;
	end
			
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Le_A_delay <= 0;
		end
		else
		begin
			Le_A_delay <= Le_A;
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Le_A <= 0;
			Init_flag <= 1'b0;
		end
		else
		begin
			//if(CmpCounter[`window_width-1:0] == 6'b0 || r != 0 && CmpCounter_add_r == q_up_add_2_mul_B)
			if(CmpCounter[`window_width-1:0] == {(`window_width){1'b0}})
			begin
				Le_A <= Le_A_init_2;
				Init_flag <= 1'b1;
			end
			else
			begin
				Init_flag <= 1'b0;
				if(Le_A == 0)
				begin
					Le_A <= blockSize - 1'b1;
				end
				else
				begin
					Le_A <= Le_A - 1'b1;
				end
			end
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Le_w_ad <= 0;
			Le_w_sort <= 0;
		end
		else
		begin
			if(decMode == 0)
			begin
				Le_w_ad <= Le_A_delay;
				Le_w_sort <= resortP;
			end
			else
			begin
				Le_w_ad <= Le_Rf;
				case(decNum)
					4'b1000:Le_w_sort <= Le_Qf;
					4'b0100:Le_w_sort <= {12'b111111111111,Le_Qf[11:0]};
					4'b0010:Le_w_sort <= {18'b111111111111111111,Le_Qf[5:0]};
					4'b0001:Le_w_sort <= {21'b111111111111111111111,Le_Qf[2:0]};
				endcase
			end
		end
	end
	
	//blockIndex == 0
	Modu_AddrCal1Step AddrCal1Step_backward0(
		//input
		.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpDirection(1'b0),
		.blockSize(blockSize),.decNum(decNum),.Rf2(Rf2),.Qf2(Qf2),
		.Req_Rf_Init(Le_Rf_init_2),.Req_Qf_Init(Le_Qf_init_2[2:0]),
		.Req_Rg_Init(Le_Rg_init_2),.Req_Qg_Init(Le_Qg_init_2[2:0]),
		//output
		.Next_Req_Rf(Le_Rf_0),.Next_Req_Qf(Le_Qf_0),.Next_Req_Rg(Le_Rg_0),.Next_Req_Qg(Le_Qg_0)
		);
		
	//blockIndex == 1
	Modu_AddrCal1Step AddrCal1Step_backward1(
		//input
		.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpDirection(1'b0),
		.blockSize(blockSize),.decNum(decNum),.Rf2(Rf2),.Qf2(Qf2),
		.Req_Rf_Init(Le_Rf_init_2),.Req_Qf_Init(Le_Qf_init_2[5:3]),
		.Req_Rg_Init(Le_Rg_init_2),.Req_Qg_Init(Le_Qg_init_2[5:3]),
		//output
		.Next_Req_Rf(Le_Rf_1),.Next_Req_Qf(Le_Qf_1),.Next_Req_Rg(Le_Rg_1),.Next_Req_Qg(Le_Qg_1)
		);
	
	//blockIndex == 2
	Modu_AddrCal1Step AddrCal1Step_backward2(
		//input
		.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpDirection(1'b0),
		.blockSize(blockSize),.decNum(decNum),.Rf2(Rf2),.Qf2(Qf2),
		.Req_Rf_Init(Le_Rf_init_2),.Req_Qf_Init(Le_Qf_init_2[8:6]),
		.Req_Rg_Init(Le_Rg_init_2),.Req_Qg_Init(Le_Qg_init_2[8:6]),
		//output
		.Next_Req_Rf(Le_Rf_2),.Next_Req_Qf(Le_Qf_2),.Next_Req_Rg(Le_Rg_2),.Next_Req_Qg(Le_Qg_2)
		);
		
	//blockIndex == 3
	Modu_AddrCal1Step AddrCal1Step_backward3(
		//input
		.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpDirection(1'b0),
		.blockSize(blockSize),.decNum(decNum),.Rf2(Rf2),.Qf2(Qf2),
		.Req_Rf_Init(Le_Rf_init_2),.Req_Qf_Init(Le_Qf_init_2[11:9]),
		.Req_Rg_Init(Le_Rg_init_2),.Req_Qg_Init(Le_Qg_init_2[11:9]),
		//output
		.Next_Req_Rf(Le_Rf_3),.Next_Req_Qf(Le_Qf_3),.Next_Req_Rg(Le_Rg_3),.Next_Req_Qg(Le_Qg_3)
		);
	
	//blockIndex == 4
	Modu_AddrCal1Step AddrCal1Step_backward4(
		//input
		.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpDirection(1'b0),
		.blockSize(blockSize),.decNum(decNum),.Rf2(Rf2),.Qf2(Qf2),
		.Req_Rf_Init(Le_Rf_init_2),.Req_Qf_Init(Le_Qf_init_2[14:12]),
		.Req_Rg_Init(Le_Rg_init_2),.Req_Qg_Init(Le_Qg_init_2[14:12]),
		//output
		.Next_Req_Rf(Le_Rf_4),.Next_Req_Qf(Le_Qf_4),.Next_Req_Rg(Le_Rg_4),.Next_Req_Qg(Le_Qg_4)
		);
		
	//blockIndex == 5
	Modu_AddrCal1Step AddrCal1Step_backward5(
		//input
		.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpDirection(1'b0),
		.blockSize(blockSize),.decNum(decNum),.Rf2(Rf2),.Qf2(Qf2),
		.Req_Rf_Init(Le_Rf_init_2),.Req_Qf_Init(Le_Qf_init_2[17:15]),
		.Req_Rg_Init(Le_Rg_init_2),.Req_Qg_Init(Le_Qg_init_2[17:15]),
		//output
		.Next_Req_Rf(Le_Rf_5),.Next_Req_Qf(Le_Qf_5),.Next_Req_Rg(Le_Rg_5),.Next_Req_Qg(Le_Qg_5)
		);
	
	//blockIndex == 6
	Modu_AddrCal1Step AddrCal1Step_backward6(
		//input
		.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpDirection(1'b0),
		.blockSize(blockSize),.decNum(decNum),.Rf2(Rf2),.Qf2(Qf2),
		.Req_Rf_Init(Le_Rf_init_2),.Req_Qf_Init(Le_Qf_init_2[20:18]),
		.Req_Rg_Init(Le_Rg_init_2),.Req_Qg_Init(Le_Qg_init_2[20:18]),
		//output
		.Next_Req_Rf(Le_Rf_6),.Next_Req_Qf(Le_Qf_6),.Next_Req_Rg(Le_Rg_6),.Next_Req_Qg(Le_Qg_6)
		);
		
	//blockIndex == 7
	Modu_AddrCal1Step AddrCal1Step_backward7(
		//input
		.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpDirection(1'b0),
		.blockSize(blockSize),.decNum(decNum),.Rf2(Rf2),.Qf2(Qf2),
		.Req_Rf_Init(Le_Rf_init_2),.Req_Qf_Init(Le_Qf_init_2[23:21]),
		.Req_Rg_Init(Le_Rg_init_2),.Req_Qg_Init(Le_Qg_init_2[23:21]),
		//output
		.Next_Req_Rf(Le_Rf_7),.Next_Req_Qf(Le_Qf_7),.Next_Req_Rg(Le_Rg_7),.Next_Req_Qg(Le_Qg_7)
		);
	

endmodule
