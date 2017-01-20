`timescale 1ns / 1ps
`include "Input_parameters.v"

module chnl_parallel_turbo_decoder #(
	parameter C_PCI_DATA_WIDTH = 9'd32
)
(
	input USR_CLK,
	input RST,
	output CHNL_RX_CLK, 
	input CHNL_RX, 
	output CHNL_RX_ACK, 
	input CHNL_RX_LAST, 
	input [31:0] CHNL_RX_LEN, 
	input [30:0] CHNL_RX_OFF, 
	input [C_PCI_DATA_WIDTH-1:0] CHNL_RX_DATA, 
	input CHNL_RX_DATA_VALID, 
	output CHNL_RX_DATA_REN,
	
	output CHNL_TX_CLK, 
	output CHNL_TX, 
	input CHNL_TX_ACK, 
	output CHNL_TX_LAST, 
	output [31:0] CHNL_TX_LEN, 
	output [30:0] CHNL_TX_OFF, 
	output [C_PCI_DATA_WIDTH-1:0] CHNL_TX_DATA, 
	output CHNL_TX_DATA_VALID, 
	input CHNL_TX_DATA_REN
);
	wire clk_pcie, clk_dec;
	wire clk_div;
	// clk 250 --> 125
	clk_wiz_250_100 clk_250_div_inst
    (
      	.clk_in1(USR_CLK),
       	.clk_out1(clk_div)
    ); 
	assign clk_pcie = clk_div;
	assign clk_dec = clk_div;
	
	// state machine regs
	reg [4:0] State;
	parameter wait_for_rx = 5'd0;
	parameter rx_configur = 5'd1;
	parameter rx_system = 5'd2;
	parameter rx_parity_0 = 5'd3;
	parameter rx_parity_1 = 5'd4;
	parameter rx_tail = 5'd5;
	parameter rx_over = 5'd6;
	parameter wait_for_tx = 5'd7;
	parameter tx_d = 5'd8;

	reg [31:0] rLen, rCountSys, rCountPar_0, rCountPar_1, rCountTail, rCountOver;
	reg [C_PCI_DATA_WIDTH-1:0] rConfig, tConfig;

	reg [31:0] tLen, tCount;
	reg [C_PCI_DATA_WIDTH-1:0] tData;

	// assgin control signal
	// RX 
	assign CHNL_RX_CLK = clk_pcie;
	assign CHNL_RX_ACK = (State == rx_configur);
	assign CHNL_RX_DATA_REN = (State == rx_configur || State == rx_system || State == rx_parity_0 || State == rx_parity_1 || State == rx_tail);
	// TX
	assign CHNL_TX_CLK = clk_pcie;
	assign CHNL_TX = (State == tx_d);
	assign CHNL_TX_LAST = 1'd1;
	assign CHNL_TX_LEN = (tLen + 1) << 2; // in words
	assign CHNL_TX_OFF = 0;
	assign CHNL_TX_DATA = tData;
	assign CHNL_TX_DATA_VALID = (State == tx_d);
	
	wire Decode_Result_Start, end_decode;
	reg two_decoders_over;
	
	// state machine
	always @ (posedge clk_pcie) begin
		if(RST) begin
			rCountSys <= 0;
			rCountPar_0 <= 0;
			rCountPar_1 <= 0;
			rCountTail <= 0;
			rCountOver <= 0;
			tCount <= 0;
			State <= 0;
		end
	else begin
		case(State)
			wait_for_rx: begin
				if(CHNL_RX) begin
					rCountSys <= 0;
					rCountPar_0 <= 0;
					rCountPar_1 <= 0;
					rCountTail <= 0;
					rCountOver <= 0;
					tCount <= 0;
					State <= rx_configur;
				end
			end
			
			rx_configur: begin
				if(CHNL_RX_DATA_VALID)
					State <= rx_system;
			end
		
			rx_system: begin
				if(CHNL_RX_DATA_VALID)
					rCountSys <= rCountSys + 1;
				if(rCountSys >= rLen - 1 && CHNL_RX_DATA_VALID)
					State <= rx_parity_0;
				else
					State <= rx_system;
			end
		
			rx_parity_0: begin
				if(CHNL_RX_DATA_VALID)
					rCountPar_0 <= rCountPar_0 + 1;
				if(rCountPar_0 >= rLen - 1 && CHNL_RX_DATA_VALID)
					State <= rx_parity_1;
				else
					State <= rx_parity_0;
			end
			
			rx_parity_1: begin
				if(CHNL_RX_DATA_VALID)
					rCountPar_1 <= rCountPar_1 + 1;
				if(rCountPar_1 >= rLen - 1 && CHNL_RX_DATA_VALID)
					State <= rx_tail;
				else
					State <= rx_parity_1;
				end
		
			rx_tail: begin
				if(CHNL_RX_DATA_VALID)
					rCountTail <= rCountTail + 1;
				if(rCountTail >= (((cb_num << 2) + (cb_num << 1)) + 6 - 1) && CHNL_RX_DATA_VALID)
					State <= rx_over;
				else
					State <= rx_tail;
			end
		
			rx_over: begin
				rCountOver <= rCountOver + 1;
				if(rCountOver > 3)
					State <= wait_for_tx;
				else
					State <= rx_over;
			end
		
			wait_for_tx: begin
				tCount <= 0;
				if(two_decoders_over)
					State <= tx_d;
				else
					State <= wait_for_tx;
			end

			tx_d: begin
				if (CHNL_TX_DATA_REN & CHNL_TX_DATA_VALID) begin
					tCount <= tCount + 1;
				if (tCount >= tLen  && CHNL_TX_DATA_REN && CHNL_TX_DATA_VALID)
					State <= wait_for_rx;
				else
					State <= tx_d;
				end
			end
		endcase
	end
