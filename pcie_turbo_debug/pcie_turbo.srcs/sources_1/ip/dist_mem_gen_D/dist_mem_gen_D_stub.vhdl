-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.2 (win64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
-- Date        : Tue May 17 13:38:41 2016
-- Host        : Xiaoshi-PC running 64-bit Service Pack 1  (build 7601)
-- Command     : write_vhdl -force -mode synth_stub
--               C:/Graduate/PCIe/Turbo/pcie_turbo_debug/pcie_turbo.srcs/sources_1/ip/dist_mem_gen_D/dist_mem_gen_D_stub.vhdl
-- Design      : dist_mem_gen_D
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7vx690tffg1157-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dist_mem_gen_D is
  Port ( 
    a : in STD_LOGIC_VECTOR ( 14 downto 0 );
    d : in STD_LOGIC_VECTOR ( 63 downto 0 );
    dpra : in STD_LOGIC_VECTOR ( 14 downto 0 );
    clk : in STD_LOGIC;
    we : in STD_LOGIC;
    dpo : out STD_LOGIC_VECTOR ( 63 downto 0 )
  );

end dist_mem_gen_D;

architecture stub of dist_mem_gen_D is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "a[14:0],d[63:0],dpra[14:0],clk,we,dpo[63:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "dist_mem_gen_v8_0,Vivado 2015.2";
begin
end;
