`timescale 1ns / 1ps
`include "Input_parameters.v"

module Turbo_CRC24(
	//input
	clk, reset, CRC_start, CRC_type, D, data_length,
	restore_D_addr,
	//output.1-->right, 0-->wrong
	D_addr, CRC_result,end_CRC,
	blk_mem_dout
);

input clk, reset, CRC_start, CRC_type;
input [12:0] data_length;
input [7:0] D;
input [6:0] restore_D_addr;
output [9:0] D_addr;
output CRC_result, end_CRC;
output [63:0] blk_mem_dout;

parameter idle = 4'd0, wr_d = 4'd1, cal_crc = 4'd2, checksum = 4'd3;
reg [3:0] state;
reg [9:0] count;
reg [2:0] cnt_col;
wire [2:0] remain_len;
wire [9:0] sub_dec_len;
assign sub_dec_len = data_length >> 3;
assign remain_len = sub_dec_len[2:0];

/*
wire D_0, D_1, D_2, D_3, D_4, D_5, D_6, D_7;
assign D_0 = D[0];
assign D_1 = D[1];
assign D_2 = D[2];
assign D_3 = D[3];
assign D_4 = D[4];
assign D_5 = D[5];
assign D_6 = D[6];
assign D_7 = D[7];
*/

reg wr_crc_mem;
always @ (posedge clk)
begin
	wr_crc_mem <= (state == wr_d);
end

assign D_addr = count;
reg [9:0] wr_crc_addr;
always @ (posedge clk)
begin
	wr_crc_addr <= count;
end

wire rd_crc_mem;
assign rd_crc_mem = (state == cal_crc) || (state == checksum);

wire [6:0] rd_crc_addr;
assign rd_crc_addr = (state == cal_crc) ?  count : restore_D_addr;

always @ (posedge clk)
begin
	if(reset)
	begin
		count <= 0;
		cnt_col <= 0;
	end
	else
	begin
		if(state == wr_d)
		begin
			cnt_col <= 0;
			if(count == sub_dec_len - 1)
				count <= 0;
			else
				count <= count + 1;
		end
		else if(state == cal_crc)
		begin
			if(remain_len == 0)
			begin
				if(count == ((sub_dec_len >> 3) - 1))
				begin
					count <= 0;
					cnt_col <= cnt_col + 1;
				end
				else
					count <= count + 1;
			end
			else
			begin
				if(count == (sub_dec_len >> 3))
				begin
					count <= 0;
					cnt_col <= cnt_col + 1;
				end
				else
					count <= count + 1;
			end
		end
	end
end