end

	reg [9:0] sys_addr;
	always @ (posedge clk_pcie)
	if(RST)
		sys_addr <= 0;
	else
	begin
		if(State == rx_system && CHNL_RX_DATA_VALID)
		begin
			if(sys_addr == (code_length[12:3] - 1))
				sys_addr <= 0;
			else
				sys_addr <= sys_addr + 10'd1;
		end
		else
			sys_addr <= sys_addr;
	end
	
	reg [9:0] par_addr_0;
	always @ (posedge clk_pcie)
	if(RST)
		par_addr_0 <= 0;
	else
	begin
		if(State == rx_parity_0 && CHNL_RX_DATA_VALID)
		begin
			if(par_addr_0 == (code_length[12:3] - 1))
				par_addr_0 <= 0;
			else
				par_addr_0 <= par_addr_0 + 10'd1;
		end
		else
			par_addr_0 <= par_addr_0;
	end
	
	reg [9:0] par_addr_1;
	always @ (posedge clk_pcie)
	if(RST)
		par_addr_1 <= 0;
	else
	begin
		if(State == rx_parity_1 && CHNL_RX_DATA_VALID)
		begin
			if(par_addr_1 == (code_length[12:3] - 1))
				par_addr_1 <= 0;
			else
				par_addr_1 <= par_addr_1 + 10'd1;
		end
		else
			par_addr_1 <= par_addr_1;
	end

	reg [2:0] tail_addr;
	always @ (posedge clk_pcie)
	if(RST)
		tail_addr <= 0;
	else
	begin
		if(State == rx_tail && CHNL_RX_DATA_VALID)
		begin
			if(tail_addr == (6 -1))
				tail_addr <= 0;
			else
				tail_addr <= tail_addr + 3'd1;
		end
		else
			tail_addr <= tail_addr;
	end
	
	reg [6:0] d_addr;
	always @ (posedge clk_pcie)
	if(RST)
		d_addr <= 0;
	else	
	begin
		if(State == tx_d  && CHNL_TX_DATA_REN && CHNL_TX_DATA_VALID)
		begin
			if(d_addr == (code_length[12:6] - 1 + ((code_length[5:3] == 0)? 0 : 1)))
				d_addr <= 0;
			else
				d_addr <= d_addr + 1;
		end
		else if(State != tx_d)
			d_addr <= 0;
		else
			d_addr <= d_addr;
	end
		
	reg [`codeblock_addr_width - 1:0] cb_cnt;
	reg [`codeblock_addr_width - 1:0] cb_num;
	
	
	always @(posedge clk_pcie)
	begin
		begin
			case(State)
				rx_system :
				begin
					if(rCountSys == rLen - 1 && CHNL_RX_DATA_VALID)
						cb_cnt <= 0;
					else if(sys_addr == (code_length[12:3] - 1) && CHNL_RX_DATA_VALID)
						cb_cnt <= cb_cnt + 1;
					else
						cb_cnt <= cb_cnt;
				end
				
				rx_parity_0 :
				begin
					if(rCountPar_0 == rLen - 1 && CHNL_RX_DATA_VALID)
						cb_cnt <= 0;
					else if(par_addr_0 == (code_length[12:3] - 1) && CHNL_RX_DATA_VALID)
						cb_cnt <= cb_cnt + 1;
					else
						cb_cnt <= cb_cnt;
				end
				
				rx_parity_1 :
				begin
					if(rCountPar_1 == rLen - 1 && CHNL_RX_DATA_VALID)
						cb_cnt <= 0;
					else if(par_addr_1 == (code_length[12:3] - 1) && CHNL_RX_DATA_VALID)
						cb_cnt <= cb_cnt + 1;
					else
						cb_cnt <= cb_cnt;
				end
				
				rx_tail :
				begin
					if(tail_addr == 6 - 1 && CHNL_RX_DATA_VALID)
						cb_cnt <= cb_cnt + 1;
					else
						cb_cnt <= cb_cnt;
				end
				
				tx_d :
				begin
					if(tCount >= tLen - 1 && CHNL_TX_DATA_REN && CHNL_TX_DATA_VALID)
						cb_cnt <= 0;
					else if(d_addr == (code_length[12:6] - 1 + ((code_length[5:3] == 0)? 0 : 1)) && CHNL_TX_DATA_REN && CHNL_TX_DATA_VALID)
						cb_cnt <= cb_cnt + 1;
					else
						cb_cnt <= cb_cnt;
				end
				
				default:
					cb_cnt <= 0;
			endcase
		end
	end
	
	always @(posedge clk_pcie)
	begin
		if(State == rx_system && CHNL_RX_DATA_VALID && (rCountSys == rLen - 1))
			cb_num <= cb_cnt;
		else
			cb_num <= cb_num;
	end
	
	// config, system ,parity, tail & D ram
	// config
	always @ (posedge clk_pcie)
	begin
		if(State == rx_configur && CHNL_RX_DATA_VALID) begin
			rLen <= CHNL_RX_DATA[95:64];
			tLen <= CHNL_RX_DATA[127:96];
			rConfig <= CHNL_RX_DATA;
		end
		else begin
			rLen <= rLen;
			tLen <= tLen;
			rConfig <= rConfig;
		end
	end
	
	// system
	reg write_en_system;
	reg [`codeblock_addr_width + 9:0] write_addr_system;
	reg [C_PCI_DATA_WIDTH-1:0] rSystem;
	always@(posedge clk_pcie)
	begin
		write_en_system <= ((State == rx_system) && CHNL_RX_DATA_VALID);
		write_addr_system <= {cb_cnt, sys_addr};
		if((State == rx_system) && CHNL_RX_DATA_VALID)
			rSystem <= CHNL_RX_DATA;
		else
			rSystem <= 0;
	end
		
	// parity 0
	reg write_en_parity_0;
	reg [`codeblock_addr_width + 9:0] write_addr_parity_0;
	reg [C_PCI_DATA_WIDTH-1:0] rParity0;
	always @ (posedge clk_pcie)
	begin
		write_en_parity_0 <= ((State == rx_parity_0) && CHNL_RX_DATA_VALID);
		write_addr_parity_0 <= {cb_cnt, par_addr_0};
		if((State == rx_parity_0) && CHNL_RX_DATA_VALID)
			rParity0 <= CHNL_RX_DATA;
		else
			rParity0 <= 0;		
	end
	
	// parity 1
	reg write_en_parity_1;
	reg [`codeblock_addr_width + 9:0] write_addr_parity_1;
	reg [C_PCI_DATA_WIDTH-1:0] rParity1;
	always @ (posedge clk_pcie)
	begin
		write_en_parity_1 <= ((State == rx_parity_1) && CHNL_RX_DATA_VALID);
		write_addr_parity_1 <= {cb_cnt, par_addr_1};
		if((State == rx_parity_1) && CHNL_RX_DATA_VALID)
			rParity1 <= CHNL_RX_DATA;
		else
			rParity1 <= 0;		
	end
		
	// tail
	reg write_en_tail;
	reg [`codeblock_addr_width + 2:0] write_addr_tail;
	reg [C_PCI_DATA_WIDTH-1:0] rTail;
	always @ (posedge clk_pcie)
	begin
		write_en_tail <= (State == rx_tail && CHNL_RX_DATA_VALID);
		write_addr_tail <= {cb_cnt, tail_addr[2:0]};
		if(State == rx_tail && CHNL_RX_DATA_VALID)
			rTail <= CHNL_RX_DATA;	
		else
			rTail <= 0;		
	end

	// pcie read
	wire [127:0] D_out;
	wire [`codeblock_addr_width + 6:0] read_addr_D;
	assign read_addr_D = {cb_cnt, d_addr};
	always@(posedge clk_pcie)
	begin
		if(State != tx_d)
			tData <= tConfig;
		else if(State == tx_d && CHNL_TX_DATA_REN && CHNL_TX_DATA_VALID)
			tData <= D_out;
		else
			tData = tData;
	end
	
	always @ (posedge clk_pcie)
	begin
		tConfig <= rConfig;
	end
	
	reg [12:0] code_length;
	reg [3:0] iter_max;
	reg crc_type;
	reg [3:0] parallel_degree;
	always @ (posedge clk_dec)
	begin
		code_length <= rConfig[12:0];
		iter_max <= rConfig[19:16];
		crc_type <= rConfig[32:32];
		parallel_degree <= 4'd8;
	end
	
	wire decode_enable, decode_over_0, decode_over_1;
	assign decode_enable = (State == wait_for_tx);
	always @ (posedge clk_pcie)
	if(RST)
		two_decoders_over <= 1'b0;
	else
	begin
		if(State == wait_for_tx && decode_over_0 && decode_over_1)
			two_decoders_over <= 1'b1;
		else
			two_decoders_over <= 1'b0;
	end

//	assign two_decoders_over = (decode_over_0 & decode_over_1);
//	assign two_decoders_over = (decode_over_0);
//	assign two_decoders_over = (decode_over_1);

/*	
	wire [`codeblock_addr_width - 1:0] dec_cnt_0;
	wire [1:0] dec_sm_0;
	wire rst_dec_0, start_decode_0, end_decode_0;
	
	wire [`codeblock_addr_width - 1:0] dec_cnt_1;
	wire [1:0] dec_sm_1;
	wire rst_dec_1, start_decode_1, end_decode_1;
*/
	
	TurboDecoderWrapper turbo_decoder_wrapper_0(
		.clk_pcie(clk_pcie), .clk_dec(clk_dec), .reset(RST),
		.cb_num(cb_num), .cb_length(code_length), .parallel_degree(4'd8), .iter_max(iter_max), .crc_type(crc_type),
		.dec_en(decode_enable), .dec_over(decode_over_0),
		.wr_addr_SYS(write_addr_system), .wr_en_SYS(write_en_system), .wr_data_SYS(rSystem[55:0]),
		.wr_addr_PAR0(write_addr_parity_0), .wr_en_PAR0(write_en_parity_0), .wr_data_PAR0(rParity0[55:0]),
		.wr_addr_PAR1(write_addr_parity_1), .wr_en_PAR1(write_en_parity_1), .wr_data_PAR1(rParity1[55:0]),
		.wr_addr_TAIL(write_addr_tail), .wr_en_TAIL(write_en_tail), .wr_data_TAIL(rTail[13:0]),
		.rd_addr_D(read_addr_D), .rd_data_D(D_out[63:0])
	 );
 	
	TurboDecoderWrapper turbo_decoder_wrapper_1(
	 	.clk_pcie(clk_pcie), .clk_dec(clk_dec), .reset(RST),
	 	.cb_num(cb_num), .cb_length(code_length), .parallel_degree(4'd8), .iter_max(iter_max), .crc_type(crc_type),
	 	.dec_en(decode_enable), .dec_over(decode_over_1),
	 	.wr_addr_SYS(write_addr_system), .wr_en_SYS(write_en_system), .wr_data_SYS(rSystem[119:64]),
	 	.wr_addr_PAR0(write_addr_parity_0), .wr_en_PAR0(write_en_parity_0), .wr_data_PAR0(rParity0[119:64]),
	 	.wr_addr_PAR1(write_addr_parity_1), .wr_en_PAR1(write_en_parity_1), .wr_data_PAR1(rParity1[119:64]),
	 	.wr_addr_TAIL(write_addr_tail), .wr_en_TAIL(write_en_tail), .wr_data_TAIL(rTail[77:64]),
	 	.rd_addr_D(read_addr_D), .rd_data_D(D_out[127:64])
	  );
	 
	 
	/* 
	ila_parallel_decoder ila_parallel_decoder_inst (
	  	.clk(clk_pcie), // input wire clk
	  	.probe0(State), // input wire [4:0]  probe0  
	  	.probe1(cb_cnt), // input wire [3:0]  probe1 
	  	.probe2(dec_cnt_0), // input wire [3:0]  probe2 
	  	.probe3(dec_sm_0), // input wire [1:0]  probe3 
	  	.probe4(rst_dec_0), // input wire [0:0]  probe4 
	  	.probe5(start_decode_0), // input wire [0:0]  probe5 
	  	.probe6(end_decode_0), // input wire [0:0]  probe6 
	  	.probe7(dec_cnt_1), // input wire [3:0]  probe7 
	  	.probe8(dec_sm_1), // input wire [1:0]  probe8 
	  	.probe9(rst_dec_1), // input wire [0:0]  probe9 
	  	.probe10(start_decode_1), // input wire [0:0]  probe10 
	  	.probe11(end_decode_1) // input wire [0:0]  probe11
	  );
	  */
	/*
	  ila_1 pcie_io (
	  	.clk(clk_pcie), // input wire clk
	  	.probe0(CHNL_RX), // input wire [0:0]  probe0  
	  	.probe1(CHNL_RX_DATA), // input wire [127:0]  probe1 
	  	.probe2(CHNL_RX_DATA_VALID), // input wire [0:0]  probe2 
	  	.probe3(CHNL_RX_DATA_REN), // input wire [0:0]  probe3 
	  	.probe4(CHNL_TX), // input wire [0:0]  probe4 
	  	.probe5(CHNL_TX_DATA), // input wire [63:0]  probe5 
	  	.probe6(CHNL_TX_DATA_VALID), // input wire [0:0]  probe6 
	  	.probe7(CHNL_TX_DATA_REN), // input wire [0:0]  probe7 
	  	.probe8(State), // input wire [4:0]  probe8
		.probe9(tCount), // input wire [31:0]  probe9 
	  	.probe10(tLen), // input wire [31:0]  probe10 
	  	.probe11(read_addr_D) // input wire [10:0]  probe11
	  );
	  */
endmodule
