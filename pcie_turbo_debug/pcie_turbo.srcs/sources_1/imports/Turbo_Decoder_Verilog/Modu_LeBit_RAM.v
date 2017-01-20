/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_LeBit_RAM.v
* Abstract: This is the verilog file that store the soft-output of the decoder
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_LeBit_RAM(
	//input
	clk,Le_sysBit_In,Le_parBit_In,Le_w_ad_delay4,Le_w_sort_delay3,Le_w_delay4,
	AddrSL,resortSL,Iter_Max,Iter,decMode,
	w_ad_Le_par1_delay4,//Add at 2012.10.18
	//output
	Le_sysBit_Out_sort,Le_parBit0_Out_sort,Le_parBit1_Out_sort
	);
	//input
	input clk;
	input [`Le_sys_par_width*8-1:0] Le_sysBit_In;
	input [`Le_sys_par_width*8-1:0] Le_parBit_In;
	input [`Data_Addr_width-1:0] Le_w_ad_delay4;
	input [23:0] Le_w_sort_delay3;
	input Le_w_delay4;
	input [`Data_Addr_width-1:0] AddrSL;
	input [23:0] resortSL;//为延时后的值，比AddrSL迟一个clk
	input [3:0] Iter_Max;
	input [3:0] Iter;
	input decMode;
	input [`Data_Addr_width-1:0] w_ad_Le_par1_delay4;//Add at 2012.10.18
	//output
	output [`Le_sys_par_width*8-1:0] Le_sysBit_Out_sort;
	output [`Le_sys_par_width*8-1:0] Le_parBit0_Out_sort;
	output [`Le_sys_par_width*8-1:0] Le_parBit1_Out_sort;
	
	wire [`Le_sys_par_width*8-1:0] Le_sysBit_In_sort;
	reg [`Le_sys_par_width*8-1:0] Le_parBit_In_sort;
	wire [`Le_sys_par_width*8-1:0] Le_sys_data;
	wire [`Le_sys_par_width*8-1:0] Le_par0_data;
	wire [`Le_sys_par_width*8-1:0] Le_par1_data;
	
	wire Le_w_par0;
	assign Le_w_par0 = ((Iter+1'b1)==Iter_Max && decMode==1'b0) ? Le_w_delay4 : 1'b0 ;
	
//	Modu_Le_RAM Le_sys_RAM(
//	.clka(clk),.wea(Le_w_delay4),.addra(Le_w_ad_delay4),.dina(Le_sysBit_In_sort),.douta(),//write port
//	.clkb(clk),.enb(1'b1),.web(1'b0),.addrb(AddrSL),.dinb(),.doutb(Le_sys_data));//read port
	
//	Modu_Le_RAM Le_par_RAM(
//	.clka(clk),.wea(Le_w_delay4),.addra(Le_w_ad_delay4),.dina(Le_parBit_In_sort),.douta(),//write port
//	.clkb(clk),.enb(1'b1),.web(1'b0),.addrb(AddrSL),.dinb(),.doutb(Le_par_data));//read port

	Modu_Block_Dual_RAM #((8*`Le_sys_par_width),(`Data_Addr_width)) Le_sys_RAM(.clk(clk),	
	.write_enable(Le_w_delay4),.write_address(Le_w_ad_delay4),.input_data(Le_sysBit_In_sort),	//write port
	.read_address(AddrSL),.output_data(Le_sys_data)															//read port
	);
	
/*	Modu_Block_Dual_RAM #((8*`Le_sys_par_width),(`Data_Addr_width)) Le_par1_RAM(.clk(clk),	
	.write_enable(Le_w_delay4),.write_address(Le_w_ad_delay4),.input_data(Le_parBit_In_sort),	//write port
	.read_address(AddrSL),.output_data(Le_par1_data)															//read port
	);*/
	
	//改变写地址 2012.10.18
	Modu_Block_Dual_RAM #((8*`Le_sys_par_width),(`Data_Addr_width)) Le_par1_RAM(.clk(clk),	
	.write_enable(Le_w_delay4),.write_address(w_ad_Le_par1_delay4),.input_data(Le_parBit_In_sort),	//write port
	.read_address(AddrSL),.output_data(Le_par1_data)															//read port
	);
	
	
	Modu_Block_Dual_RAM #((8*`Le_sys_par_width),(`Data_Addr_width)) Le_par0_RAM(.clk(clk),	
	.write_enable(Le_w_par0),.write_address(Le_w_ad_delay4),.input_data(Le_parBit_In_sort),	//write port
	.read_address(AddrSL),.output_data(Le_par0_data)															//read port
	);
	
	//输入重排
	Modu_Reorder_writeEn_1 #(`Le_sys_par_width) Reorder_Le_sysBit_In(
	//input
	.clk(clk),.data_in(Le_sysBit_In),.resortSE(Le_w_sort_delay3),
	//output
	.data_out(Le_sysBit_In_sort)
	);
	
/*	//修改校验位软量的存入地址从而保证译码完不需要对Le_parity1进行交织才可以进行大迭代2012.10.18
	Modu_Reorder_writeEn_1 #(`Le_sys_par_width) Reorder_Le_parBit_In(
	//input
	.clk(clk),.data_in(Le_parBit_In),.resortSE(Le_w_sort_delay3),
	//output
	.data_out(Le_parBit_In_sort)
	);*/
	
	always@(posedge clk)
	begin
		Le_parBit_In_sort <= Le_parBit_In;// 不需要重排的
	end
	
	//输出重排
	Modu_Reorder_writeEn_0 #(`Le_sys_par_width) Reorder_Le_sysBit_Out(
	//input
	.clk(clk),.data_in(Le_sys_data),.resortSE(resortSL),
	//output
	.data_out(Le_sysBit_Out_sort)
	);
	
	Modu_Reorder_writeEn_0 #(`Le_sys_par_width) Reorder_Le_parBit1_Out(
	//input
	.clk(clk),.data_in(Le_par1_data),.resortSE(resortSL),
	//output
	.data_out(Le_parBit1_Out_sort)
	);
	
	Modu_Reorder_writeEn_0 #(`Le_sys_par_width) Reorder_Le_parBit0_Out(
	//input
	.clk(clk),.data_in(Le_par0_data),.resortSE(resortSL),
	//output
	.data_out(Le_parBit0_Out_sort)
	);

endmodule
