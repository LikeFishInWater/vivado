`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_InputPara(//input
	clk,reset,Start_Cmp,
	CB_length,Parallel_degree,
	
	//output
	BLOCK_SIZE,window_size,Req_A_Init,Req_Rf_Init,Req_Qf_Init,Req_Rg_Init,Req_Qg_Init,
	Rf2,Qf2,r,q_up,start_decode
	);
	//input
	input clk;
	input reset;
	input Start_Cmp;
	input [12:0] CB_length;
	input [3:0] Parallel_degree;

	//output
	output [`Data_Addr_width-1:0] BLOCK_SIZE;
	output [`window_width:0] window_size;
	output [`Data_Addr_width-1:0] Req_A_Init;
	output [`Data_Addr_width-1:0] Req_Rf_Init;
	output [23:0] Req_Qf_Init;
	output [`Data_Addr_width-1:0] Req_Rg_Init;
	output [23:0] Req_Qg_Init;
	output [`Data_Addr_width-1:0] Rf2;
	output [2:0] Qf2;
	output [`window_width-1:0] r;
	output [3:0] q_up;
	output start_decode;
	
	reg [`Data_Addr_width-1:0] BLOCK_SIZE;
	reg [`window_width:0] window_size;
	reg [`Data_Addr_width-1:0] Req_A_Init;
	reg [`Data_Addr_width-1:0] Req_Rf_Init;
	reg [23:0] Req_Qf_Init;
	reg [`Data_Addr_width-1:0] Req_Rg_Init;
	reg [23:0] Req_Qg_Init;
	reg [`Data_Addr_width-1:0] Rf2;
	reg [2:0] Qf2;
	reg [`window_width-1:0] r;
	reg [3:0] q_up;
	reg start_decode;
	
	reg [2:0] Counter;
	reg [7:0] Add_ROM_temp;
	reg [9:0] Add_ROM;
	wire [23:0] ROM_out_data_P8;//parameters for parallel_degree = 8
	wire [23:0] ROM_out_data_P4;//parameters for parallel_degree = 4
	wire [3:0] CB_length_r9;
	wire [2:0] CB_length_r10;
	wire [1:0] CB_length_r11;
	
	assign CB_length_r9 = CB_length[12:9];
	assign CB_length_r10 = CB_length[12:10];
	assign CB_length_r11 = CB_length[12:11];
	
	Modu_Block_ROM_Para_P8 #(24,10) ROM_Para_P8(
	//input
	.clk(clk),.read_address(Add_ROM),
	//output
	.output_data(ROM_out_data_P8)
	);
	
	Modu_Block_ROM_Para_P4 #(24,10) ROM_Para_P4(
	//input
	.clk(clk),.read_address(Add_ROM),
	//output
	.output_data(ROM_out_data_P4)
	);
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Counter <= 3'b0;
		end
		else if(Start_Cmp == 1'b1)
		begin
			Counter <= 3'b001;
		end
		else 
		begin
			if(Counter == 3'b110)
			begin
				Counter <= 3'b0;
			end
			else if(Counter != 3'b0)
			begin
				Counter <= Counter + 1'b1;
			end
			else
			begin
				Counter <= Counter;
			end
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			start_decode <= 1'b0;
		end
		else if(Counter == 3'b110)
		begin
			start_decode <= 1'b1;
		end
		else
		begin
			start_decode <= 1'b0;
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Add_ROM_temp <= 8'b0;//the corresponding memory is 0
		end
		else if(Start_Cmp == 1'b1)
		begin
			if(CB_length_r11 != 2'b0)
			begin
				Add_ROM_temp <= {1'b0,CB_length[12:6]} + 8'b01011011;//92-1
			end
			else if(CB_length_r10 != 3'b0)
			begin
				Add_ROM_temp <= CB_length[12:5] + 7'b0111011;//60-1
			end
			else if(CB_length_r9 != 4'b0)
			begin
				Add_ROM_temp <= CB_length[11:4] + 6'b011011;
			end
			else
			begin
				Add_ROM_temp <= CB_length[10:3] + 8'b11111011;//-4-1
			end
		end
		else
		begin
			Add_ROM_temp <= Add_ROM_temp;
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Add_ROM <= 10'b0;
		end
		else if(Counter == 3'b001)
		begin
			Add_ROM <= {2'b00,Add_ROM_temp} + {2'b00,Add_ROM_temp} + {2'b00,Add_ROM_temp} + 10'b0000000001;
		end
		else if(Counter == 3'b010)
		begin
			Add_ROM <= {2'b00,Add_ROM_temp} + {2'b00,Add_ROM_temp} + {2'b00,Add_ROM_temp} + 10'b0000000010;
		end
		else if(Counter == 3'b011)
		begin
			Add_ROM <= {2'b00,Add_ROM_temp} + {2'b00,Add_ROM_temp} + {2'b00,Add_ROM_temp} + 10'b0000000011;
		end
		else
		begin
			Add_ROM <= 10'b0;
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset ==  1'b0)
		begin
			Req_A_Init <= 9'b0;
		end
		else if(Start_Cmp == 1'b1)
		begin
			Req_A_Init <= 9'b0;
		end
		else
		begin
			Req_A_Init <= Req_A_Init;
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Req_Rf_Init <= 10'b0;
		end
		else
		begin
			Req_Rf_Init <= 10'b0;
		end
	end

	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			BLOCK_SIZE <= 10'b0;
		end
		else if(Start_Cmp == 1'b1)
		begin
			if(Parallel_degree == 4'b0001)
			begin
				BLOCK_SIZE <= CB_length[9:0];
			end
			else if(Parallel_degree == 4'b0010)
			begin
				BLOCK_SIZE <= CB_length[10:1];
			end
			else if(Parallel_degree == 4'b0100)
			begin
				BLOCK_SIZE <= CB_length[11:2];
			end
			else
			begin
				BLOCK_SIZE <= CB_length[12:3];
			end
		end
		else
		begin
			BLOCK_SIZE <= BLOCK_SIZE;
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset ==  1'b0)
		begin
			window_size <= 7'b0;
		end
		else if(Start_Cmp == 1'b1)
		begin
			window_size <= 7'b1000000;
		end
		else
		begin
			window_size <= window_size;
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			r <= 6'b0;
		end
		else
		begin
			r <= BLOCK_SIZE[5:0];
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			q_up <= 4'b0;
		end
		else if(r == 6'b0)
		begin
			q_up <= BLOCK_SIZE[9:6];
		end
		else
		begin
			q_up <= {1'b0,BLOCK_SIZE[9:6]} + 2'b01;
		end
	end
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Req_Qf_Init <= 24'b0;
			Req_Rg_Init <= 10'b0;
			Req_Qg_Init <= 24'b0;
			Rf2 <= 10'b0;
			Qf2 <= 3'b0;
		end
		else if(Counter == 3'b011)
		begin
			Req_Rg_Init <= (Parallel_degree == 4'b1000) ? ROM_out_data_P8[9:0] : ROM_out_data_P4[9:0];
			Rf2 <= (Parallel_degree == 4'b1000) ? ROM_out_data_P8[19:10] : ROM_out_data_P4[19:10];
			Qf2 <= (Parallel_degree == 4'b1000) ? ROM_out_data_P8[22:20] : ROM_out_data_P4[22:20];
		end
		else if(Counter == 3'b100)
		begin
			Req_Qf_Init <= (Parallel_degree == 4'b1000) ? ROM_out_data_P8 : ROM_out_data_P4;
		end
		else if(Counter == 3'b101)
		begin
			Req_Qg_Init <= (Parallel_degree == 4'b1000) ? ROM_out_data_P8 : ROM_out_data_P4;
		end
		else
		begin
			Req_Qf_Init <= Req_Qf_Init;
			Req_Rg_Init <= Req_Rg_Init;
			Req_Qg_Init <= Req_Qg_Init;
			Rf2 <= Rf2;
			Qf2 <= Qf2;
		end
	end
endmodule
