`timescale 1ns / 1ps
`include "Input_parameters.v"


module TurboDecoderWrapper(
	clk_pcie, clk_dec, reset,
	cb_num, cb_length, parallel_degree, iter_max, crc_type,
	dec_en, dec_over,
	wr_addr_SYS, wr_addr_PAR0, wr_addr_PAR1,wr_addr_TAIL, rd_addr_D,
	wr_en_SYS, wr_en_PAR0, wr_en_PAR1, wr_en_TAIL,
	wr_data_SYS, wr_data_PAR0, wr_data_PAR1,wr_data_TAIL, rd_data_D/*,
	dec_cnt, dec_sm, rst_dec, start_decode, end_decode*/
 );
 	// clock
 	input clk_pcie, clk_dec, reset;
 	// parameter
 	input [`codeblock_addr_width - 1:0] cb_num;
 	input [12:0] cb_length;
 	input [3:0] parallel_degree;
 	input [3:0] iter_max;
 	input crc_type;
 	// control signal
 	input dec_en;
 	output dec_over;
 	// IO addr, wen, data
 	input [`codeblock_addr_width + 9:0]  wr_addr_SYS, wr_addr_PAR0, wr_addr_PAR1;
 	input [`codeblock_addr_width + 2:0] wr_addr_TAIL;
 	input [`codeblock_addr_width + 6:0] rd_addr_D;
 	input wr_en_SYS, wr_en_PAR0, wr_en_PAR1, wr_en_TAIL;
 	input [55:0] wr_data_SYS, wr_data_PAR0, wr_data_PAR1;
 	input [13:0] wr_data_TAIL;
 	output [63:0] rd_data_D;
	/* 	
 	output [`codeblock_addr_width - 1:0] dec_cnt;
 	output [1:0] dec_sm;
 	output rst_dec, start_decode, end_decode;
	*/ 
 
    reg [`codeblock_addr_width - 1:0] dec_cnt;
        
    wire [9:0] rd_addr_SYS;
    wire [`sys_par_width*8-1:0] rd_data_SYS;
 	blk_mem_gen blk_mem_gen_sys (
 		.clka(clk_pcie),    
 		.ena(wr_en_SYS),
 		.wea(wr_en_SYS),
 		.addra(wr_addr_SYS),
 		.dina(wr_data_SYS),
 		.clkb(clk_dec), 
 		.enb(~wr_en_SYS), 
 		.addrb({dec_cnt, rd_addr_SYS}),
 		.doutb(rd_data_SYS)
 	);   
 	
 	wire [9:0] rd_addr_PAR;
 	wire [`sys_par_width*8-1:0] rd_data_PAR0;
 	blk_mem_gen blk_mem_gen_par_0 (
	  .clka(clk_pcie),
	  .ena(wr_en_PAR0), 
	  .wea(wr_en_PAR0), 
	  .addra(wr_addr_PAR0), 
	  .dina(wr_data_PAR0), 
	  .clkb(clk_dec),  
	  .enb(~wr_en_PAR0),
	  .addrb({dec_cnt, rd_addr_PAR}),
	  .doutb(rd_data_PAR0) 
	);
	
	wire [`sys_par_width*8-1:0] rd_data_PAR1;
	blk_mem_gen blk_mem_gen_par_1 (
	  .clka(clk_pcie),  
	  .ena(wr_en_PAR1),   
	  .wea(wr_en_PAR1),    
	  .addra(wr_addr_PAR1), 
	  .dina(wr_data_PAR1), 
	  .clkb(clk_dec),  
	  .enb(~wr_en_PAR1),   
	  .addrb({dec_cnt, rd_addr_PAR}), 
	  .doutb(rd_data_PAR1) 
	);

	wire [2:0] rd_addr_TAIL;
	wire [`sys_par_width*2-1:0] rd_data_TAIL;
	blk_mem_gen_tail blk_mem_gen_tail_inst (
		.clka(clk_pcie),  
  		.ena(wr_en_TAIL),   
  		.wea(wr_en_TAIL),    
  		.addra(wr_addr_TAIL), 
  		.dina(wr_data_TAIL),  
  		.clkb(clk_dec),   
  		.enb(~wr_en_TAIL),     
  		.addrb({dec_cnt, rd_addr_TAIL}), 
  		.doutb(rd_data_TAIL)
	);	
    
    // D
 	// turbo write D
 	reg wr_en_D;
 	reg [`codeblock_addr_width + 6:0] wr_addr_D;
 	wire [6:0] decode_addr_D;
 	wire [63:0] decode_D;
 		
 	always @ (posedge clk_dec)
 	begin
 		wr_addr_D <= {dec_cnt, decode_addr_D};
 		if(Decode_Result_Start)
 			wr_en_D <= 1'b1;
 		else if(end_decode)
 			wr_en_D <= 1'b0;
 		else
 			wr_en_D <= wr_en_D;
 	end
    
    dist_mem_gen_D dist_mem_gen_D_inst (
 	  .a(wr_addr_D),        // input wire [10 : 0] a
 	  .d(decode_D),        // input wire [63 : 0] d
 	  .dpra(rd_addr_D),  // input wire [10 : 0] dpra
 	  .clk(clk_dec),    // input wire clk
 	  .we(wr_en_D),      // input wire we
 	  .dpo(rd_data_D)    // output wire [63 : 0] dpo
 	);    
 	
 	/*
 	ila_dist_D ila_dist_D_inst (
 		.clk(clk_dec), // input wire clk
 		.probe0(wr_addr_D), // input wire [10:0]  probe0  
 		.probe1(decode_D), // input wire [63:0]  probe1 
 		.probe2(rd_addr_D), // input wire [10:0]  probe2 
 		.probe3(wr_en_D), // input wire [0:0]  probe3 
 		.probe4(rd_data_D) // input wire [63:0]  probe4
 	);
 	*/
 	
   /* 
    blk_mem_gen_D blk_mem_gen_D_inst (
      .clka(clk_dec), 
      .ena(wr_en_D),
      .wea(wr_en_D), 
      .addra(wr_addr_D),  
      .dina(decode_D),    			
      .clkb(clk_pcie),    
      .enb(~wr_en_D), 
      .addrb(rd_addr_D),  
      .doutb(rd_data_D) 
    );
   */
       
    // state machine for decoder
    reg [1:0] dec_sm;
    parameter dec_rst = 2'd0;
    parameter dec_strt = 2'd1;
    parameter dec_wait = 2'd2;
    parameter dec_end = 2'd3;
        
    wire rst_dec, start_decode, end_decode;
    assign rst_dec = ~((dec_sm == dec_rst) || (dec_sm == dec_end) );
    assign start_decode = (dec_sm == dec_strt);
           
    reg dec_over;
    always @ (posedge clk_dec)
    if(reset)
    begin
    	dec_over <= 0;
    	dec_cnt <= -1;
    end
    else
    begin
    	if(dec_en)
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
 
    /*
    reg [3:0] dec_end_cnt;
    always @(posedge clk_dec)
    if(reset)
    	dec_end_cnt <= 0;
    else
    begin
    	if(dec_sm == dec_end)
    		dec_end_cnt <= dec_end_cnt + 1;
    	else
    		dec_end_cnt <= 0;
    end
   */
    
    always @ (posedge clk_dec)
    if(reset)
    	dec_sm <= dec_rst;
    else
    begin
    	case(dec_sm)
    		dec_rst :
    		begin
    			if((dec_en) && (~dec_over))
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
    		/*
    		    if(dec_end_cnt >= 3)
    		    	dec_sm <= dec_rst;
    		    else
    		        dec_sm <= dec_end;
    		*/
    		      dec_sm <= dec_rst;
    		end	
    	endcase
    end
   
    Modu_Decoder_New_CRC turbo_decoder(
    	.clk(clk_dec), 
    	.reset(rst_dec), 
    	.Start_Cmp(start_decode),
    	.CB_length(cb_length),
    	.Parallel_degree(4'd8),
    	.Iter_Max(iter_max),
    	.CRC_type(crc_type),
    	// ram data
    	.System_In_ROM(rd_data_SYS),
    	.Parity0_In_ROM(rd_data_PAR0),
    	.Parity1_In_ROM(rd_data_PAR1),
    	.Tail_In_ROM(rd_data_TAIL),
    	// ram addr
    	.Read_Addr_system(rd_addr_SYS),
    	.Read_Addr_parity(rd_addr_PAR),
    	.Read_Addr_tail(rd_addr_TAIL),
    	// output revised by shaxiaoshi
    	.CRC_result(crc_result),
    	.Decode_Result_Start(Decode_Result_Start),
    	.Decode_Result_Addr(decode_addr_D),
    	.Decode_result_D(decode_D),  // .D(D), 
    	.End_Decode(end_decode)			
    );
	
	ila_turbo_wrapper ila_turbo_wrapper_inst (
		.clk(clk_dec), // input wire clk
		.probe0(dec_cnt), // input wire [1:0]  probe0  
		.probe1(dec_sm), // input wire [1:0]  probe1 
		.probe2(dec_en), // input wire [0:0]  probe2 
		.probe3(dec_over), // input wire [0:0]  probe3 
		.probe4(end_decode), // input wire [0:0]  probe4 
		.probe5(Decode_Result_Start), // input wire [0:0]  probe5 
		.probe6(rst_dec), // input wire [0:0]  probe6 
		.probe7(start_decode) // input wire [0:0]  probe7
	);
	
endmodule
