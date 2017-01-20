// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.2 (win64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
// Date        : Thu May 26 08:55:58 2016
// Host        : Xiaoshi-PC running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               C:/Graduate/PCIe/Turbo/pcie_turbo_debug/pcie_turbo.srcs/sources_1/ip/crc_blk_mem_1w_8w/crc_blk_mem_1w_8w_stub.v
// Design      : crc_blk_mem_1w_8w
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1157-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_2,Vivado 2015.2" *)
module crc_blk_mem_1w_8w(clka, ena, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[9:0],dina[7:0],clkb,enb,addrb[6:0],doutb[63:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [9:0]addra;
  input [7:0]dina;
  input clkb;
  input enb;
  input [6:0]addrb;
  output [63:0]doutb;
endmodule
