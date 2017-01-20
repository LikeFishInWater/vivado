/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_D_RAM.v
* Abstract: This is the verilog file that define the distributes block single-port RAM. The address_width
* can be set as wanted.The decoded results are stored here
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_D_RAM(
	//input
	clk,D_In,Le_w_ad_delay1,Le_w_sort,Le_w_delay1,
	D_r_ad,
	decMode, // revised by shaxiaoshi 2016.5.5  add
	//output
	D_out//输出还不完善，需要根据后续情况修改
	);
	//input
	input clk;
	input [7:0] D_In;
	input [`Data_Addr_width-1:0] Le_w_ad_delay1;
	input [23:0] Le_w_sort;
	input Le_w_delay1;
	input [`Data_Addr_width-1:0] D_r_ad;
	input decMode; // revised by shaxiaoshi 2016.5.5  add
	//output
	output [7:0] D_out;
	
	wire [7:0] D_In_sort;
	
//	Modu_result_RAM result_RAM(
//	.clka(clk),.wea(Le_w_delay1),.addra(Le_w_ad_delay1),.dina(D_In_sort),.douta(),//write port
//	.clkb(clk),.enb(1'b1),.web(1'b0),.addrb(D_r_ad),.dinb(),.doutb(D_out));//read port

	Modu_Block_Dual_RAM #(8,(`Data_Addr_width + 1)) result_RAM(.clk(clk),	
	.write_enable(Le_w_delay1),.write_address({decMode, Le_w_ad_delay1}),.input_data(D_In_sort),			//write port
	.read_address({~decMode, D_r_ad}),.output_data(D_out)													//read port
	);
	// revised by shaxiaoshi 2016.5.5  
	// add  .write_address({decMode, Le_w_ad_delay1})
	// add  .read_address({~decMode, D_r_ad})
	
	//输入重排
	Modu_Reorder_writeEn_1 #(1) Reorder_D_In(
	//input
	.clk(clk),.data_in(D_In),.resortSE(Le_w_sort),
	//output
	.data_out(D_In_sort)
	);
	
//	integer handle;
	
/*	initial
	begin
		#27457;
		handle = $fopen("result.txt");
		#1822;
		$fclose(handle);
	end
	always @(posedge clk)
	begin
		$fdisplay(handle,"%b",D_In_sort);
	end*/


endmodule
