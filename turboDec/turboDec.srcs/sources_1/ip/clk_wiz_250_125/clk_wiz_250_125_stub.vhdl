-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.2 (win64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
-- Date        : Thu Nov 17 16:22:01 2016
-- Host        : DESKTOP-I4NLUVV running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               f:/projects/vivado/turboDec/turboDec.srcs/sources_1/ip/clk_wiz_250_125/clk_wiz_250_125_stub.vhdl
-- Design      : clk_wiz_250_125
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k325tffg900-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_wiz_250_125 is
  Port ( 
    clk_in1 : in STD_LOGIC;
    clk_out1 : out STD_LOGIC
  );

end clk_wiz_250_125;

architecture stub of clk_wiz_250_125 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_in1,clk_out1";
begin
end;