always @ (posedge clk)
begin
	if(reset == 1'b1)
	begin
		state <= idle;
	end	
	else
	begin
		case(state)
			idle:
				if(CRC_start)
					state <= wr_d;
				else
					state <= idle;
			wr_d:
				if(count == sub_dec_len - 1)
					state <= cal_crc;
				else
					state <= wr_d;
			cal_crc:
				if(cnt_col == 3'd7  && ((remain_len == 0 && count == ((sub_dec_len >> 3) - 1)) || (remain_len != 0 && count == (sub_dec_len >> 3))  ) )
					state <= checksum;
				else
					state <= cal_crc;
			checksum:
				if(CRC_start)
					state <= wr_d;
				else
					state <= checksum;
		endcase
	end
end

reg [4:0] crc_parallel;
always @ (posedge clk)
begin
	if(remain_len == 0)
		crc_parallel <= 5'd8;
	else
	begin
		if(count == sub_dec_len >> 3)
			crc_parallel <= remain_len;
		else
			crc_parallel <= 5'd8;
	end
end

reg crc_en;
always @ (posedge clk)
begin
	crc_en <= (state == cal_crc);
end

reg [23:0] crc_reg;
wire [23:0] next_crc;
always @ (posedge clk)
begin
	case(state)
		idle: crc_reg <= crc_reg;
		wr_d: crc_reg <= {24{1'b0}};			// revised by shaxiaoshi  2016.5.5  here is 24 1 or 24 0 ???
		cal_crc: if(crc_en) crc_reg <= next_crc; else crc_reg <= crc_reg;
		checksum: if(crc_en) crc_reg <= next_crc; else crc_reg <= crc_reg;
	endcase
end

reg [7:0] dout;
wire [7:0] dout_0, dout_1, dout_2, dout_3, dout_4, dout_5, dout_6, dout_7;
wire [63:0] blk_mem_dout;
assign dout_0 = {blk_mem_dout[56], blk_mem_dout[48], blk_mem_dout[40], blk_mem_dout[32], blk_mem_dout[24], blk_mem_dout[16], blk_mem_dout[8], blk_mem_dout[0]};
assign dout_1 = {blk_mem_dout[56+1], blk_mem_dout[48+1], blk_mem_dout[40+1], blk_mem_dout[32+1], blk_mem_dout[24+1], blk_mem_dout[16+1], blk_mem_dout[8+1], blk_mem_dout[0+1]};
assign dout_2 = {blk_mem_dout[56+2], blk_mem_dout[48+2], blk_mem_dout[40+2], blk_mem_dout[32+2], blk_mem_dout[24+2], blk_mem_dout[16+2], blk_mem_dout[8+2], blk_mem_dout[0+2]};
assign dout_3 = {blk_mem_dout[56+3], blk_mem_dout[48+3], blk_mem_dout[40+3], blk_mem_dout[32+3], blk_mem_dout[24+3], blk_mem_dout[16+3], blk_mem_dout[8+3], blk_mem_dout[0+3]};
assign dout_4 = {blk_mem_dout[56+4], blk_mem_dout[48+4], blk_mem_dout[40+4], blk_mem_dout[32+4], blk_mem_dout[24+4], blk_mem_dout[16+4], blk_mem_dout[8+4], blk_mem_dout[0+4]};
assign dout_5 = {blk_mem_dout[56+5], blk_mem_dout[48+5], blk_mem_dout[40+5], blk_mem_dout[32+5], blk_mem_dout[24+5], blk_mem_dout[16+5], blk_mem_dout[8+5], blk_mem_dout[0+5]};
assign dout_6 = {blk_mem_dout[56+6], blk_mem_dout[48+6], blk_mem_dout[40+6], blk_mem_dout[32+6], blk_mem_dout[24+6], blk_mem_dout[16+6], blk_mem_dout[8+6], blk_mem_dout[0+6]};
assign dout_7 = {blk_mem_dout[56+7], blk_mem_dout[48+7], blk_mem_dout[40+7], blk_mem_dout[32+7], blk_mem_dout[24+7], blk_mem_dout[16+7], blk_mem_dout[8+7], blk_mem_dout[0+7]};

reg [2:0] cnt_col_delay;
always @ (posedge clk)
if(reset)   // by shaxiaoshi 2016/6/6
    cnt_col_delay <= 0;
else
begin
	cnt_col_delay <= cnt_col;
end

always @ (*)
begin
	case(cnt_col_delay)
		3'd0: dout = dout_0;
		3'd1: dout = dout_1;
		3'd2: dout = dout_2;
		3'd3: dout = dout_3;
		3'd4: dout = dout_4;
		3'd5: dout = dout_5;
		3'd6: dout = dout_6;
		3'd7: dout = dout_7;
	endcase
end

reg CRC_result, end_CRC;

always @ (posedge clk)
if(reset) // by shaxiaoshi 2016/6/6
begin
    end_CRC <= 1'b0;
	CRC_result <= 1'b0;
end
else
begin
	if(state == checksum)
	begin
		end_CRC <= 1'b1;
		CRC_result <= ~(|crc_reg);
	end
	else
	begin
		end_CRC <= 1'b0;
		CRC_result <= 1'b0;
	end
end

parallel_crc parallel_crc_24(dout, crc_reg, CRC_type, crc_parallel, next_crc); 

crc_blk_mem_1w_8w crc_blk_mem_1w_8w_inst (
  .clka(clk),    // input wire clka
  .ena(wr_crc_mem),      // input wire ena
  .wea(wr_crc_mem),      // input wire [0 : 0] wea
  .addra(wr_crc_addr),  // input wire [9 : 0] addra
  .dina(D),    // input wire [7 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(rd_crc_mem),      // input wire enb
  .addrb(rd_crc_addr),  // input wire [6 : 0] addrb
  .doutb(blk_mem_dout)  // output wire [63 : 0] doutb
);


/*
crc_blk_mem_1w_8w crc_blk_mem_1w_8w_0 (
  .clka(clk),    							// input wire clka
  .ena(crc_mem_en_0),      					// input wire ena
  .wea(wr_crc_mem & crc_mem_en_0),      	// input wire [0 : 0] wea
  .addra(crc_addr),  						// input wire [9 : 0] addra
  .dina(D_0),    							// input wire [0 : 0] dina
  .douta(dout_0)  							// output wire [7 : 0] douta
);

crc_blk_mem_1w_8w crc_blk_mem_1w_8w_1 (
  .clka(clk),    							// input wire clka
  .ena(crc_mem_en_1),      					// input wire ena
  .wea(wr_crc_mem & crc_mem_en_1),      	// input wire [0 : 0] wea
  .addra(crc_addr),  						// input wire [9 : 0] addra
  .dina(D_1),    							// input wire [0 : 0] dina
  .douta(dout_1)  							// output wire [7 : 0] douta
);

crc_blk_mem_1w_8w crc_blk_mem_1w_8w_2 (
  .clka(clk),    							// input wire clka
  .ena(crc_mem_en_2),      					// input wire ena
  .wea(wr_crc_mem & crc_mem_en_2),      	// input wire [0 : 0] wea
  .addra(crc_addr),  						// input wire [9 : 0] addra
  .dina(D_2),    							// input wire [0 : 0] dina
  .douta(dout_2)  							// output wire [7 : 0] douta
);

crc_blk_mem_1w_8w crc_blk_mem_1w_8w_3 (
  .clka(clk),    							// input wire clka
  .ena(crc_mem_en_3),      					// input wire ena
  .wea(wr_crc_mem & crc_mem_en_3),      	// input wire [0 : 0] wea
  .addra(crc_addr),  						// input wire [9 : 0] addra
  .dina(D_3),    							// input wire [0 : 0] dina
  .douta(dout_3)  							// output wire [7 : 0] douta
);

crc_blk_mem_1w_8w crc_blk_mem_1w_8w_4 (
  .clka(clk),    							// input wire clka
  .ena(crc_mem_en_4),      					// input wire ena
  .wea(wr_crc_mem & crc_mem_en_4),      	// input wire [0 : 0] wea
  .addra(crc_addr),  						// input wire [9 : 0] addra
  .dina(D_4),    							// input wire [0 : 0] dina
  .douta(dout_4)  							// output wire [7 : 0] douta
);

crc_blk_mem_1w_8w crc_blk_mem_1w_8w_5 (
  .clka(clk),    							// input wire clka
  .ena(crc_mem_en_5),      					// input wire ena
  .wea(wr_crc_mem & crc_mem_en_5),      	// input wire [0 : 0] wea
  .addra(crc_addr),  						// input wire [9 : 0] addra
  .dina(D_5),    							// input wire [0 : 0] dina
  .douta(dout_5)  							// output wire [7 : 0] douta
);

crc_blk_mem_1w_8w crc_blk_mem_1w_8w_6 (
  .clka(clk),    							// input wire clka
  .ena(crc_mem_en_6),      					// input wire ena
  .wea(wr_crc_mem & crc_mem_en_6),      	// input wire [0 : 0] wea
  .addra(crc_addr),  						// input wire [9 : 0] addra
  .dina(D_6),    							// input wire [0 : 0] dina
  .douta(dout_6)  							// output wire [7 : 0] douta
);

crc_blk_mem_1w_8w crc_blk_mem_1w_8w_7 (
  .clka(clk),    							// input wire clka
  .ena(crc_mem_en_7),      					// input wire ena
  .wea(wr_crc_mem & crc_mem_en_7),      	// input wire [0 : 0] wea
  .addra(crc_addr),  						// input wire [9 : 0] addra
  .dina(D_7),    							// input wire [0 : 0] dina
  .douta(dout_7)  							// output wire [7 : 0] douta
);
*/

endmodule
