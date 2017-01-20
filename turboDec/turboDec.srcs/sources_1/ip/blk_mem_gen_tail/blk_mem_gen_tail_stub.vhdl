-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.2 (win64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
-- Date        : Thu Nov 17 16:28:11 2016
-- Host        : DESKTOP-I4NLUVV running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               f:/projects/vivado/turboDec/turboDec.srcs/sources_1/ip/blk_mem_gen_tail/blk_mem_gen_tail_stub.vhdl
-- Design      : blk_mem_gen_tail
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k325tffg900-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity blk_mem_gen_tail is
  Port ( 
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 6 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 13 downto 0 );
    clkb : in STD_LOGIC;
    enb : in STD_LOGIC;
    addrb : in STD_LOGIC_VECTOR ( 6 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 13 downto 0 )
  );

end blk_mem_gen_tail;

architecture stub of blk_mem_gen_tail is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,ena,wea[0:0],addra[6:0],dina[13:0],clkb,enb,addrb[6:0],doutb[13:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_2,Vivado 2015.2";
begin
end;
