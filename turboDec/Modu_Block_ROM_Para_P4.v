`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:08:55 04/12/2012 
// Design Name: 
// Module Name:    Modu_Block_ROM_Para 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Modu_Block_ROM_Para_P4(
//input
	clk,read_address,
	//output
	output_data	
	);
	parameter RAM_WIDTH = 24'b0;
   parameter RAM_ADDR_BITS = 10'b0;
	//input
	input clk;
	input [RAM_ADDR_BITS-1:0] read_address;
	//output
	output [RAM_WIDTH-1:0] output_data;
	
	reg [RAM_WIDTH-1:0] output_data;
	
	reg [RAM_WIDTH-1:0] ROM_reg [(2**RAM_ADDR_BITS)-1:0];
	
	initial 
	begin
		$readmemb("C:\\Users\\Xiaoshi\\Documents\\Graduate\\PCIe\\Turbo\\pcie_turbo_debug\\data\\Parameter_P4.txt",ROM_reg,0,564);//ROM_reg[0] = 0
	end
	
	always @(posedge clk)
	begin
		output_data <= ROM_reg[read_address];
	end
endmodule
