// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.2 (win64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
// Date        : Wed May 25 21:18:39 2016
// Host        : Xiaoshi-PC running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               c:/Graduate/PCIe/Turbo/pcie_turbo_debug/pcie_turbo.srcs/sources_1/ip/ila_1/ila_1_stub.v
// Design      : ila_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1157-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2015.2" *)
module ila_1(clk, probe0, probe1, probe2, probe3, probe4, probe5, probe6, probe7, probe8, probe9, probe10, probe11)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[0:0],probe1[127:0],probe2[0:0],probe3[0:0],probe4[0:0],probe5[127:0],probe6[0:0],probe7[0:0],probe8[4:0],probe9[31:0],probe10[31:0],probe11[10:0]" */;
  input clk;
  input [0:0]probe0;
  input [127:0]probe1;
  input [0:0]probe2;
  input [0:0]probe3;
  input [0:0]probe4;
  input [127:0]probe5;
  input [0:0]probe6;
  input [0:0]probe7;
  input [4:0]probe8;
  input [31:0]probe9;
  input [31:0]probe10;
  input [10:0]probe11;
endmodule
