/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_Decoder.v
* Abstract: This is the verilog file of the decoder
* Discription: "System_In_ROM,Parity0_In_ROM,Parity1_In_ROM,SYS_PAR_Ram_w_addr,Tail_In_ROM,Tail_RAM_w_addr,SYS_PAR_Ram_w,Tail_RAM_w" are entries for 
					decoding data. Before decoding, the data should be prepaired. When data is ready, start_decode=1'b1 will begin the decoder.
					Sub-DEC0 and sub-DEC1 use the same modu named Modu_Subdecoder, and they work serially. The decMode and decoding data for them are different.
					After Turbo decoding, CRC module begins to work. End_CB is the finished flag of these two modules.
					D is the decoding hard-decision output, that will sent into CRC module to check. And Le_sys,Le_par0,Le_par1 are the soft-output ex-information
					for Outer-iteration.
					
					This code has one shortcoming: (length of decoded data)/Parallel_degree must be the integral multiple of window length 64. So this code can only work for
					the special code word length, such as 64*8*i,(i=1,2...,12)
*
* Version:  V5.1
* Author:   Duck
* Time:		2012-04-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_Decoder_New_CRC(
	//input
	clk,reset,Start_Cmp,CB_length,Parallel_degree,Iter_Max,CRC_type,
	System_In_ROM,Parity0_In_ROM,Parity1_In_ROM,Tail_In_ROM,
	//output
	Read_Addr_system,Read_Addr_parity,Read_Addr_tail,
	
	// output revised by shaxiaoshi
	CRC_result, Decode_Result_Start, Decode_Result_Addr, Decode_result_D, End_Decode
	);
	//input
	input clk;
	input reset;
	input Start_Cmp;
	input [12:0] CB_length;
	input [3:0] Parallel_degree;
	input [3:0] Iter_Max;
	input CRC_type;
	
	input [`sys_par_width*8-1:0] System_In_ROM;
	input [`sys_par_width*8-1:0] Parity0_In_ROM;
	input [`sys_par_width*8-1:0] Parity1_In_ROM;
	input [`sys_par_width*2-1:0] Tail_In_ROM;
	
	//output
	output [`Data_Addr_width-1:0] Read_Addr_system;
	output [`Data_Addr_width-1:0] Read_Addr_parity;
	output [2:0] Read_Addr_tail;

	output CRC_result;							 //output result of crc check.1-->right, 0-->wrong
	output Decode_Result_Start;
	output [6:0] Decode_Result_Addr;
	output [63:0] Decode_result_D;
	output End_Decode;								//end flag of Turbo decoder and CRC modules
	
	
	wire [`Data_Addr_width-1:0] D_r_ad;
	
	
	wire start_decode;
	wire [7:0] D;

	wire end_Subde;
	wire CRC_result; 
	wire End_CB;

	reg [12:0] CRC_data_length;
	
	reg Init_flag;
	reg enable_Subde;
	reg [3:0] Iter;
	reg decMode;
	wire [5:0] r;
	wire [3:0] q_up;
	wire [9:0] blockSize;
	wire [9:0] Rf2;
	wire [2:0] Qf2;
	wire [9:0] Req_A_Init;
	wire [9:0] Req_Rf_Init;
	wire [23:0] Req_Qf_Init;
	wire [9:0] Req_Rg_Init;
	wire [23:0] Req_Qg_Init;
	wire [6:0] B;
	reg End_flag;	
	
	reg [`Data_Addr_width-1:0] SYS_PAR_Ram_w_addr;//将外部ROM中的数据写入subdecoder的译码数据RAM中的写地址
	reg [2:0] Tail_RAM_w_addr;//每个地址单元中存储有一个校验比特和一个系统比特，共需要6个存储单元

	Modu_InputPara InputPara(
	//input
	.clk(clk),.reset(reset),.Start_Cmp(Start_Cmp),
	.CB_length(CB_length),.Parallel_degree(Parallel_degree),
	//output
	.BLOCK_SIZE(blockSize),.window_size(B),.Req_A_Init(Req_A_Init),.Req_Rf_Init(Req_Rf_Init),.Req_Qf_Init(Req_Qf_Init),.Req_Rg_Init(Req_Rg_Init),.Req_Qg_Init(Req_Qg_Init),
	.Rf2(Rf2),.Qf2(Qf2),.r(r),.q_up(q_up),.start_decode(start_decode)
	);
	
	Modu_Subdecoder Subdecoder(
	//input.译码数据、译码结果、BPU、FPU初值均存储于该模块的RAM中，
	.clk(clk),.reset(reset),.Init_flag(Init_flag),.enable_Subde(enable_Subde),.Iter_Max(Iter_Max),
	.Iter(Iter),.decMode(decMode),
	.r(r),.q_up(q_up),.decNum(Parallel_degree),.blockSize(blockSize),.Rf2(Rf2),.Qf2(Qf2),
	.Req_A_Init(Req_A_Init),.Req_Rf_Init(Req_Rf_Init),.Req_Qf_Init(Req_Qf_Init),.Req_Rg_Init(Req_Rg_Init),
	.Req_Qg_Init(Req_Qg_Init),.B(B),
	.SystemBit(System_In_ROM),.ParityBit0(Parity0_In_ROM),.ParityBit1(Parity1_In_ROM),
	.TailBit(Tail_In_ROM),.D_r_ad(D_r_ad),
	//output
	.decode_result(D),.Le_sys_data_sort(),.Le_par0_data_sort(),.Le_par1_data_sort(),.end_Subde(end_Subde),
	.AddrSL(Read_Addr_system),.AddrP(Read_Addr_parity),.BPU_tail_Ad(Read_Addr_tail)
	);
	
	
	
	reg Decode_Result_Start;
	wire [6:0] Decode_Result_Addr;
	wire [63:0] Decode_result_D;
	reg End_Decode;								//end flag of Turbo decoder and CRC modules
	
	// state machine for restore decode result D
	reg [1:0] sm_restore_D;
	parameter idle = 2'd0, restore = 2'd1, over = 2'd3;
	
	reg [9:0] restore_count;
	assign Decode_Result_Addr = restore_count;
	
	always @ (posedge clk)
	begin
		if(reset == 1'b0)
			restore_count <= 0;
		else
		begin
			if(sm_restore_D == restore)
				restore_count <= restore_count + 1;
			else
				restore_count <= -1;
		end
	end
	
	
	always @ (posedge clk)
	begin
		if(reset == 1'b0)
			sm_restore_D <= idle;
		else
		begin
			case(sm_restore_D)
				idle:
				begin
					End_Decode <= 1'b0;
					if(decode_over)
					begin
						sm_restore_D <= restore;
						Decode_Result_Start <= 1'b1;
					end
					else
					begin
						sm_restore_D <= idle;
						Decode_Result_Start <= 1'b0;
					end
				end
				
				restore:
				begin
					Decode_Result_Start <= 1'b0;
					if(restore_count == ((blockSize >> 3)))
					begin
						End_Decode <= 1'b1;
						sm_restore_D <= over;
					end
					else
					begin
						End_Decode <= 1'b0;
						sm_restore_D <= restore;
					end
				end
				over:
				begin
					sm_restore_D <= over;
				end
			endcase
		end
	end
	
	reg crc_result;
	assign CRC_result = crc_result;
	reg crc_start_0, crc_start_1;
	always @ (posedge clk)
	begin
		if(end_Subde == 1'b1 && decMode == 1'b0 && crc_result == 1'b0)
			crc_start_0 <= 1'b1;
		else
			crc_start_0 <= 1'b0;
	end
	
	always @ (posedge clk)
	begin
		if(end_Subde == 1'b1 && decMode == 1'b1 && crc_result == 1'b0)
			crc_start_1 <= 1'b1;
		else
			crc_start_1 <= 1'b0;
	end
	
	
	wire crc_result_0, crc_result_1;
	wire crc_end_0, crc_end_1;
	wire [`Data_Addr_width-1:0] D_r_ad_0, D_r_ad_1;
	
	wire [63:0] blk_mem_dout_0, blk_mem_dout_1;
	
	Turbo_CRC24 turbo_crc24_0_inst(
	//input
	.clk(clk), .reset(~reset), .CRC_start(crc_start_0), .CRC_type(CRC_type), .D(D), .data_length(CRC_data_length),
	.restore_D_addr(Decode_Result_Addr),
	//output.1-->right, 0-->wrong
	.D_addr(D_r_ad_0), .CRC_result(crc_result_0), .end_CRC(crc_end_0),
	.blk_mem_dout(blk_mem_dout_0)
	);
	
	Turbo_CRC24 turbo_crc24_1_inst(
	//input
	.clk(clk), .reset(~reset), .CRC_start(crc_start_1), .CRC_type(CRC_type), .D(D), .data_length(CRC_data_length),
	.restore_D_addr(Decode_Result_Addr),
	//output.1-->right, 0-->wrong
	.D_addr(D_r_ad_1), .CRC_result(crc_result_1), .end_CRC(crc_end_1),
	.blk_mem_dout(blk_mem_dout_1)
	);
	
	assign Decode_result_D = ((crc_result_0 & crc_end_0))? blk_mem_dout_0 : blk_mem_dout_1;
	
	assign D_r_ad = (decMode == 1'b0)? D_r_ad_1 : D_r_ad_0;

	reg crc_start_1_delay;
	always @ (posedge clk)
		crc_start_1_delay <= crc_start_1;
	
	reg decode_over;
	always @ (posedge clk)
	begin
		if(reset == 1'b0)
		begin
			decode_over <= 1'b0;
			crc_result <= 1'b0;
		end
		else
		begin
			if(crc_result == 1'b0)
			begin
				if((crc_result_0 & crc_end_0) || (crc_result_1 & crc_end_1))
				begin
					decode_over <= 1'b1;
					crc_result <= 1'b1;
				end
				else if(Iter == Iter_Max && crc_end_1 && ~crc_start_1_delay && ~crc_start_1)
				begin
					decode_over <= 1'b1;
					crc_result <= crc_result_1;
				end
				else
				begin
					decode_over <= 1'b0;
					crc_result <= 1'b0;
				end
			end
			else
			begin
				decode_over <= decode_over;
				crc_result<= 1'b1;
			end
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Init_flag <= 1'b0;
		end
		else if(crc_result == 1'b1)
		begin
			Init_flag <= 1'b0;
		end
		else if(start_decode == 1'b1 || end_Subde == 1'b1) 				// revised by shaxiaoshi add && ~crc_result
		begin
			Init_flag <= 1'b1;
		end
		else
		begin
			Init_flag <= 1'b0;
		end
	end
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			enable_Subde <= 1'b0;
		end
		else if(Iter < Iter_Max)
		begin
			enable_Subde <= 1'b1;
		end
		else
		begin
			enable_Subde <= 1'b0;
		end
	end

	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Iter <= 4'b1111;
		end
		else if(Start_Cmp == 1'b1)
		begin
			Iter <= 4'b0000;
		end
		else if(end_Subde == 1'b1 && decMode == 1'b1 && Iter < Iter_Max)
		begin
			Iter <= Iter + 1'b1;
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			decMode <= 1'b0;
		end
		else if(end_Subde)
		begin
			decMode <= ~decMode;
		end
	end

/*	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			End_flag <= 1'b0;
		end
		else if(Iter == Iter_Max-1'b1 && end_Subde == 1'b1 && decMode == 1'b1)
		begin
			End_flag <= 1'b1;
		end
	end
*/

/*
	//add for CRC module following Turbo decoding
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			CRC_start_temp <= 1'b0;
		end
		else if(Iter == Iter_Max-1'b1 && end_Subde == 1'b1 && decMode == 1'b1)
		begin
			CRC_start_temp <= 1'b1;
		end
	end
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			CRC_start <= 1'b0;
		end
		else if(Iter == Iter_Max-1'b1 && end_Subde == 1'b1 && decMode == 1'b1 && CRC_start_temp == 1'b0)
		begin
			CRC_start <= 1'b1;
		end
		else
		begin
			CRC_start <= 1'b0;
		end
	end
*/

	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			CRC_data_length <= 13'b0;
		end
		else if(Parallel_degree == 4'b1000)
		begin
			CRC_data_length <= (blockSize<<3);
		end
		else if(Parallel_degree == 4'b0100)
		begin
			CRC_data_length <= (blockSize<<2);
		end
		else if(Parallel_degree == 4'b0010)
		begin
			CRC_data_length <= (blockSize<<1);
		end
		else if(Parallel_degree == 4'b0001)
		begin
			CRC_data_length <= blockSize;
		end
	end

	
endmodule
