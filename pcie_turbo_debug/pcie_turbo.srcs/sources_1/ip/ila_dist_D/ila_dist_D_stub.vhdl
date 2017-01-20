-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.2 (win64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
-- Date        : Wed May 25 13:23:10 2016
-- Host        : Xiaoshi-PC running 64-bit Service Pack 1  (build 7601)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Graduate/PCIe/Turbo/pcie_turbo_debug/pcie_turbo.srcs/sources_1/ip/ila_dist_D/ila_dist_D_stub.vhdl
-- Design      : ila_dist_D
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7vx690tffg1157-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ila_dist_D is
  Port ( 
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 10 downto 0 );
    probe1 : in STD_LOGIC_VECTOR ( 63 downto 0 );
    probe2 : in STD_LOGIC_VECTOR ( 10 downto 0 );
    probe3 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe4 : in STD_LOGIC_VECTOR ( 63 downto 0 )
  );

end ila_dist_D;

architecture stub of ila_dist_D is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe0[10:0],probe1[63:0],probe2[10:0],probe3[0:0],probe4[63:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "ila,Vivado 2015.2";
begin
end;
