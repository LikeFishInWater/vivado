/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_sysAddLePar_Compute.v
* Abstract: This is the verilog file that compute the branch metric in FPU and BPU
*
* Version:  V5.0
* Author:   Duck
* Time:		2011-11-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_sysAddLePar_Compute(
	//input
	clk,System,Parity,La,
	//output
	sysAddLePar0,sysAddLePar1,Neg_sysAddLePar0,Neg_sysAddLePar1
	);
	
	input clk;
	input [`sys_par_width-1:0] System;
	input [`sys_par_width-1:0] Parity;
	input [`Le_sys_par_width-1:0] La;
	output [`Le_sys_par_width+1:0] sysAddLePar0;
	output [`Le_sys_par_width+1:0] sysAddLePar1;
	output [`Le_sys_par_width+1:0] Neg_sysAddLePar0;
	output [`Le_sys_par_width+1:0] Neg_sysAddLePar1;
	
	reg [`Le_sys_par_width+1:0] sysAddLePar0;
	reg [`Le_sys_par_width+1:0] sysAddLePar1;
	reg [`Le_sys_par_width+1:0] Neg_sysAddLePar0;
	reg [`Le_sys_par_width+1:0] Neg_sysAddLePar1;
	wire [`Le_sys_par_width+1:0] sysAddLePar0_temp;
	wire [`Le_sys_par_width+1:0] sysAddLePar1_temp;
	wire [`Le_sys_par_width+1:0] Neg_sysAddLePar0_temp;
	wire [`Le_sys_par_width+1:0] Neg_sysAddLePar1_temp; 
	
	assign sysAddLePar0_temp = {{(`Le_sys_par_width+2-`sys_par_width){System[`sys_par_width-1]}},System}
	+ {{2{La[`Le_sys_par_width-1]}},La}
	+ {{(`Le_sys_par_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	
	assign sysAddLePar1_temp = {{(`Le_sys_par_width+2-`sys_par_width){System[`sys_par_width-1]}},System}
	+ {{2{La[`Le_sys_par_width-1]}},La}
	- {{(`Le_sys_par_width+2-`sys_par_width){Parity[`sys_par_width-1]}},Parity};
	
	assign Neg_sysAddLePar0_temp = ~sysAddLePar0_temp[`Le_sys_par_width+1:0] + 1'b1;
	
	assign Neg_sysAddLePar1_temp = ~sysAddLePar1_temp[`Le_sys_par_width+1:0] + 1'b1;
	
	
	always @(posedge clk)
	begin
		sysAddLePar0 <= sysAddLePar0_temp;
		sysAddLePar1 <= sysAddLePar1_temp;
		Neg_sysAddLePar0 <= Neg_sysAddLePar0_temp;
		Neg_sysAddLePar1 <= Neg_sysAddLePar1_temp;
	end

endmodule
