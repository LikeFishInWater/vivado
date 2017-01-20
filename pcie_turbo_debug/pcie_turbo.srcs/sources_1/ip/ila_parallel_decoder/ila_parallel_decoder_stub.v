// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.2 (win64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
// Date        : Mon May 23 17:51:19 2016
// Host        : Xiaoshi-PC running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               c:/Graduate/PCIe/Turbo/pcie_turbo_debug/pcie_turbo.srcs/sources_1/ip/ila_parallel_decoder/ila_parallel_decoder_stub.v
// Design      : ila_parallel_decoder
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1157-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2015.2" *)
module ila_parallel_decoder(clk, probe0, probe1, probe2, probe3, probe4, probe5, probe6, probe7, probe8, probe9, probe10, probe11)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[4:0],probe1[3:0],probe2[3:0],probe3[1:0],probe4[0:0],probe5[0:0],probe6[0:0],probe7[3:0],probe8[1:0],probe9[0:0],probe10[0:0],probe11[0:0]" */;
  input clk;
  input [4:0]probe0;
  input [3:0]probe1;
  input [3:0]probe2;
  input [1:0]probe3;
  input [0:0]probe4;
  input [0:0]probe5;
  input [0:0]probe6;
  input [3:0]probe7;
  input [1:0]probe8;
  input [0:0]probe9;
  input [0:0]probe10;
  input [0:0]probe11;
endmodule
