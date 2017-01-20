`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/05/03 19:55:03
// Design Name: 
// Module Name: parallel_crc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module parallel_crc(
	data, crc, crc_type, crc_parallel, newcrc 
    );
    input [7:0] data;
    input [23:0] crc;
    input crc_type;
    input [4:0] crc_parallel;
    output [23:0] newcrc;
    
    
    wire [23:0] newcrc_D1_type0, newcrc_D2_type0, newcrc_D3_type0, newcrc_D4_type0, newcrc_D5_type0, newcrc_D6_type0, newcrc_D7_type0, newcrc_D8_type0;
    wire [23:0] newcrc_D1_type1, newcrc_D2_type1, newcrc_D3_type1, newcrc_D4_type1, newcrc_D5_type1, newcrc_D6_type1, newcrc_D7_type1, newcrc_D8_type1; 
    
    reg [23:0] newcrc;
    always @ (*)
    begin
    	if(crc_type == 1'b0)
    	begin
    		case(crc_parallel)
    			5'd1: newcrc = newcrc_D1_type0;
    			5'd2: newcrc = newcrc_D2_type0;
    			5'd3: newcrc = newcrc_D3_type0;
    			5'd4: newcrc = newcrc_D4_type0;
    			5'd5: newcrc = newcrc_D5_type0;
    			5'd6: newcrc = newcrc_D6_type0;
    			5'd7: newcrc = newcrc_D7_type0;
    			5'd8: newcrc = newcrc_D8_type0;
    		endcase
    	end
    	else
    	begin
    		case(crc_parallel)
    			5'd1: newcrc = newcrc_D1_type1;
    			5'd2: newcrc = newcrc_D2_type1;
    			5'd3: newcrc = newcrc_D3_type1;
    			5'd4: newcrc = newcrc_D4_type1;
    			5'd5: newcrc = newcrc_D5_type1;
    			5'd6: newcrc = newcrc_D6_type1;
    			5'd7: newcrc = newcrc_D7_type1;
    			5'd8: newcrc = newcrc_D8_type1;
    		endcase
    	end
    end
/*
	crc24_D1_type0 crc24_D1_type0_inst(data[0:0], crc, newcrc_D1_type0);
	crc24_D2_type0 crc24_D2_type0_inst(data[1:0], crc, newcrc_D2_type0);
	crc24_D3_type0 crc24_D3_type0_inst(data[2:0], crc, newcrc_D3_type0);
	crc24_D4_type0 crc24_D4_type0_inst(data[3:0], crc, newcrc_D4_type0);
	crc24_D5_type0 crc24_D5_type0_inst(data[4:0], crc, newcrc_D5_type0);
	crc24_D6_type0 crc24_D6_type0_inst(data[5:0], crc, newcrc_D6_type0);
	crc24_D7_type0 crc24_D7_type0_inst(data[6:0], crc, newcrc_D7_type0);
	crc24_D8_type0 crc24_D8_type0_inst(data[7:0], crc, newcrc_D8_type0);
*/
    
    wire [7:0] reverse_data;
    assign reverse_data[7] = data[0];
    assign reverse_data[6] = data[1];
    assign reverse_data[5] = data[2];
    assign reverse_data[4] = data[3];
    assign reverse_data[3] = data[4];
    assign reverse_data[2] = data[5];
    assign reverse_data[1] = data[6];
    assign reverse_data[0] = data[7];
    
    
	crc24_D1_type0 crc24_D1_type0_inst(reverse_data[7:7], crc, newcrc_D1_type0);
	crc24_D2_type0 crc24_D2_type0_inst(reverse_data[7:6], crc, newcrc_D2_type0);
	crc24_D3_type0 crc24_D3_type0_inst(reverse_data[7:5], crc, newcrc_D3_type0);
	crc24_D4_type0 crc24_D4_type0_inst(reverse_data[7:4], crc, newcrc_D4_type0);
	crc24_D5_type0 crc24_D5_type0_inst(reverse_data[7:3], crc, newcrc_D5_type0);
	crc24_D6_type0 crc24_D6_type0_inst(reverse_data[7:2], crc, newcrc_D6_type0);
	crc24_D7_type0 crc24_D7_type0_inst(reverse_data[7:1], crc, newcrc_D7_type0);
	crc24_D8_type0 crc24_D8_type0_inst(reverse_data[7:0], crc, newcrc_D8_type0);
	
	crc24_D1_type1 crc24_D1_type1_inst(reverse_data[7:7], crc, newcrc_D1_type1);
	crc24_D2_type1 crc24_D2_type1_inst(reverse_data[7:6], crc, newcrc_D2_type1);
	crc24_D3_type1 crc24_D3_type1_inst(reverse_data[7:5], crc, newcrc_D3_type1);
	crc24_D4_type1 crc24_D4_type1_inst(reverse_data[7:4], crc, newcrc_D4_type1);
	crc24_D5_type1 crc24_D5_type1_inst(reverse_data[7:3], crc, newcrc_D5_type1);
	crc24_D6_type1 crc24_D6_type1_inst(reverse_data[7:2], crc, newcrc_D6_type1);
	crc24_D7_type1 crc24_D7_type1_inst(reverse_data[7:1], crc, newcrc_D7_type1);
	crc24_D8_type1 crc24_D8_type1_inst(reverse_data[7:0], crc, newcrc_D8_type1);

endmodule

module crc24_D1_type0(d, c, newcrc);
	input [0:0] d;
	input [23:0] c;
	output [23:0] newcrc;
	
	assign newcrc[0] = d[0] ^ c[23];
	assign newcrc[1] = d[0] ^ c[0] ^ c[23];
	assign newcrc[2] = c[1];
	assign newcrc[3] = d[0] ^ c[2] ^ c[23];
	assign newcrc[4] = d[0] ^ c[3] ^ c[23];
	assign newcrc[5] = d[0] ^ c[4] ^ c[23];
	assign newcrc[6] = d[0] ^ c[5] ^ c[23];
	assign newcrc[7] = d[0] ^ c[6] ^ c[23];
	assign newcrc[8] = c[7];
	assign newcrc[9] = c[8];
	assign newcrc[10] = d[0] ^ c[9] ^ c[23];
	assign newcrc[11] = d[0] ^ c[10] ^ c[23];
	assign newcrc[12] = c[11];
	assign newcrc[13] = c[12];
	assign newcrc[14] = d[0] ^ c[13] ^ c[23];
	assign newcrc[15] = c[14];
	assign newcrc[16] = c[15];
	assign newcrc[17] = d[0] ^ c[16] ^ c[23];
	assign newcrc[18] = d[0] ^ c[17] ^ c[23];
	assign newcrc[19] = c[18];
	assign newcrc[20] = c[19];
	assign newcrc[21] = c[20];
	assign newcrc[22] = c[21];
	assign newcrc[23] = d[0] ^ c[22] ^ c[23];	
	
endmodule

module crc24_D2_type0(d, c, newcrc);
	input [1:0] d;
	input [23:0] c;
	output [23:0] newcrc;
    
	assign newcrc[0] = d[1] ^ d[0] ^ c[22] ^ c[23];
	assign newcrc[1] = d[0] ^ c[22];
	assign newcrc[2] = d[1] ^ c[0] ^ c[23];
	assign newcrc[3] = d[1] ^ d[0] ^ c[1] ^ c[22] ^ c[23];
	assign newcrc[4] = d[0] ^ c[2] ^ c[22];
	assign newcrc[5] = d[0] ^ c[3] ^ c[22];
	assign newcrc[6] = d[0] ^ c[4] ^ c[22];
	assign newcrc[7] = d[0] ^ c[5] ^ c[22];
	assign newcrc[8] = d[1] ^ c[6] ^ c[23];
	assign newcrc[9] = c[7];
	assign newcrc[10] = d[1] ^ d[0] ^ c[8] ^ c[22] ^ c[23];
	assign newcrc[11] = d[0] ^ c[9] ^ c[22];
	assign newcrc[12] = d[1] ^ c[10] ^ c[23];
	assign newcrc[13] = c[11];
	assign newcrc[14] = d[1] ^ d[0] ^ c[12] ^ c[22] ^ c[23];
	assign newcrc[15] = d[1] ^ c[13] ^ c[23];
	assign newcrc[16] = c[14];
	assign newcrc[17] = d[1] ^ d[0] ^ c[15] ^ c[22] ^ c[23];
	assign newcrc[18] = d[0] ^ c[16] ^ c[22];
	assign newcrc[19] = d[1] ^ c[17] ^ c[23];
	assign newcrc[20] = c[18];
	assign newcrc[21] = c[19];
	assign newcrc[22] = c[20];
	assign newcrc[23] = d[1] ^ d[0] ^ c[21] ^ c[22] ^ c[23];		
	
endmodule

module crc24_D3_type0(d, c, newcrc);
	input [2:0] d;
	input [23:0] c;
	output [23:0] newcrc;
    
	assign newcrc[0] = d[2] ^ d[1] ^ d[0] ^ c[21] ^ c[22] ^ c[23];
	assign newcrc[1] = d[0] ^ c[21];
	assign newcrc[2] = d[1] ^ c[22];
	assign newcrc[3] = d[1] ^ d[0] ^ c[0] ^ c[21] ^ c[22];
	assign newcrc[4] = d[0] ^ c[1] ^ c[21];
	assign newcrc[5] = d[2] ^ d[0] ^ c[2] ^ c[21] ^ c[23];
	assign newcrc[6] = d[2] ^ d[0] ^ c[3] ^ c[21] ^ c[23];
	assign newcrc[7] = d[2] ^ d[0] ^ c[4] ^ c[21] ^ c[23];
	assign newcrc[8] = d[1] ^ c[5] ^ c[22];
	assign newcrc[9] = d[2] ^ c[6] ^ c[23];
	assign newcrc[10] = d[2] ^ d[1] ^ d[0] ^ c[7] ^ c[21] ^ c[22] ^ c[23];
	assign newcrc[11] = d[0] ^ c[8] ^ c[21];
	assign newcrc[12] = d[1] ^ c[9] ^ c[22];
	assign newcrc[13] = d[2] ^ c[10] ^ c[23];
	assign newcrc[14] = d[2] ^ d[1] ^ d[0] ^ c[11] ^ c[21] ^ c[22] ^ c[23];
	assign newcrc[15] = d[2] ^ d[1] ^ c[12] ^ c[22] ^ c[23];
	assign newcrc[16] = d[2] ^ c[13] ^ c[23];
	assign newcrc[17] = d[2] ^ d[1] ^ d[0] ^ c[14] ^ c[21] ^ c[22] ^ c[23];
	assign newcrc[18] = d[0] ^ c[15] ^ c[21];
	assign newcrc[19] = d[1] ^ c[16] ^ c[22];
	assign newcrc[20] = d[2] ^ c[17] ^ c[23];
	assign newcrc[21] = c[18];
	assign newcrc[22] = c[19];
	assign newcrc[23] = d[2] ^ d[1] ^ d[0] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
		
endmodule

module crc24_D4_type0(d, c, newcrc);
	input [3:0] d;
	input [23:0] c;
	output [23:0] newcrc;

	assign newcrc[0] = d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
	assign newcrc[1] = d[0] ^ c[20];
	assign newcrc[2] = d[1] ^ c[21];
	assign newcrc[3] = d[3] ^ d[1] ^ d[0] ^ c[20] ^ c[21] ^ c[23];
	assign newcrc[4] = d[3] ^ d[0] ^ c[0] ^ c[20] ^ c[23];
	assign newcrc[5] = d[3] ^ d[2] ^ d[0] ^ c[1] ^ c[20] ^ c[22] ^ c[23];
	assign newcrc[6] = d[2] ^ d[0] ^ c[2] ^ c[20] ^ c[22];
	assign newcrc[7] = d[2] ^ d[0] ^ c[3] ^ c[20] ^ c[22];
	assign newcrc[8] = d[3] ^ d[1] ^ c[4] ^ c[21] ^ c[23];
	assign newcrc[9] = d[2] ^ c[5] ^ c[22];
 	assign newcrc[10] = d[2] ^ d[1] ^ d[0] ^ c[6] ^ c[20] ^ c[21] ^ c[22];
	assign newcrc[11] = d[0] ^ c[7] ^ c[20];
	assign newcrc[12] = d[1] ^ c[8] ^ c[21];
	assign newcrc[13] = d[2] ^ c[9] ^ c[22];
	assign newcrc[14] = d[2] ^ d[1] ^ d[0] ^ c[10] ^ c[20] ^ c[21] ^ c[22];
	assign newcrc[15] = d[3] ^ d[2] ^ d[1] ^ c[11] ^ c[21] ^ c[22] ^ c[23];
	assign newcrc[16] = d[3] ^ d[2] ^ c[12] ^ c[22] ^ c[23];
	assign newcrc[17] = d[2] ^ d[1] ^ d[0] ^ c[13] ^ c[20] ^ c[21] ^ c[22];
	assign newcrc[18] = d[0] ^ c[14] ^ c[20];
	assign newcrc[19] = d[1] ^ c[15] ^ c[21];
	assign newcrc[20] = d[2] ^ c[16] ^ c[22];
	assign newcrc[21] = d[3] ^ c[17] ^ c[23];
	assign newcrc[22] = c[18];
	assign newcrc[23] = d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[19] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
	
endmodule

module crc24_D5_type0(d, c, newcrc);
	input [4:0] d;
	input [23:0] c;
	output [23:0] newcrc;

	assign newcrc[0] = d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[19] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
	assign newcrc[1] = d[0] ^ c[19];
	assign newcrc[2] = d[1] ^ c[20];
	assign newcrc[3] = d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[19] ^ c[20] ^ c[22] ^ c[23];
	assign newcrc[4] = d[3] ^ d[0] ^ c[19] ^ c[22];
	assign newcrc[5] = d[3] ^ d[2] ^ d[0] ^ c[0] ^ c[19] ^ c[21] ^ c[22];
	assign newcrc[6] = d[2] ^ d[0] ^ c[1] ^ c[19] ^ c[21];
	assign newcrc[7] = d[4] ^ d[2] ^ d[0] ^ c[2] ^ c[19] ^ c[21] ^ c[23];
	assign newcrc[8] = d[3] ^ d[1] ^ c[3] ^ c[20] ^ c[22];
	assign newcrc[9] = d[4] ^ d[2] ^ c[4] ^ c[21] ^ c[23];
	assign newcrc[10] = d[4] ^ d[2] ^ d[1] ^ d[0] ^ c[5] ^ c[19] ^ c[20] ^ c[21] ^ c[23];
	assign newcrc[11] = d[4] ^ d[0] ^ c[6] ^ c[19] ^ c[23];
	assign newcrc[12] = d[1] ^ c[7] ^ c[20];
	assign newcrc[13] = d[2] ^ c[8] ^ c[21];
	assign newcrc[14] = d[4] ^ d[2] ^ d[1] ^ d[0] ^ c[9] ^ c[19] ^ c[20] ^ c[21] ^ c[23];
	assign newcrc[15] = d[3] ^ d[2] ^ d[1] ^ c[10] ^ c[20] ^ c[21] ^ c[22];
	assign newcrc[16] = d[4] ^ d[3] ^ d[2] ^ c[11] ^ c[21] ^ c[22] ^ c[23];
	assign newcrc[17] = d[2] ^ d[1] ^ d[0] ^ c[12] ^ c[19] ^ c[20] ^ c[21];
	assign newcrc[18] = d[4] ^ d[0] ^ c[13] ^ c[19] ^ c[23];
	assign newcrc[19] = d[1] ^ c[14] ^ c[20];
	assign newcrc[20] = d[2] ^ c[15] ^ c[21];
	assign newcrc[21] = d[3] ^ c[16] ^ c[22];
	assign newcrc[22] = d[4] ^ c[17] ^ c[23];
	assign newcrc[23] = d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[18] ^ c[19] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
		
endmodule

module crc24_D6_type0(d, c, newcrc);
	input [5:0] d;
	input [23:0] c;
	output [23:0] newcrc;

	assign newcrc[0] = d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[18] ^ c[19] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
	assign newcrc[1] = d[0] ^ c[18];
	assign newcrc[2] = d[1] ^ c[19];
	assign newcrc[3] = d[5] ^ d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[18] ^ c[19] ^ c[21] ^ c[22] ^ c[23];
	assign newcrc[4] = d[3] ^ d[0] ^ c[18] ^ c[21];
	assign newcrc[5] = d[5] ^ d[3] ^ d[2] ^ d[0] ^ c[18] ^ c[20] ^ c[21] ^ c[23];
	assign newcrc[6] = d[5] ^ d[2] ^ d[0] ^ c[0] ^ c[18] ^ c[20] ^ c[23];
	assign newcrc[7] = d[5] ^ d[4] ^ d[2] ^ d[0] ^ c[1] ^ c[18] ^ c[20] ^ c[22] ^ c[23];
	assign newcrc[8] = d[5] ^ d[3] ^ d[1] ^ c[2] ^ c[19] ^ c[21] ^ c[23];
	assign newcrc[9] = d[4] ^ d[2] ^ c[3] ^ c[20] ^ c[22];
	assign newcrc[10] = d[4] ^ d[2] ^ d[1] ^ d[0] ^ c[4] ^ c[18] ^ c[19] ^ c[20] ^ c[22];
	assign newcrc[11] = d[4] ^ d[0] ^ c[5] ^ c[18] ^ c[22];
	assign newcrc[12] = d[5] ^ d[1] ^ c[6] ^ c[19] ^ c[23];
	assign newcrc[13] = d[2] ^ c[7] ^ c[20];
	assign newcrc[14] = d[5] ^ d[4] ^ d[2] ^ d[1] ^ d[0] ^ c[8] ^ c[18] ^ c[19] ^ c[20] ^ c[22] ^ c[23];
	assign newcrc[15] = d[5] ^ d[3] ^ d[2] ^ d[1] ^ c[9] ^ c[19] ^ c[20] ^ c[21] ^ c[23];
	assign newcrc[16] = d[4] ^ d[3] ^ d[2] ^ c[10] ^ c[20] ^ c[21] ^ c[22];
	assign newcrc[17] = d[2] ^ d[1] ^ d[0] ^ c[11] ^ c[18] ^ c[19] ^ c[20];
	assign newcrc[18] = d[5] ^ d[4] ^ d[0] ^ c[12] ^ c[18] ^ c[22] ^ c[23];
	assign newcrc[19] = d[5] ^ d[1] ^ c[13] ^ c[19] ^ c[23];
	assign newcrc[20] = d[2] ^ c[14] ^ c[20];
	assign newcrc[21] = d[3] ^ c[15] ^ c[21];
	assign newcrc[22] = d[4] ^ c[16] ^ c[22];
	assign newcrc[23] = d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[17] ^ c[18] ^ c[19] ^ c[20] ^ c[21] ^ c[22];
		
endmodule

module crc24_D7_type0(d, c, newcrc);
	input [6:0] d;
	input [23:0] c;
	output [23:0] newcrc;

	assign newcrc[0] = d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[17] ^ c[18] ^ c[19] ^ c[20] ^ c[21] ^ c[22];
    assign newcrc[1] = d[6] ^ d[0] ^ c[17] ^ c[23];
    assign newcrc[2] = d[1] ^ c[18];
    assign newcrc[3] = d[5] ^ d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[17] ^ c[18] ^ c[20] ^ c[21] ^ c[22];
    assign newcrc[4] = d[6] ^ d[3] ^ d[0] ^ c[17] ^ c[20] ^ c[23];
    assign newcrc[5] = d[5] ^ d[3] ^ d[2] ^ d[0] ^ c[17] ^ c[19] ^ c[20] ^ c[22];
    assign newcrc[6] = d[6] ^ d[5] ^ d[2] ^ d[0] ^ c[17] ^ c[19] ^ c[22] ^ c[23];
    assign newcrc[7] = d[6] ^ d[5] ^ d[4] ^ d[2] ^ d[0] ^ c[0] ^ c[17] ^ c[19] ^ c[21] ^ c[22] ^ c[23];
    assign newcrc[8] = d[6] ^ d[5] ^ d[3] ^ d[1] ^ c[1] ^ c[18] ^ c[20] ^ c[22] ^ c[23];
    assign newcrc[9] = d[6] ^ d[4] ^ d[2] ^ c[2] ^ c[19] ^ c[21] ^ c[23];
    assign newcrc[10] = d[4] ^ d[2] ^ d[1] ^ d[0] ^ c[3] ^ c[17] ^ c[18] ^ c[19] ^ c[21];
    assign newcrc[11] = d[4] ^ d[0] ^ c[4] ^ c[17] ^ c[21];
    assign newcrc[12] = d[5] ^ d[1] ^ c[5] ^ c[18] ^ c[22];
    assign newcrc[13] = d[6] ^ d[2] ^ c[6] ^ c[19] ^ c[23];
    assign newcrc[14] = d[5] ^ d[4] ^ d[2] ^ d[1] ^ d[0] ^ c[7] ^ c[17] ^ c[18] ^ c[19] ^ c[21] ^ c[22];
    assign newcrc[15] = d[6] ^ d[5] ^ d[3] ^ d[2] ^ d[1] ^ c[8] ^ c[18] ^ c[19] ^ c[20] ^ c[22] ^ c[23];
    assign newcrc[16] = d[6] ^ d[4] ^ d[3] ^ d[2] ^ c[9] ^ c[19] ^ c[20] ^ c[21] ^ c[23];
    assign newcrc[17] = d[2] ^ d[1] ^ d[0] ^ c[10] ^ c[17] ^ c[18] ^ c[19];
    assign newcrc[18] = d[5] ^ d[4] ^ d[0] ^ c[11] ^ c[17] ^ c[21] ^ c[22];
    assign newcrc[19] = d[6] ^ d[5] ^ d[1] ^ c[12] ^ c[18] ^ c[22] ^ c[23];
    assign newcrc[20] = d[6] ^ d[2] ^ c[13] ^ c[19] ^ c[23];
    assign newcrc[21] = d[3] ^ c[14] ^ c[20];
    assign newcrc[22] = d[4] ^ c[15] ^ c[21];
    assign newcrc[23] = d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[16] ^ c[17] ^ c[18] ^ c[19] ^ c[20] ^ c[21];
		
endmodule

module crc24_D8_type0(d, c, newcrc);
	input [7:0] d;
	input [23:0] c;
	output [23:0] newcrc;

    assign newcrc[0] = d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[16] ^ c[17] ^ c[18] ^ c[19] ^ c[20] ^ c[21];
    assign newcrc[1] = d[6] ^ d[0] ^ c[16] ^ c[22];
    assign newcrc[2] = d[7] ^ d[1] ^ c[17] ^ c[23];
    assign newcrc[3] = d[5] ^ d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[16] ^ c[17] ^ c[19] ^ c[20] ^ c[21];
    assign newcrc[4] = d[6] ^ d[3] ^ d[0] ^ c[16] ^ c[19] ^ c[22];
    assign newcrc[5] = d[7] ^ d[5] ^ d[3] ^ d[2] ^ d[0] ^ c[16] ^ c[18] ^ c[19] ^ c[21] ^ c[23];
    assign newcrc[6] = d[6] ^ d[5] ^ d[2] ^ d[0] ^ c[16] ^ c[18] ^ c[21] ^ c[22];
    assign newcrc[7] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[2] ^ d[0] ^ c[16] ^ c[18] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
    assign newcrc[8] = d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[1] ^ c[0] ^ c[17] ^ c[19] ^ c[21] ^ c[22] ^ c[23];
    assign newcrc[9] = d[7] ^ d[6] ^ d[4] ^ d[2] ^ c[1] ^ c[18] ^ c[20] ^ c[22] ^ c[23];
    assign newcrc[10] = d[7] ^ d[4] ^ d[2] ^ d[1] ^ d[0] ^ c[2] ^ c[16] ^ c[17] ^ c[18] ^ c[20] ^ c[23];
    assign newcrc[11] = d[4] ^ d[0] ^ c[3] ^ c[16] ^ c[20];
    assign newcrc[12] = d[5] ^ d[1] ^ c[4] ^ c[17] ^ c[21];
    assign newcrc[13] = d[6] ^ d[2] ^ c[5] ^ c[18] ^ c[22];
    assign newcrc[14] = d[7] ^ d[5] ^ d[4] ^ d[2] ^ d[1] ^ d[0] ^ c[6] ^ c[16] ^ c[17] ^ c[18] ^ c[20] ^ c[21] ^ c[23];
    assign newcrc[15] = d[6] ^ d[5] ^ d[3] ^ d[2] ^ d[1] ^ c[7] ^ c[17] ^ c[18] ^ c[19] ^ c[21] ^ c[22];
    assign newcrc[16] = d[7] ^ d[6] ^ d[4] ^ d[3] ^ d[2] ^ c[8] ^ c[18] ^ c[19] ^ c[20] ^ c[22] ^ c[23];
    assign newcrc[17] = d[7] ^ d[2] ^ d[1] ^ d[0] ^ c[9] ^ c[16] ^ c[17] ^ c[18] ^ c[23];
    assign newcrc[18] = d[5] ^ d[4] ^ d[0] ^ c[10] ^ c[16] ^ c[20] ^ c[21];
    assign newcrc[19] = d[6] ^ d[5] ^ d[1] ^ c[11] ^ c[17] ^ c[21] ^ c[22];
    assign newcrc[20] = d[7] ^ d[6] ^ d[2] ^ c[12] ^ c[18] ^ c[22] ^ c[23];
    assign newcrc[21] = d[7] ^ d[3] ^ c[13] ^ c[19] ^ c[23];
    assign newcrc[22] = d[4] ^ c[14] ^ c[20];
    assign newcrc[23] = d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[15] ^ c[16] ^ c[17] ^ c[18] ^ c[19] ^ c[20];
		
endmodule

module crc24_D1_type1(d, c, newcrc);
	input [0:0] d;
	input [23:0] c;
	output [23:0] newcrc;
	
    assign newcrc[0] = d[0] ^ c[23];
	assign newcrc[1] = d[0] ^ c[0] ^ c[23];
	assign newcrc[2] = c[1];
	assign newcrc[3] = c[2];
	assign newcrc[4] = c[3];
	assign newcrc[5] = d[0] ^ c[4] ^ c[23];
	assign newcrc[6] = d[0] ^ c[5] ^ c[23];
	assign newcrc[7] = c[6];
	assign newcrc[8] = c[7];
	assign newcrc[9] = c[8];
	assign newcrc[10] = c[9];
	assign newcrc[11] = c[10];
	assign newcrc[12] = c[11];
	assign newcrc[13] = c[12];
	assign newcrc[14] = c[13];
	assign newcrc[15] = c[14];
	assign newcrc[16] = c[15];
	assign newcrc[17] = c[16];
	assign newcrc[18] = c[17];
	assign newcrc[19] = c[18];
	assign newcrc[20] = c[19];
	assign newcrc[21] = c[20];
	assign newcrc[22] = c[21];
	assign newcrc[23] = d[0] ^ c[22] ^ c[23];
	
endmodule

module crc24_D2_type1(d, c, newcrc);
	input [1:0] d;
	input [23:0] c;
	output [23:0] newcrc;
    
    assign newcrc[0] = d[1] ^ d[0] ^ c[22] ^ c[23];
	assign newcrc[1] = d[0] ^ c[22];
	assign newcrc[2] = d[1] ^ c[0] ^ c[23];
	assign newcrc[3] = c[1];
	assign newcrc[4] = c[2];
	assign newcrc[5] = d[1] ^ d[0] ^ c[3] ^ c[22] ^ c[23];
	assign newcrc[6] = d[0] ^ c[4] ^ c[22];
	assign newcrc[7] = d[1] ^ c[5] ^ c[23];
	assign newcrc[8] = c[6];
	assign newcrc[9] = c[7];
	assign newcrc[10] = c[8];
	assign newcrc[11] = c[9];
	assign newcrc[12] = c[10];
	assign newcrc[13] = c[11];
	assign newcrc[14] = c[12];
	assign newcrc[15] = c[13];
	assign newcrc[16] = c[14];
	assign newcrc[17] = c[15];
	assign newcrc[18] = c[16];
	assign newcrc[19] = c[17];
	assign newcrc[20] = c[18];
	assign newcrc[21] = c[19];
	assign newcrc[22] = c[20];
	assign newcrc[23] = d[1] ^ d[0] ^ c[21] ^ c[22] ^ c[23];	
	
endmodule

module crc24_D3_type1(d, c, newcrc);
	input [2:0] d;
	input [23:0] c;
	output [23:0] newcrc;
    
    assign newcrc[0] = d[2] ^ d[1] ^ d[0] ^ c[21] ^ c[22] ^ c[23];
	assign newcrc[1] = d[0] ^ c[21];
	assign newcrc[2] = d[1] ^ c[22];
	assign newcrc[3] = d[2] ^ c[0] ^ c[23];
	assign newcrc[4] = c[1];
	assign newcrc[5] = d[2] ^ d[1] ^ d[0] ^ c[2] ^ c[21] ^ c[22] ^ c[23];
	assign newcrc[6] = d[0] ^ c[3] ^ c[21];
	assign newcrc[7] = d[1] ^ c[4] ^ c[22];
	assign newcrc[8] = d[2] ^ c[5] ^ c[23];
	assign newcrc[9] = c[6];
	assign newcrc[10] = c[7];
	assign newcrc[11] = c[8];
	assign newcrc[12] = c[9];
	assign newcrc[13] = c[10];
	assign newcrc[14] = c[11];
	assign newcrc[15] = c[12];
	assign newcrc[16] = c[13];
	assign newcrc[17] = c[14];
	assign newcrc[18] = c[15];
	assign newcrc[19] = c[16];
	assign newcrc[20] = c[17];
	assign newcrc[21] = c[18];
	assign newcrc[22] = c[19];
	assign newcrc[23] = d[2] ^ d[1] ^ d[0] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
		
endmodule

module crc24_D4_type1(d, c, newcrc);
	input [3:0] d;
	input [23:0] c;
	output [23:0] newcrc;

    assign newcrc[0] = d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
    assign newcrc[1] = d[0] ^ c[20];
    assign newcrc[2] = d[1] ^ c[21];
    assign newcrc[3] = d[2] ^ c[22];
    assign newcrc[4] = d[3] ^ c[0] ^ c[23];
    assign newcrc[5] = d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[1] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
    assign newcrc[6] = d[0] ^ c[2] ^ c[20];
    assign newcrc[7] = d[1] ^ c[3] ^ c[21];
    assign newcrc[8] = d[2] ^ c[4] ^ c[22];
    assign newcrc[9] = d[3] ^ c[5] ^ c[23];
    assign newcrc[10] = c[6];
    assign newcrc[11] = c[7];
    assign newcrc[12] = c[8];
    assign newcrc[13] = c[9];
    assign newcrc[14] = c[10];
    assign newcrc[15] = c[11];
    assign newcrc[16] = c[12];
    assign newcrc[17] = c[13];
    assign newcrc[18] = c[14];
    assign newcrc[19] = c[15];
    assign newcrc[20] = c[16];
    assign newcrc[21] = c[17];
    assign newcrc[22] = c[18];
    assign newcrc[23] = d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[19] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
	
endmodule

module crc24_D5_type1(d, c, newcrc);
	input [4:0] d;
	input [23:0] c;
	output [23:0] newcrc;

    assign newcrc[0] = d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[19] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
    assign newcrc[1] = d[0] ^ c[19];
    assign newcrc[2] = d[1] ^ c[20];
    assign newcrc[3] = d[2] ^ c[21];
    assign newcrc[4] = d[3] ^ c[22];
    assign newcrc[5] = d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[0] ^ c[19] ^ c[20] ^ c[21] ^ c[22];
    assign newcrc[6] = d[0] ^ c[1] ^ c[19];
    assign newcrc[7] = d[1] ^ c[2] ^ c[20];
    assign newcrc[8] = d[2] ^ c[3] ^ c[21];
    assign newcrc[9] = d[3] ^ c[4] ^ c[22];
    assign newcrc[10] = d[4] ^ c[5] ^ c[23];
    assign newcrc[11] = c[6];
    assign newcrc[12] = c[7];
    assign newcrc[13] = c[8];
    assign newcrc[14] = c[9];
    assign newcrc[15] = c[10];
    assign newcrc[16] = c[11];
    assign newcrc[17] = c[12];
    assign newcrc[18] = c[13];
    assign newcrc[19] = c[14];
    assign newcrc[20] = c[15];
    assign newcrc[21] = c[16];
    assign newcrc[22] = c[17];
    assign newcrc[23] = d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[18] ^ c[19] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
		
endmodule

module crc24_D6_type1(d, c, newcrc);
	input [5:0] d;
	input [23:0] c;
	output [23:0] newcrc;

    assign newcrc[0] = d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[18] ^ c[19] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
    assign newcrc[1] = d[0] ^ c[18];
    assign newcrc[2] = d[1] ^ c[19];
    assign newcrc[3] = d[2] ^ c[20];
    assign newcrc[4] = d[3] ^ c[21];
    assign newcrc[5] = d[5] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[18] ^ c[19] ^ c[20] ^ c[21] ^ c[23];
    assign newcrc[6] = d[5] ^ d[0] ^ c[0] ^ c[18] ^ c[23];
    assign newcrc[7] = d[1] ^ c[1] ^ c[19];
    assign newcrc[8] = d[2] ^ c[2] ^ c[20];
    assign newcrc[9] = d[3] ^ c[3] ^ c[21];
    assign newcrc[10] = d[4] ^ c[4] ^ c[22];
    assign newcrc[11] = d[5] ^ c[5] ^ c[23];
    assign newcrc[12] = c[6];
    assign newcrc[13] = c[7];
    assign newcrc[14] = c[8];
    assign newcrc[15] = c[9];
    assign newcrc[16] = c[10];
    assign newcrc[17] = c[11];
    assign newcrc[18] = c[12];
    assign newcrc[19] = c[13];
    assign newcrc[20] = c[14];
    assign newcrc[21] = c[15];
    assign newcrc[22] = c[16];
    assign newcrc[23] = d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[17] ^ c[18] ^ c[19] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
		
endmodule

module crc24_D7_type1(d, c, newcrc);
	input [6:0] d;
	input [23:0] c;
	output [23:0] newcrc;

    assign newcrc[0] = d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[17] ^ c[18] ^ c[19] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
    assign newcrc[1] = d[0] ^ c[17];
    assign newcrc[2] = d[1] ^ c[18];
    assign newcrc[3] = d[2] ^ c[19];
    assign newcrc[4] = d[3] ^ c[20];
    assign newcrc[5] = d[6] ^ d[5] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[17] ^ c[18] ^ c[19] ^ c[20] ^ c[22] ^ c[23];
    assign newcrc[6] = d[5] ^ d[0] ^ c[17] ^ c[22];
    assign newcrc[7] = d[6] ^ d[1] ^ c[0] ^ c[18] ^ c[23];
    assign newcrc[8] = d[2] ^ c[1] ^ c[19];
    assign newcrc[9] = d[3] ^ c[2] ^ c[20];
    assign newcrc[10] = d[4] ^ c[3] ^ c[21];
    assign newcrc[11] = d[5] ^ c[4] ^ c[22];
    assign newcrc[12] = d[6] ^ c[5] ^ c[23];
    assign newcrc[13] = c[6];
    assign newcrc[14] = c[7];
    assign newcrc[15] = c[8];
    assign newcrc[16] = c[9];
    assign newcrc[17] = c[10];
    assign newcrc[18] = c[11];
    assign newcrc[19] = c[12];
    assign newcrc[20] = c[13];
    assign newcrc[21] = c[14];
    assign newcrc[22] = c[15];
    assign newcrc[23] = d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[16] ^ c[17] ^ c[18] ^ c[19] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
		
endmodule

module crc24_D8_type1(d, c, newcrc);
	input [7:0] d;
	input [23:0] c;
	output [23:0] newcrc;

    assign newcrc[0] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[16] ^ c[17] ^ c[18] ^ c[19] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
	assign newcrc[1] = d[0] ^ c[16];
	assign newcrc[2] = d[1] ^ c[17];
	assign newcrc[3] = d[2] ^ c[18];
	assign newcrc[4] = d[3] ^ c[19];
	assign newcrc[5] = d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[16] ^ c[17] ^ c[18] ^ c[19] ^ c[21] ^ c[22] ^ c[23];
	assign newcrc[6] = d[5] ^ d[0] ^ c[16] ^ c[21];
	assign newcrc[7] = d[6] ^ d[1] ^ c[17] ^ c[22];
	assign newcrc[8] = d[7] ^ d[2] ^ c[0] ^ c[18] ^ c[23];
	assign newcrc[9] = d[3] ^ c[1] ^ c[19];
	assign newcrc[10] = d[4] ^ c[2] ^ c[20];
	assign newcrc[11] = d[5] ^ c[3] ^ c[21];
	assign newcrc[12] = d[6] ^ c[4] ^ c[22];
	assign newcrc[13] = d[7] ^ c[5] ^ c[23];
	assign newcrc[14] = c[6];
	assign newcrc[15] = c[7];
	assign newcrc[16] = c[8];
	assign newcrc[17] = c[9];
	assign newcrc[18] = c[10];
	assign newcrc[19] = c[11];
	assign newcrc[20] = c[12];
	assign newcrc[21] = c[13];
	assign newcrc[22] = c[14];
	assign newcrc[23] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[15] ^ c[16] ^ c[17] ^ c[18] ^ c[19] ^ c[20] ^ c[21] ^ c[22] ^ c[23];
		
endmodule