`timescale 1ns / 1ps
`include "Input_parameters.v"

module chnl_turbo_decoder #(
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
	clk_wiz_250_125 clk_250_div_inst
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
	parameter rx_parity = 5'd3;
	parameter rx_tail = 5'd4;
	parameter rx_over = 5'd5;
	parameter wait_for_tx = 5'd6;
	parameter tx_d = 5'd7;

	reg [31:0] rLen, rCountSys, rCountPar, rCountTail, rCountOver;
	reg [C_PCI_DATA_WIDTH-1:0] rConfig, tConfig;
	reg [C_PCI_DATA_WIDTH-1:0] rSystem;
	reg [C_PCI_DATA_WIDTH/2-1:0] rParity0, rParity1;
	reg [C_PCI_DATA_WIDTH-1:0] rTail;

	reg [31:0] tLen, tCount;
	reg [C_PCI_DATA_WIDTH-1:0] tData;

	// assgin control signal
	// RX 
	assign CHNL_RX_CLK = clk_pcie;
	assign CHNL_RX_ACK = (State == rx_configur);
	assign CHNL_RX_DATA_REN = (State == rx_configur || State == rx_system || State == rx_parity || State == rx_tail);
	// TX
	assign CHNL_TX_CLK = clk_pcie;
	assign CHNL_TX = (State == tx_d);
	assign CHNL_TX_LAST = 1'd1;
	assign CHNL_TX_LEN = (tLen + 2) << 2; // in words
	assign CHNL_TX_OFF = 0;
	assign CHNL_TX_DATA = tData;
	assign CHNL_TX_DATA_VALID = (State == tx_d);
	
	wire Decode_Result_Start, end_decode;
	
	// state machine
	always @ (posedge clk_pcie) begin
		if(RST) begin
			rCountSys <= 0;
			rCountPar <= 0;
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
					rCountPar <= 0;
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
					State <= rx_parity;
				else
					State <= rx_system;
			end
		
			rx_parity: begin
				if(CHNL_RX_DATA_VALID)
					rCountPar <= rCountPar + 1;
				if(rCountPar >= rLen - 1 && CHNL_RX_DATA_VALID)
					State <= rx_tail;
				else
					State <= rx_parity;
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
				if(dec_over)
					State <= tx_d;
				else
					State <= wait_for_tx;
			end

			tx_d: begin
				if (CHNL_TX_DATA_REN & CHNL_TX_DATA_VALID) begin
					tCount <= tCount + 1;
				if (tCount >= tLen + 1  && CHNL_TX_DATA_REN && CHNL_TX_DATA_VALID)
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
	
	reg [9:0] par_addr;
	always @ (posedge clk_pcie)
	if(RST)
			par_addr <= 0;
	else
	begin
		if(State == rx_parity && CHNL_RX_DATA_VALID)
		begin
			if(par_addr == (code_length[12:3] - 1))
				par_addr <= 0;
			else
				par_addr <= par_addr + 10'd1;
		end
		else
			par_addr <= par_addr;
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
	
	reg [9:0] d_addr;
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
	reg [`codeblock_addr_width - 1:0] dec_cnt;
	
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
				
				rx_parity :
				begin
					if(rCountPar == rLen - 1 && CHNL_RX_DATA_VALID)
						cb_cnt <= 0;
					else if(par_addr == (code_length[12:3] - 1) && CHNL_RX_DATA_VALID)
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
	wire [9:0] read_addr_system;
	wire [`sys_par_width*8-1:0] system_out_ram;
	always@(posedge clk_pcie)
	begin
		write_en_system <= ((State == rx_system) && CHNL_RX_DATA_VALID);
		write_addr_system <= {cb_cnt, sys_addr[9:0]};
		if((State == rx_system) && CHNL_RX_DATA_VALID)
			rSystem <= CHNL_RX_DATA;
		else
			rSystem <= 0;
	end
	
	blk_mem_gen blk_mem_gen_sys (
	  .clka(clk_pcie),    // input wire clka
	  .ena(write_en_system),      // input wire ena
	  .wea(write_en_system),      // input wire [0 : 0] wea
	  .addra(write_addr_system),  // input wire [14 : 0] addra
	  .dina(rSystem),    // input wire [55 : 0] dina
	  .clkb(clk_dec),    // input wire clkb
	  .enb(~write_en_system),      // input wire enb
	  .addrb({dec_cnt, read_addr_system[9:0]}),  // input wire [14 : 0] addrb
	  .doutb(system_out_ram)  // output wire [55 : 0] doutb
	);
	
	// parity
	reg write_en_parity;
	reg [`codeblock_addr_width + 9:0] write_addr_parity;
	wire [9:0] read_addr_parity;
	wire [`sys_par_width*8-1:0] parity0_out_ram, parity1_out_ram;
	always @ (posedge clk_pcie)
	begin
		write_en_parity <= ((State == rx_parity) && CHNL_RX_DATA_VALID);
		write_addr_parity <= {cb_cnt, par_addr[9:0]};
		if((State == rx_parity) && CHNL_RX_DATA_VALID)
		begin
		//	{rParity1, rParity0} <= CHNL_RX_DATA;	
			rParity1 <= CHNL_RX_DATA[127:64];
			rParity0 <= CHNL_RX_DATA[63:0];
		end
		else
			{rParity1, rParity0} <= 0;		
	end
	
	blk_mem_gen blk_mem_gen_par_0 (
	  .clka(clk_pcie),    // input wire clka
	  .ena(write_en_parity),      // input wire ena
	  .wea(write_en_parity),      // input wire [0 : 0] wea
	  .addra(write_addr_parity),  // input wire [14 : 0] addra
	  .dina(rParity0),    // input wire [55 : 0] dina
	  .clkb(clk_dec),    // input wire clkb
	  .enb(~write_en_parity),      // input wire enb
	  .addrb({dec_cnt, read_addr_parity[9:0]}),  // input wire [14 : 0] addrb
	  .doutb(parity0_out_ram)  // output wire [55 : 0] doutb
	);

	blk_mem_gen blk_mem_gen_par_1 (
	  .clka(clk_pcie),    // input wire clka
	  .ena(write_en_parity),      // input wire ena
	  .wea(write_en_parity),      // input wire [0 : 0] wea
	  .addra(write_addr_parity),  // input wire [14 : 0] addra
	  .dina(rParity1),    // input wire [55 : 0] dina
	  .clkb(clk_dec),    // input wire clkb
	  .enb(~write_en_parity),      // input wire enb
	  .addrb({dec_cnt, read_addr_parity[9:0]}),  // input wire [14 : 0] addrb
	  .doutb(parity1_out_ram)  // output wire [55 : 0] doutb
	);
		
	// tail
	reg write_en_tail;
	reg [`codeblock_addr_width + 2:0] write_addr_tail;
	wire [2:0] read_addr_tail;
	wire [`sys_par_width*2-1:0] tail_out_ram;
	always @ (posedge clk_pcie)
	begin
		write_en_tail <= (State == rx_tail && CHNL_RX_DATA_VALID);
		write_addr_tail <= {cb_cnt, tail_addr[2:0]};
		if(State == rx_tail && CHNL_RX_DATA_VALID)
			rTail <= CHNL_RX_DATA;	
		else
			rTail <= 0;		
	end

	blk_mem_gen_tail blk_mem_gen_tail_inst (
  	.clka(clk_pcie),    // input wire clka
  	.ena(write_en_tail),      // input wire ena
  	.wea(write_en_tail),      // input wire [0 : 0] wea
  	.addra(write_addr_tail),  // input wire [9 : 0] addra
  	.dina(rTail[13:0]),    // input wire [13 : 0] dina
  	.clkb(clk_dec),    // input wire clkb
  	.enb(~write_en_tail),      // input wire enb
  	.addrb({dec_cnt,read_addr_tail[2:0]}),  // input wire [9 : 0] addrb
  	.doutb(tail_out_ram)  // output wire [13 : 0] doutb
	);	
