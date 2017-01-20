`timescale 1ns / 1ps
`include "Input_parameters.v"

module test_chnl_turbo_decoder;

	//input
	reg clk;
	reg reset;
	
	reg [127:0] rx_data;
	reg rx_valid;
	reg rx;
		
	reg tx_en;
	reg tx_ack;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		// Wait 100 ns for global reset to finish
		#500;
		reset = 1'b0;
		rx = 1'b1;
		rx_valid = 1'b1;
		rx_data = {32'd15,32'd75, 32'd0, 16'd2, 16'd40};
		#50000
		tx_en = 1'b1;
		tx_ack = 1'b1;
	end
	
   always #5 clk = ~clk;


	chnl_parallel_turbo_decoder #(9'd128)
	chnl_turbo_dec_inst
	(
		.USR_CLK(clk),
		.RST(reset),
		.CHNL_RX_CLK(), 
		.CHNL_RX(rx), 
		.CHNL_RX_ACK(), 
		.CHNL_RX_LAST(), 
		.CHNL_RX_LEN(), 
		.CHNL_RX_OFF(), 
		.CHNL_RX_DATA(rx_data), 
		.CHNL_RX_DATA_VALID(rx_valid), 
		.CHNL_RX_DATA_REN(),
		
		.CHNL_TX_CLK(), 
		.CHNL_TX(), 
		.CHNL_TX_ACK(tx_ack), 
		.CHNL_TX_LAST(), 
		.CHNL_TX_LEN(), 
		.CHNL_TX_OFF(), 
		.CHNL_TX_DATA(), 
		.CHNL_TX_DATA_VALID(), 
		.CHNL_TX_DATA_REN(tx_en)
	);
endmodule


