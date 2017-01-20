`timescale 1ns / 1ps
`include "Input_parameters.v"

module test_final;

	//input
	reg clk;
	reg reset;
	reg Start_Cmp;
	reg [12:0] CB_length;
	reg [3:0] Parallel_degree;
	reg [3:0] Iter_Max;
	reg CRC_type;

	// Outputs
	wire [7:0] D;
	wire [`Le_sys_par_width*8-1:0] Le_sys;
	wire [`Le_sys_par_width*8-1:0] Le_par0;
	wire [`Le_sys_par_width*8-1:0] Le_par1;
	wire CRC_result;
	wire End_CB;
	
	
	// system ,parity & tail ram, read out
	wire [`Data_Addr_width-1:0] read_addr_system;
	wire [`sys_par_width*8-1:0] system_out_ram;
	Modu_Block_Dual_RAM_sys #((`sys_par_width*8),(`Data_Addr_width)) System_RAM(.clk(clk),	
		.write_enable(0),.write_address(),.input_data(),				//write port
		.read_address(read_addr_system),.output_data(system_out_ram)	//read port
	);
	
	wire [`Data_Addr_width-1:0] read_addr_parity;
	wire [`sys_par_width*8-1:0] parity0_out_ram, parity1_out_ram;
	Modu_Block_Dual_RAM_par0 #((`sys_par_width*8),(`Data_Addr_width)) Parity0_RAM(.clk(clk),	
		.write_enable(0),.write_address(),.input_data(),				//write port
		.read_address(read_addr_parity),.output_data(parity0_out_ram)	//read port
	);
	Modu_Block_Dual_RAM_par1 #((`sys_par_width*8),(`Data_Addr_width)) Parity1_RAM(.clk(clk),	
		.write_enable(0),.write_address(),.input_data(),				//write port
		.read_address(read_addr_parity),.output_data(parity1_out_ram)	//read port
	);
	
	wire [2:0] read_addr_tail;
	wire [`sys_par_width*2-1:0] tail_out_ram;
	Modu_Distributed_Dual_RAM_tail #((`sys_par_width*2),3) TailBit_RAM(.clk(clk),
		.write_address(),.write_enable(0),.input_data(),
		.read_address(read_addr_tail),.output_data(tail_out_ram)
	);
	
	// Instantiate the Unit Under Test (UUT)
	wire [`Data_Addr_width-1:0] D_addr;
	wire crc_start;
	Modu_Decoder_New_CRC uut(
//	Modu_Decoder uut(
		.clk(clk), 
		.reset(reset), 
		.Start_Cmp(Start_Cmp),
		.CB_length(CB_length),
		.Parallel_degree(4'd8),
		.Iter_Max(Iter_Max),
		.CRC_type(CRC_type),
		.System_In_ROM(system_out_ram),
		.Parity0_In_ROM(parity0_out_ram),
		.Parity1_In_ROM(parity1_out_ram),
		.Tail_In_ROM(tail_out_ram),
		// output
		.Read_Addr_system(read_addr_system),
		.Read_Addr_parity(read_addr_parity),
		.Read_Addr_tail(read_addr_tail),
		
		// output revised by shaxiaoshi
		.CRC_result(CRC_result),
		.Decode_Result_Start(Decode_Result_Start),
		.Decode_Result_Addr(Decode_Result_Addr),
		.Decode_result_D(Decode_result_D),
		.End_Decode(End_CB)
	);


	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		Start_Cmp = 0;
		CB_length = 13'd6144;
		Parallel_degree = 4'd8;
		Iter_Max = 4'd8;
		CRC_type = 1'b0;

		// Wait 100 ns for global reset to finish
		#100;
		reset = 1'b0;
		#10;//2
		reset = 1'b1;
		#10;//2
		Start_Cmp = 1'b1;
		#10;//2
		Start_Cmp = 1'b0;
		#40005
		reset = 1'b0;
		#20
		reset = 1'b1;
		#10
		Start_Cmp = 1'b1;
		#10;//2
		Start_Cmp = 1'b0;
		// Add stimulus here

	end
	
   always #5 clk = ~clk;

endmodule