/*	
	dist_mem_gen dist_mem_gen_tail_inst (
	  .a(write_addr_tail),		// input wire [7 : 0] a
	  .d(rTail[13:0]),							// input wire [13 : 0] d
	  .dpra({dec_cnt,read_addr_tail[2:0]}),		// input wire [7 : 0] dpra
	  .clk(clk_pcie),							// input wire clk
	  .we(write_en_tail),						// input wire we
	  .qdpo_clk(clk_dec),						// input wire qdpo_clk
	  .qdpo(tail_out_ram)						// output wire [13 : 0] qdpo
	);
*/

	// D
	// turbo write
	reg write_en_D;
	reg [`codeblock_addr_width + 6:0] write_addr_D;
	wire [63:0] D;
	wire [`Data_Addr_width-1:0] D_addr;
	
	always @ (posedge clk_dec)
	begin
		write_addr_D <= {dec_cnt, D_addr[6:0]};
		if(Decode_Result_Start)
			write_en_D <= 1'b1;
		else if(end_decode)
			write_en_D <= 1'b0;
		else
			write_en_D <= write_en_D;
	end
	
	// pcie read
	wire [63:0] D_out_ram;
	wire [`codeblock_addr_width + 6:0] read_addr_D;
	assign read_addr_D = {cb_cnt, d_addr[6:0]};

	always@(posedge clk_pcie)
	begin
		if(State != tx_d)
			tData <= {31'd0, crc_result, tConfig[95:0]};
		else if(State == tx_d && CHNL_TX_DATA_REN && CHNL_TX_DATA_VALID)
			tData <= D_out_ram;
		else
			tData = tData;
	end
	
	blk_mem_gen_D blk_mem_gen_D_inst (
	  .clka(clk_dec),    // input wire clka
	  .ena(write_en_D),      // input wire ena
	  .wea(write_en_D),      // input wire [0 : 0] wea
	  .addra(write_addr_D),  // input wire [11 : 0] addra
	  .dina(D),    // input wire [63 : 0] dina
	  .clkb(clk_pcie),    // input wire clkb
	  .enb(~write_en_D),      // input wire enb
	  .addrb(read_addr_D),  // input wire [11 : 0] addrb
	  .doutb(D_out_ram)  // output wire [63 : 0] doutb
	);
	
/*	
	dist_mem_gen_D dist_mem_gen_D_inst (
	  .a(write_addr_D),     				// input wire [9 : 0] a
	  .d(D),        						// input wire [63 : 0] d
	  .dpra(read_addr_D),  					// input wire [9 : 0] dpra
	  .clk(clk_dec),    					// input wire clk
	  .we(write_en_D),      				// input wire we
	  .dpo(D_out_ram)    					// output wire [63 : 0] dpo
	);
*/	
	
	// state machine for decoder
	reg dec_over;
	always @ (posedge clk_dec)
	if(RST)
	begin
		dec_over <= 0;
		dec_cnt <= -1;
	end
	else
	begin
		if(State == wait_for_tx)
		begin
			if(dec_cnt == cb_num && end_decode)
				dec_over <= 1;
			else
				dec_over <= 0;
			if(start_decode)
				dec_cnt <= dec_cnt + 1;
			else
				dec_cnt <= dec_cnt;
		end
		else
		begin
			dec_cnt <= -1;
			dec_over <= 0;
		end
	end
	
	reg [1:0] dec_sm;
	parameter dec_rst = 2'd0;
	parameter dec_strt = 2'd1;
	parameter dec_wait = 2'd2;
	parameter dec_end = 2'd3;
	always @ (posedge clk_dec)
	if(RST)
		dec_sm <= dec_rst;
	else
	begin
		case(dec_sm)
			dec_rst :
			begin
				if((State == wait_for_tx) && (~dec_over))
					dec_sm <= dec_strt;
				else
					dec_sm <= dec_rst;
			end
			dec_strt :
			begin
				dec_sm <= dec_wait;
			end
			dec_wait :
			begin
				if(end_decode)
					dec_sm <= dec_end;
				else
					dec_sm <= dec_wait;
			end
			dec_end :
			begin
				dec_sm <= dec_rst;
			end	
		endcase
	end

	wire rst_dec, start_decode;
	assign rst_dec = ~((dec_sm == dec_rst) || (dec_sm == dec_end));
	assign start_decode = (dec_sm == dec_strt);
	// Instantiate the Unit Under Test (UUT)

	reg [12:0] code_length;
//	reg [3:0] parallel_degree;
	reg [3:0] iter_max;
	reg crc_type;		// revised by shaxiaoshi 2015.05.03
	always @ (posedge clk_dec)
	begin
		code_length <= rConfig[12:0];
//		parallel_degree <= 4'd8; // rConfig[35:32];
		iter_max <= rConfig[35:32];
//		crc_type <= rConfig[32:32];
	end
	
	wire crc_result;
	always @ (posedge clk_pcie)
	begin
		tConfig <= rConfig[95:0];
	end

	Modu_Decoder_New_CRC turbo_decoder(
		.clk(clk_dec), 
		.reset(rst_dec), 
		.Start_Cmp(start_decode),
		.CB_length(code_length),
		.Parallel_degree(4'd8),
		.Iter_Max(iter_max),
		.CRC_type(1'b0),
		// ram data
		.System_In_ROM(system_out_ram),
		.Parity0_In_ROM(parity0_out_ram),
		.Parity1_In_ROM(parity1_out_ram),
		.Tail_In_ROM(tail_out_ram),
		// ram addr
		.Read_Addr_system(read_addr_system),
		.Read_Addr_parity(read_addr_parity),
		.Read_Addr_tail(read_addr_tail),
		// output revised by shaxiaoshi
		.CRC_result(crc_result),
		.Decode_Result_Start(Decode_Result_Start),
		.Decode_Result_Addr(D_addr),
		.Decode_result_D(D),  // .D(D), 
		.End_Decode(end_decode)			
	);
	
	/*
	ila_0 ila_0_inst (
		.clk(clk_pcie), // input wire clk
		.probe0(State), // input wire [3:0]  probe0  
		.probe1(rCountSys), // input wire [31:0]  probe1 
		.probe2(rCountPar), // input wire [31:0]  probe2 
		.probe3(rCountTail), // input wire [31:0]  probe3 
		.probe4(tCount), // input wire [31:0]  probe4 
		.probe5(cb_cnt), // input wire [4:0]  probe5 
		.probe6(dec_cnt), // input wire [4:0]  probe6 
		.probe7(CHNL_RX_DATA_VALID), // input wire [0:0]  probe7 
		.probe8(CHNL_TX_DATA_REN), // input wire [0:0]  probe8 
		.probe9(CHNL_TX_DATA_VALID), // input wire [0:0]  probe9 
		.probe10(dec_sm), // input wire [1:0]  probe10 
		.probe11(rst_dec), // input wire [0:0]  probe11 
		.probe12(start_decode), // input wire [0:0]  probe12 
		.probe13(end_decode), // input wire [0:0]  probe13 
		.probe14(dec_over) // input wire [0:0]  probe14
	);
	*/
endmodule
