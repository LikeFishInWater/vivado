/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_Addr_control.v
* Abstract: This is the verilog file that provide almost the necessary addresses and write_enable
* signals for the internal RAMs
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
* Modified on 2012-04-17 for various code length of LTE
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_Addr_control(
	//input
	clk,reset,Init_flag,CmpCounter,decMode,r,q_up,decNum,blockSize,Rf2,Qf2,
	Req_A_Init,Req_Rf_Init,Req_Qf_Init,Req_Rg_Init,Req_Qg_Init,B,
	//output
	AddrP,resortP_delay,AddrSL,resortSL_delay,Le_w_ad,Le_w_sort,Le_w,
	dir_BUFA,Ad_BUFA_read,Ad_BUF0,Ad_BUF1,Ad_BUF2,BUFA_w,BUF0_w,BUF1_w,BUF2_w,
	id_FPU,id_BPU,BPU_tail_Ad,
	//2012.10.18修改Le_parity1的写地址，从而不需要译码完后对这个量再交织才能进行大迭代
	w_ad_Le_par1
	);
	//input
	input clk;
	input reset;
	input Init_flag;
	input [`CmpCounter_width-1:0] CmpCounter;
	input decMode;
	input [`window_width-1:0] r;
	input [3:0] q_up;
	input [3:0] decNum;
	input [`Data_Addr_width-1:0] blockSize;
	input [`Data_Addr_width-1:0] Rf2;
	input [2:0] Qf2;
	input [`Data_Addr_width-1:0]Req_A_Init;
	input [`Data_Addr_width-1:0]Req_Rf_Init;
	input [23:0]Req_Qf_Init;
	input [`Data_Addr_width-1:0]Req_Rg_Init;
	input [23:0]Req_Qg_Init;
	input [`window_width:0] B;
	
	//output
	output [`Data_Addr_width-1:0] AddrP;
	output [23:0] resortP_delay;
	output [`Data_Addr_width-1:0] AddrSL;
	output [23:0] resortSL_delay;
	output [`Data_Addr_width-1:0] Le_w_ad;
	output [23:0] Le_w_sort;
	output Le_w;
	output dir_BUFA;
	output [`window_width-1:0] Ad_BUFA_read;//Ad_BUFA_write为Ad_BUFA_read的1个clk的延时，为了减少端口，在主控单元中实现Ad_BUFA_write
	output [`window_width-1:0] Ad_BUF0;
	output [`window_width-1:0] Ad_BUF1;
	output [`window_width-1:0] Ad_BUF2;
	//output dir_BUF0;
	//output dir_BUF1;
	//output dir_BUF2;
	output BUFA_w;
	output BUF0_w;
	output BUF1_w;
	output BUF2_w;
	output [1:0] id_FPU;
	output [1:0] id_BPU;
	output [2:0] BPU_tail_Ad;
	
	output [`Data_Addr_width-1:0] w_ad_Le_par1;//Add at 2012.10.18
	wire [`Data_Addr_width-1:0] w_ad_Le_par1;//Add at 2012.10.18
//	wire [`Data_Addr_width-1:0] w_ad_Le_par1_temp;//Add at 2012.10.18
	
	reg [23:0] resortP_delay;
	reg [23:0] resortSL_delay;
	reg Le_w;
	reg BUFA_w;
	reg [2:0] BPU_tail_Ad;
	
	wire dir_BUFA;
	wire [`Data_Addr_width-1:0] AddrP;
	wire [23:0] resortP;
	wire [`Data_Addr_width-1:0] AddrSL;
	wire [23:0] resortSL;
	wire [`Data_Addr_width-1:0] Le_w_ad;
	wire [23:0] Le_w_sort;
	wire [`Data_Addr_width-1:0] Req_A;
	wire [`Data_Addr_width-1:0] Req_Rf;
	wire [23:0] Req_Qf;
	wire [`Data_Addr_width-1:0] Req_Rg;
	wire [23:0] Req_Qg;
	wire [`Data_Addr_width-1:0] Le_A_init_2;
	wire [`Data_Addr_width-1:0] Le_Rf_init_2;
	wire [23:0] Le_Qf_init_2;
	wire [`Data_Addr_width-1:0] Le_Rg_init_2;
	wire [23:0] Le_Qg_init_2;
	wire [`Data_Addr_width-1:0] Le_w_ad_temp;
	wire [23:0] Le_w_sort_temp;
	wire [`window_width-1:0] Ad_BUFA_read;
	wire [`window_width-1:0] Ad_BUF0;
	wire [`window_width-1:0] Ad_BUF1;
	wire [`window_width-1:0] Ad_BUF2;
	//wire dir_BUF0;
	//wire dir_BUF1;
	//wire dir_BUF2;
	wire BUF0_w;
	wire BUF1_w;
	wire BUF2_w;
	wire [1:0] id_FPU;
	wire [1:0] id_BPU;
	
	wire [`Data_Addr_width:0] blockSize_add_2B_8;
	wire [`Data_Addr_width:0] blockSize_add_B_4;
	
	assign blockSize_add_B_4 = blockSize + B + 3'b100;
	assign blockSize_add_2B_8 = blockSize + (B << 1) + 4'b1000;
	
	// add for various code length
	wire [4:0] q_up_add_2;
	reg final_BUF_flag_BUF0;
	reg final_BUF_flag_BUF1;
	reg final_BUF_flag_BUF2;
	
	assign q_up_add_2 = {1'b0,q_up} + 3'b010;
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			final_BUF_flag_BUF0 <= 1'b0;
			final_BUF_flag_BUF1 <= 1'b0;
			final_BUF_flag_BUF2 <= 1'b0;
		end
		else
		begin
			final_BUF_flag_BUF0 <= (q_up_add_2==3||q_up_add_2==6||q_up_add_2==9||q_up_add_2==12||q_up_add_2==15) ? 1'b1 : 1'b0;
			//(q_up_add_2[1:0] == 2'b00) ? 1'b1 : 1'b0;
			//final_BUF_flag_BUF1 <= (q_up_add_2[1:0] == 2'b01) ? 1'b1 : 1'b0;
			final_BUF_flag_BUF1 <= (q_up_add_2==4||q_up_add_2==7||q_up_add_2==10||q_up_add_2==13||q_up_add_2==16) ? 1'b1 : 1'b0;
			//final_BUF_flag_BUF2 <= (q_up_add_2[1:0] == 2'b10) ? 1'b1 : 1'b0;
			final_BUF_flag_BUF2 <= (q_up_add_2==5||q_up_add_2==8||q_up_add_2==11||q_up_add_2==14||q_up_add_2==17) ? 1'b1 : 1'b0;
		end
	end
	// add for various code length	
	
//	SRL16	//delay 7
//	Le_w_ad_Delay [`Data_Addr_width-1:0] (.Q(Le_w_ad),.A0(1'b0),.A1(1'b1),.A2(1'b1),.A3(1'b0),.CLK(clk),.D(Le_w_ad_temp));
//	SRL16	//delay 7
//	Le_w_sort_Delay [23:0] (.Q(Le_w_sort),.A0(1'b0),.A1(1'b1),.A2(1'b1),.A3(1'b0),.CLK(clk),.D(Le_w_sort_temp));
	
	Modu_Shift_Reg8	//delay 7
	#(`Data_Addr_width) Le_w_ad_Delay(.clk(clk),.delay(3'b110),.data_in(Le_w_ad_temp),.data_out(Le_w_ad));
	
/*	Modu_Shift_Reg8	//delay 7 Add at 2012.10.18
	#(`Data_Addr_width) Le_w_ad_Delay(.clk(clk),.delay(3'b110),.data_in(w_ad_Le_par1_temp),.data_out(w_ad_Le_par1));*/
	
	Modu_Shift_Reg8	//delay 7
	#(24) Le_w_sort_Delay(.clk(clk),.delay(3'b110),.data_in(Le_w_sort_temp),.data_out(Le_w_sort));
	
	always @(posedge clk)
	begin
		resortP_delay <= resortP;
		resortSL_delay <= resortSL;
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
			Le_w <= 1'b0;
		else if(CmpCounter >= ((B << 1) + 9) && CmpCounter <= blockSize_add_2B_8)
			Le_w <= 1'b1;
		else
			Le_w <= 1'b0;
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
			BUFA_w <= 1'b0;
		else if(CmpCounter >= (B+5) && CmpCounter <= blockSize_add_B_4)
			BUFA_w <= 1'b1;
		else
			BUFA_w <= 1'b0;
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
			BPU_tail_Ad <= 3'b000;
		else if(Init_flag == 1'b1)
			BPU_tail_Ad <= decMode ? 3'b101 : 3'b010;
		else if(CmpCounter == 0)
			BPU_tail_Ad <= decMode ? 3'b100 : 3'b001;
		else
			BPU_tail_Ad <= decMode ? 3'b011 : 3'b000;
	end
	
	/*Calculate the address to read data(system,parity0,parity1) from the out data ROM*/
	/*CmpCounter==0时Req_A/Rf/Qf/Rg/Qg开始有效；CmpCounter==1时AddrP、resortP、AddrSL、resortSL开始有效*/
	Modu_CalcReadAddr CalcReadAddr_modu(
	//input
	.clk(clk),.reset(reset),.Init_flag(Init_flag),.Req_A_Init(Req_A_Init),.Req_Rf_Init(Req_Rf_Init),
	.Req_Qf_Init(Req_Qf_Init),.Req_Rg_Init(Req_Rg_Init),.Req_Qg_Init(Req_Qg_Init),
	.decNum(decNum),.blockSize(blockSize),.decMode(decMode),.Rf2(Rf2),.Qf2(Qf2),
	//output
	.Req_A(Req_A),.Req_Rf(Req_Rf),.Req_Qf(Req_Qf),.Req_Rg(Req_Rg),.Req_Qg(Req_Qg),
	.AddrP(AddrP),.resortP(resortP),.AddrSL(AddrSL),.resortSL(resortSL)
    );
	
	/*Save the initial values of the written address of Le_sys and Le_par*/
	/*CmpCounter==nB-1时Le_Rg/Qg_init_2开始有效；CmpCounter==nB时Le_A/Rf/Qf_init_2开始有效*/
	Modu_SaveLeInitWriteAddr_3BUF SaveLeInitWriteAddr_3BUF_modu(												/////////////////////////////modified1
	//input
	.clk(clk),.reset(reset),.CmpCounter(CmpCounter),.r(r),.q_up(q_up),.blockSize(blockSize),
	.Req_A(Req_A),.Req_Rg(Req_Rg),.Req_Qg(Req_Qg),.Req_Rf(Req_Rf),.Req_Qf(Req_Qf),
	//output
	.Le_A_init_2(Le_A_init_2),.Le_Rf_init_2(Le_Rf_init_2),.Le_Qf_init_2(Le_Qf_init_2),
	.Le_Rg_init_2(Le_Rg_init_2),.Le_Qg_init_2(Le_Qg_init_2)
    );
	
	/*Calculate the address to wite the Le_sys and Le_par to the Le_RAM*/
	/*CmpCounter==nB+3(n>1)时Le_w_ad、Le_w_sort开始有效，根据具体时序进行时延即可*/
	Modu_CalcLeWriteAddr_3BUF CalcLeWriteAddr_3BUF_modu(															/////////////////////////////modified2
	//input
	.clk(clk),.reset(reset),.CmpCounter(CmpCounter),.decMode(decMode),.r(r),.q_up(q_up),
	.decNum(decNum),.blockSize(blockSize),.Rf2(Rf2),.Qf2(Qf2),.resortP(resortP),
	.Le_A_init_2(Le_A_init_2),.Le_Rf_init_2(Le_Rf_init_2),.Le_Qf_init_2(Le_Qf_init_2),
	.Le_Rg_init_2(Le_Rg_init_2),.Le_Qg_init_2(Le_Qg_init_2),
	//output
	.Le_w_ad(Le_w_ad_temp),.Le_w_sort(Le_w_sort_temp),
	.w_ad_Le_par1(w_ad_Le_par1)// Add at 2012.10.18
    );
	 
	/*BUFA for FPU to store the alpha value*/
	/*CmpCounter==5时Ad_BUFA_read开始有效，则相应的Ad_BUFA_write从CmpCounter==6时开始有效*/
	Modu_CalcBufA_Addr CalcBufA_Addr(																					/////////////////////////////modified3
	//input
	.clk(clk),.reset(reset),.initDir(1'b0),.CmpCounter(CmpCounter),.B(B),.q_up(q_up),.r(r),
	//output
	.Ad_BUFA(Ad_BUFA_read),.dir_BUFA(dir_BUFA)
    );
	 
	/*BUF0 of the three data buffer*/
	/*CmpCounter==3时Ad_BUF0开始有效,CmpCounter==2时dir_BUF0开始有效*/
	Modu_CalcBufAddr_3BUF CalcBufAddr_3BUF_BUF0(																		/////////////////////////////modified4
	//input
	.clk(clk),.reset(reset),.initDir(1'b1),.initFlag(2'b01),.CmpCounter(CmpCounter),
	.final_BUF_flag(final_BUF_flag_BUF0),.q_up(q_up),.r(r),
	//output
	.Ad_3BUF(Ad_BUF0)//,.dir_3BUF(dir_BUF0)
    );
	 
	/*BUF1 of the three data buffer*/
	/*CmpCounter==3时Ad_BUF1开始有效,CmpCounter==2时dir_BUF1开始有效*/
	 Modu_CalcBufAddr_3BUF CalcBufAddr_3BUF_BUF1(																		/////////////////////////////modified4
	//input
	.clk(clk),.reset(reset),.initDir(1'b0),.initFlag(2'b00),.CmpCounter(CmpCounter),
	.final_BUF_flag(final_BUF_flag_BUF1),.q_up(q_up),.r(r),
	//output
	.Ad_3BUF(Ad_BUF1)//,.dir_3BUF(dir_BUF1)
    );
	 
	/*BUF2 of the three data buffer*/
	/*CmpCounter==3时Ad_BUF2开始有效,CmpCounter==2时dir_BUF2开始有效*/
	 Modu_CalcBufAddr_3BUF CalcBufAddr_3BUF_BUF2(																		/////////////////////////////modified4
	//input
	.clk(clk),.reset(reset),.initDir(1'b0),.initFlag(2'b10),.CmpCounter(CmpCounter),
	.final_BUF_flag(final_BUF_flag_BUF2),.q_up(q_up),.r(r),
	//output
	.Ad_3BUF(Ad_BUF2)//,.dir_3BUF(dir_BUF2)
    );
	 
	 /*BUF0~2_w CmpCounter==3时开始有效；id_FPU id_BPU分别从CmpCounter==B+4和CmpCounter==2B+4开始有效*/
	 Modu_3BUF_w BUF_w(
	//input
	.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpCounter(CmpCounter),.B(B),
	//output
	.BUF0_w(BUF0_w),.BUF1_w(BUF1_w),.BUF2_w(BUF2_w),.id_FPU(id_FPU),.id_BPU(id_BPU)
	);


endmodule
