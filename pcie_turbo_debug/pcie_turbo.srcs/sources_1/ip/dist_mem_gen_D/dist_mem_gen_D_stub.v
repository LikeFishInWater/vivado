// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.2 (win64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
// Date        : Tue May 17 13:38:41 2016
// Host        : Xiaoshi-PC running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               C:/Graduate/PCIe/Turbo/pcie_turbo_debug/pcie_turbo.srcs/sources_1/ip/dist_mem_gen_D/dist_mem_gen_D_stub.v
// Design      : dist_mem_gen_D
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1157-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0,Vivado 2015.2" *)
module dist_mem_gen_D(a, d, dpra, clk, we, dpo)
/* synthesis syn_black_box black_box_pad_pin="a[14:0],d[63:0],dpra[14:0],clk,we,dpo[63:0]" */;
  input [14:0]a;
  input [63:0]d;
  input [14:0]dpra;
  input clk;
  input we;
  output [63:0]dpo;
endmodule
