`timescale 1ns / 1ps
`include "Input_parameters.v"

module test_turbocrc;

	// input
	reg clk;
	reg reset;
	
	reg CRC_start, CRC_type;
	reg [7:0] D;
	reg [12:0] data_length;
	
	wire CRC_result, end_CRC;
	
	// generate clock
	always #5 clk = ~clk;
	
	// generate random data
	always @ (posedge clk)
		D <= $random % 256;
	
	Turbo_CRC24 turbo_crc24_inst(
		//input
		clk, ~reset, CRC_start, CRC_type, D, data_length,
		//output.1-->right, 0-->wrong
		D_addr, CRC_result, end_CRC
	);
	
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		CRC_start = 0;
		CRC_type = 1'b0;
		D = 0;
		data_length = 13'd816;
		
		// Wait 100 ns for global reset to finish
		#100;
		reset = 1'b0;
		#10;//2
		reset = 1'b1;
		#10;//2
		CRC_start = 1'b1;
		#10;//2
		CRC_start = 1'b0;	
	end
	
   

endmodule