/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_Subdecoder.v
* Abstract: This is the verilog file that define the parallel subdecoders in each
* subdecoder
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_SW_MAP_3BUF(
	//input
	clk,Iter,decMode,blockIndex,decNum,System,Parity,La,
	dir_BUFA,Ad_BUFA_read,Ad_BUF0,Ad_BUF1,Ad_BUF2,BUF_w,id_FPU,id_BPU,
	Init_Flag_BPU_M,Init_Flag_BPU_L,Init_Flag_FPU,initBeta,initAlpha,
	q_up, // add by shaxiaoshi 2016.3.8
	//output
	BPU_beta_out_next,FPU_alpha_out_next,
	D,Le_sys,Le_par
	);
	
	//input
	input clk;
	input [3:0] Iter;
	input decMode;
	input [2:0] blockIndex;
	input [3:0] decNum;
	input [`sys_par_width-1:0] System;
	input [`sys_par_width-1:0] Parity;
	input [`Le_sys_par_width-1:0] La;
	input dir_BUFA;
	input [`window_width-1:0] Ad_BUFA_read;
	input [`window_width-1:0] Ad_BUF0;
	input [`window_width-1:0] Ad_BUF1;
	input [`window_width-1:0] Ad_BUF2;
	input [3:0] BUF_w;
	input [1:0] id_FPU;
	input [1:0] id_BPU;
	input Init_Flag_BPU_M;
	input Init_Flag_BPU_L;
	input Init_Flag_FPU;
	input [`beta_alpha_width*8-1:0] initBeta;
	input [`beta_alpha_width*8-1:0] initAlpha;
	
	input [3:0] q_up; // add by shaxiaoshi 2016.3.8
	
	//output
	output [`beta_alpha_width*8-1:0] BPU_beta_out_next;
	output [`beta_alpha_width*8-1:0] FPU_alpha_out_next;
	output D;
	output [`Le_sys_par_width-1:0] Le_sys;
	output [`Le_sys_par_width-1:0] Le_par;
	
	reg [`window_width-1:0] Ad_BUFA_write;
	wire [`beta_alpha_width*8-1:0] BPU_beta_out_next;
	reg [`beta_alpha_width*8-1:0] FPU_alpha_out_last;
	wire [`beta_alpha_width*8-1:0] FPU_alpha_out;
	wire [`beta_alpha_width*8-1:0] FPU_alpha_out_next;
	wire [`beta_alpha_width*8-1:0] BPU_alpha_temp;
	wire [`beta_alpha_width*8-1:0] BPU_alpha;
	wire D;
	wire [`Le_sys_par_width-1:0] Le_sys;
	wire [`Le_sys_par_width-1:0] Le_par;
	wire [`sys_par_width*2+`Le_sys_par_width-1:0] BUF_In_data;	//Input_data to instore in 3 data BUF
	wire [`sys_par_width*2+`Le_sys_par_width-1:0] data_BUF0;		//Output of data_BUF0
	wire [`sys_par_width*2+`Le_sys_par_width-1:0] data_BUF1;		//Output of data_BUF1
	wire [`sys_par_width*2+`Le_sys_par_width-1:0] data_BUF2;		//Output of data_BUF2
	wire [`sys_par_width*2+`Le_sys_par_width-1:0] data_In_FPU;	//Input_data for FPU,choose from the output of 3 data_BUF
	wire [`sys_par_width*2+`Le_sys_par_width-1:0] data_In_BPU;	//Input_data for FPU,choose from the output of 3 data_BUF
	
	assign BUF_In_data[`sys_par_width*2+`Le_sys_par_width-1:`sys_par_width*2] = La;
	assign BUF_In_data[`sys_par_width*2-1:`sys_par_width] = Parity;
	assign BUF_In_data[`sys_par_width-1:0] =  System;
	
	//assign BPU_alpha = Ad_BUFA_read==6'b111111 ? FPU_alpha_out_next : BPU_alpha_temp;
	assign BPU_alpha=(Ad_BUFA_read==6'b111110 && dir_BUFA == 1'b0)||(Ad_BUFA_read==6'b000001 && dir_BUFA == 1'b1) ? FPU_alpha_out_last:BPU_alpha_temp;
	
	always @(posedge clk)
	begin
		FPU_alpha_out_last <= FPU_alpha_out;
	end
	
	always @(posedge clk)
	begin
		Ad_BUFA_write <= Ad_BUFA_read;
	end
	
