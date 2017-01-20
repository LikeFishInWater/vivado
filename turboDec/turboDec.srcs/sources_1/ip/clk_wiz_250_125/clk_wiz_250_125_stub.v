// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.2 (win64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
// Date        : Thu Nov 17 16:22:01 2016
// Host        : DESKTOP-I4NLUVV running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               f:/projects/vivado/turboDec/turboDec.srcs/sources_1/ip/clk_wiz_250_125/clk_wiz_250_125_stub.v
// Design      : clk_wiz_250_125
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_250_125(clk_in1, clk_out1)
/* synthesis syn_black_box black_box_pad_pin="clk_in1,clk_out1" */;
  input clk_in1;
  output clk_out1;
endmodule