//	Modu_BUF_data BUF0(.clka(clk),.wea(BUF_w[0]),.addra(Ad_BUF0),.dina(BUF_In_data),.douta(data_BUF0));
//	Modu_BUF_data BUF1(.clka(clk),.wea(BUF_w[1]),.addra(Ad_BUF1),.dina(BUF_In_data),.douta(data_BUF1));
//	Modu_BUF_data BUF2(.clka(clk),.wea(BUF_w[2]),.addra(Ad_BUF2),.dina(BUF_In_data),.douta(data_BUF2));
	
//	Modu_alpha_BUFA BUFA(
//	.clka(clk),.wea(BUF_w[3]),.addra(Ad_BUFA_write),.dina(FPU_alpha_out),.douta(),//write port
//	.clkb(clk),.enb(1'b1),.web(1'b0),.addrb(Ad_BUFA_read),.dinb(),.doutb(BPU_alpha));//read port
	Modu_Distributed_Single_RAM #((`sys_par_width*2+`Le_sys_par_width),`window_width) BUF0(
	.clk(clk),.write_enable(BUF_w[0]),.address(Ad_BUF0),.input_data(BUF_In_data),.output_data(data_BUF0)
	);
	Modu_Distributed_Single_RAM #((`sys_par_width*2+`Le_sys_par_width),`window_width) BUF1(
	.clk(clk),.write_enable(BUF_w[1]),.address(Ad_BUF1),.input_data(BUF_In_data),.output_data(data_BUF1)
	);
	Modu_Distributed_Single_RAM #((`sys_par_width*2+`Le_sys_par_width),`window_width) BUF2(
	.clk(clk),.write_enable(BUF_w[2]),.address(Ad_BUF2),.input_data(BUF_In_data),.output_data(data_BUF2)
	);
	
	Modu_Distributed_Dual_RAM #((`beta_alpha_width*8),`window_width) BUFA(
	//input
	.clk(clk),.write_address(Ad_BUFA_write),.write_enable(BUF_w[3]),.input_data(FPU_alpha_out),
	.read_address(Ad_BUFA_read),
	//output
	.output_data(BPU_alpha_temp)
	);
	
	Modu_SelectBUF_3BUF SelectBUF_FPU_BPU(
	//input
	.clk(clk),.id_FPU(id_FPU),.id_BPU(id_BPU),.Iter(Iter),.decMode(decMode),
	.data_BUF0(data_BUF0),.data_BUF1(data_BUF1),.data_BUF2(data_BUF2),
	//output
	.data_out_FPU(data_In_FPU),.data_out_BPU(data_In_BPU)
	);
	
	Modu_FPU FPU(
	//input
	.clk(clk),.Iter(Iter),.blockIndex(blockIndex),.Init_Flag_FPU(Init_Flag_FPU),.initAlpha(initAlpha),
	.data_In_FPU(data_In_FPU),
	//output
	.alphaValueOut(FPU_alpha_out),.alphaValueOut_next(FPU_alpha_out_next)
	);
	
	Modu_BPU BPU(
	//input
	.clk(clk),.Iter(Iter),.blockIndex(blockIndex),.Parallel_degree(decNum),
	.Init_Flag_BPU_M(Init_Flag_BPU_M),.Init_Flag_BPU_L(Init_Flag_BPU_L),
	.initBeta(initBeta),.Alpha_In_BPU(BPU_alpha),
	.data_In_BPU(data_In_BPU),
	.q_up(q_up), // add by shaxiasohi 2016.3.8
	//output
	.betaValueOut_next(BPU_beta_out_next),.Le_sys(Le_sys),.Le_par(Le_par),.D(D)
	);


endmodule
