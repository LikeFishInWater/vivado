/******************************************************************************
* Copyright (c) NCRL Coding Group.
* All right reserved.
*
* Filename: Modu_Subdecoder.v
* Abstract: This is the verilog file that define the subdecoder
				最大并行度定为8时，所用Number of Slice Registers大约为11000；最大并行度定为4时，降为6000
*
* Version:  V5.1
* Author:   Duck
* Time:		2012-04-01
*
******************************************************************************/

`timescale 1ns / 1ps
`include "Input_parameters.v"

module Modu_Subdecoder(
	//input.译码数据、译码结果、BPU、FPU初值均存储于该模块的RAM中，
	clk,reset,Init_flag,enable_Subde,Iter_Max,Iter,decMode,r,q_up,decNum,blockSize,Rf2,Qf2,
	Req_A_Init,Req_Rf_Init,Req_Qf_Init,Req_Rg_Init,Req_Qg_Init,B,
	SystemBit,ParityBit0,ParityBit1,TailBit,D_r_ad,
	//SystemBit,ParityBit0,ParityBit1,SYS_PAR_Ram_w_addr,SYS_PAR_Ram_w,
	//TailBit,Tail_RAM_w_addr,Tail_RAM_w,D_r_ad,
	
	//output
	decode_result,Le_sys_data_sort,Le_par0_data_sort,Le_par1_data_sort,end_Subde,
	AddrSL,AddrP,BPU_tail_Ad
	);
	//input
	input clk;
	input reset;//只在控制单元中使用，其余单元中不用
	input Init_flag;//初始化信号
	input enable_Subde;//译码使能信号，防止译码结束后分量译码器继续工作
	input [3:0] Iter_Max;
	input [3:0] Iter;
	input decMode;
	input [`window_width-1:0] r;
	input [3:0] q_up;
	input [3:0] decNum;
	input [`Data_Addr_width-1:0] blockSize;
	input [`Data_Addr_width-1:0] Rf2;
	input [2:0] Qf2;
	input [`Data_Addr_width-1:0] Req_A_Init;
	input [`Data_Addr_width-1:0] Req_Rf_Init;
	input [23:0] Req_Qf_Init;
	input [`Data_Addr_width-1:0] Req_Rg_Init;
	input [23:0] Req_Qg_Init;
	input [`window_width:0] B;
	
	input [`sys_par_width*8-1:0] SystemBit;
	input [`sys_par_width*8-1:0] ParityBit0;
	input [`sys_par_width*8-1:0] ParityBit1;
	
	//input [`Data_Addr_width-1:0] SYS_PAR_Ram_w_addr;//将外部ROM中的数据写入subdecoder的译码数据RAM中的写地址
	//input SYS_PAR_Ram_w;//SYS_Ram和PAR_Ram的读写信号
	input [`sys_par_width*2-1:0] TailBit;
	//input [2:0] Tail_RAM_w_addr;//每个地址单元中存储有一个校验比特和一个系统比特，共需要6个存储单元
	//input Tail_RAM_w;
	input [`Data_Addr_width-1:0] D_r_ad;
	
	//output
	//output [`Parallel_degree-1:0] decode_result;
	//output [`Le_sys_par_width*`Parallel_degree-1:0] Le_sys_data_sort;
	//output [`Le_sys_par_width*`Parallel_degree-1:0] Le_par0_data_sort;
	//output [`Le_sys_par_width*`Parallel_degree-1:0] Le_par1_data_sort;
	output [7:0] decode_result;
	output [`Le_sys_par_width*8-1:0] Le_sys_data_sort;
	output [`Le_sys_par_width*8-1:0] Le_par0_data_sort;
	output [`Le_sys_par_width*8-1:0] Le_par1_data_sort;
	
	output end_Subde;//分量译码器译码完毕的信号
	
	output [`Data_Addr_width-1:0] AddrSL;//read address for the system bits. output for outer ram
	output [`Data_Addr_width-1:0] AddrP;//read address for the parity bits. output for outer ram
	output [2:0] BPU_tail_Ad;
	
	reg end_Subde;
	
	//计算单元的控制信号
	reg [`CmpCounter_width-1:0] CmpCounter;
	reg Init_Flag_BPU_tail;					//BPU_Tail的递推初始化信号
	reg Updata_BPUtail_beta;				//BPU_Tail计算结果保存以用于BPU计算的保存信号
	reg Init_Flag_FPU;						//FPU初始化信号，每次内迭代出现1次
	reg Updata_FPU_alpha;					//FPU的计算结果保存以用于下次内迭代
	reg Updata_FPU_alpha_delay;			//Init_Value中存放FPU计算结果的辅助信号
	reg Updata_BPUtail_beta_delay;		//Init_Value中存放BPU_Tail计算结果的辅助信号
	reg Init_Flag_BPU_M;						//BPU的中间滑窗的初始化信号
	reg Init_Flag_BPU_L;						//BPU的最后一个滑窗的初始化信号
	reg Updata_BPU_beta;						//BPU的计算结果保存以用于下次内迭代
	reg FPU_Init_Req;							//Init_Value中用于提醒系统输出FPU计算初值的信号
	reg BPU_Init_Req;							//Init_Value中用于提醒系统输出BPU计算初值的信号
	
	//译码所需数据
	wire [`sys_par_width*8-1:0] ParityBit;//从输入的ParityBit0和ParityBit1中选择一个进行交织后进行译码计算
	wire [`sys_par_width*2-1:0] BPU_tail_data_In;//送给BPU_Tail模块
	wire [`sys_par_width*8-1:0] Sys_data_sort;
	wire [`sys_par_width*8-1:0] Par_data_sort;
	//wire [`Le_sys_par_width*`Parallel_degree-1:0] Le_sys_data_sort;
	//wire [`Le_sys_par_width*`Parallel_degree-1:0] Le_par0_data_sort;//译码器提供的校验位软量
	//wire [`Le_sys_par_width*`Parallel_degree-1:0] Le_par1_data_sort;
	wire [`Le_sys_par_width*8-1:0] Le_sys_data_sort;
	wire [`Le_sys_par_width*8-1:0] Le_par0_data_sort;//译码器提供的校验位软量
	wire [`Le_sys_par_width*8-1:0] Le_par1_data_sort;
	
	//地址控制单元的输出与其他模块的接口
	wire [`Data_Addr_width-1:0] read_Ad_Le;	//output of Addr_control
	wire [23:0] resort_Ad_Le;
	wire [`Data_Addr_width-1:0] AddrSL;	//output of Addr_control
	wire [23:0] resortSL_delay;			//output of Addr_control
	wire [`Data_Addr_width-1:0] AddrP;	//output of Addr_control
	wire [23:0] resortP_delay;				//output of Addr_control
	wire [`Data_Addr_width-1:0] Le_w_ad;//output of Addr_control
	wire [23:0] Le_w_sort;					//output of Addr_control
	wire Le_w;									//output of Addr_control
	wire [`window_width-1:0] Ad_BUFA_read;//output of Addr_control
	//wire [`window_width-1:0] Ad_BUFA_write;//在SW-MAP中实现
	wire dir_BUFA;
	wire [`window_width-1:0] Ad_BUF0;	//output of Addr_control
	wire [`window_width-1:0] Ad_BUF1;	//output of Addr_control
	wire [`window_width-1:0] Ad_BUF2;	//output of Addr_control
	wire BUFA_w;								//output of Addr_control
	wire BUF0_w;								//output of Addr_control
	wire BUF1_w;								//output of Addr_control
	wire BUF2_w;								//output of Addr_control
	wire [1:0] id_FPU;						//output of Addr_control
	wire [1:0] id_BPU;						//output of Addr_control
	wire [2:0] BPU_tail_Ad;					//output of Addr_control
	wire [`Data_Addr_width-1:0] Le_w_ad_delay4;
	wire [`Data_Addr_width-1:0] w_ad_Le_par1;//Add at 2012.10.18
	wire [`Data_Addr_width-1:0] w_ad_Le_par1_delay4;//Add at 2012.10.18
	wire [23:0] Le_w_sort_delay3;
	wire Le_w_delay4;
	reg [`Data_Addr_width-1:0] Le_w_ad_delay1;
	reg Le_w_delay1;
	wire [3:0] BUF_w;							//{BUFA_w,BUF2_w,BUF1_w,BUF0_w}
	
	//output_value of FPU、BPU、BPU_Tail
	wire [`beta_alpha_width*8-1:0] Beta_tail_In;	//output of BPU_Tail==input of Init_Value unit
	wire [`beta_alpha_width*8-1:0] Beta0,Beta1,Beta2,Beta3,Beta4,Beta5,Beta6,Beta7;//output of SW-MAP,input of Init_Value
	wire [`beta_alpha_width*8-1:0] Alph0,Alph1,Alph2,Alph3,Alph4,Alph5,Alph6,Alph7;//output of SW-MAP,input of Init_Value
	wire [`beta_alpha_width*8-1:0] InitBeta0,InitBeta1,InitBeta2,InitBeta3,InitBeta4,InitBeta5,InitBeta6,InitBeta7;//output of Init_Value,input of SW-MAP
	//when q_up=2,the initial mode cann't init the second SW of each BPU in SW-decoder correctly.Because it should store the beta_value from the 1st SW first,
	//and then read for the next SW. So, for the code block that has only 2 SW in each subdecoder, the InitBeta should be modified
	wire [`beta_alpha_width*8-1:0] InitBeta0_2SW,InitBeta1_2SW,InitBeta2_2SW,InitBeta3_2SW,InitBeta4_2SW,InitBeta5_2SW,InitBeta6_2SW,InitBeta7_2SW;
	reg [`beta_alpha_width*8-1:0] Beta_tail_result;
	
	wire [`beta_alpha_width*8-1:0] InitAlph0,InitAlph1,InitAlph2,InitAlph3,InitAlph4,InitAlph5,InitAlph6,InitAlph7;//output of Init_Value,input of SW-MAP
	wire D0,D1,D2,D3,D4,D5,D6,D7;
	wire [`Le_sys_par_width-1:0] Le_sys0,Le_sys1,Le_sys2,Le_sys3,Le_sys4,Le_sys5,Le_sys6,Le_sys7;
	wire [`Le_sys_par_width-1:0] Le_par0,Le_par1,Le_par2,Le_par3,Le_par4,Le_par5,Le_par6,Le_par7;
	wire [7:0] D_RAM_In;
	wire [`Le_sys_par_width*8-1:0] Le_sys_RAM_In,Le_par_RAM_In;
	assign D_RAM_In = {D7,D6,D5,D4,D3,D2,D1,D0};
	assign Le_sys_RAM_In = {Le_sys7,Le_sys6,Le_sys5,Le_sys4,Le_sys3,Le_sys2,Le_sys1,Le_sys0};
	assign Le_par_RAM_In = {Le_par7,Le_par6,Le_par5,Le_par4,Le_par3,Le_par2,Le_par1,Le_par0};
	
	wire [`sys_par_width-1:0] Sys_SW0,Sys_SW1,Sys_SW2,Sys_SW3,Sys_SW4,Sys_SW5,Sys_SW6,Sys_SW7;
	wire [`sys_par_width-1:0] Par_SW0,Par_SW1,Par_SW2,Par_SW3,Par_SW4,Par_SW5,Par_SW6,Par_SW7;
	wire [`Le_sys_par_width-1:0] La_SW0,La_SW1,La_SW2,La_SW3,La_SW4,La_SW5,La_SW6,La_SW7;
	
	assign read_Ad_Le = (Iter == Iter_Max) ? D_r_ad : AddrSL;
	assign resort_Ad_Le = (Iter == Iter_Max) ? {3'b111,3'b110,3'b101,3'b100,3'b011,3'b010,3'b001,3'b000} : resortSL_delay;
	
	assign Sys_SW0 = Sys_data_sort[`sys_par_width-1:0];
	assign Sys_SW1 = Sys_data_sort[`sys_par_width*2-1:`sys_par_width];
	assign Sys_SW2 = Sys_data_sort[`sys_par_width*3-1:`sys_par_width*2];
	assign Sys_SW3 = Sys_data_sort[`sys_par_width*4-1:`sys_par_width*3];
	assign Sys_SW4 = Sys_data_sort[`sys_par_width*5-1:`sys_par_width*4];
	assign Sys_SW5 = Sys_data_sort[`sys_par_width*6-1:`sys_par_width*5];
	assign Sys_SW6 = Sys_data_sort[`sys_par_width*7-1:`sys_par_width*6];
	assign Sys_SW7 = Sys_data_sort[`sys_par_width*8-1:`sys_par_width*7];
	
	assign Par_SW0 = Par_data_sort[`sys_par_width-1:0];
	assign Par_SW1 = Par_data_sort[`sys_par_width*2-1:`sys_par_width];
	assign Par_SW2 = Par_data_sort[`sys_par_width*3-1:`sys_par_width*2];
	assign Par_SW3 = Par_data_sort[`sys_par_width*4-1:`sys_par_width*3];
	assign Par_SW4 = Par_data_sort[`sys_par_width*5-1:`sys_par_width*4];
	assign Par_SW5 = Par_data_sort[`sys_par_width*6-1:`sys_par_width*5];
	assign Par_SW6 = Par_data_sort[`sys_par_width*7-1:`sys_par_width*6];
	assign Par_SW7 = Par_data_sort[`sys_par_width*8-1:`sys_par_width*7];
	
	assign La_SW0 = Le_sys_data_sort[`Le_sys_par_width-1:0];
	assign La_SW1 = Le_sys_data_sort[`Le_sys_par_width*2-1:`Le_sys_par_width];
	assign La_SW2 = Le_sys_data_sort[`Le_sys_par_width*3-1:`Le_sys_par_width*2];
	assign La_SW3 = Le_sys_data_sort[`Le_sys_par_width*4-1:`Le_sys_par_width*3];
	assign La_SW4 = Le_sys_data_sort[`Le_sys_par_width*5-1:`Le_sys_par_width*4];
	assign La_SW5 = Le_sys_data_sort[`Le_sys_par_width*6-1:`Le_sys_par_width*5];
	assign La_SW6 = Le_sys_data_sort[`Le_sys_par_width*7-1:`Le_sys_par_width*6];
	assign La_SW7 = Le_sys_data_sort[`Le_sys_par_width*8-1:`Le_sys_par_width*7];
	
	//其他辅助变量
	wire [`window_width+1:0] B_mul_2;
	wire [`window_width+1:0] B_mul_3;
	wire [`CmpCounter_width-1:0] CmpCounter_sub_4;
	wire [`CmpCounter_width:0] BLOCK_SIZE_add_2B;
	wire [`CmpCounter_width:0] BLOCK_SIZE_add_2B_14;
	wire [`CmpCounter_width:0] BLOCK_SIZE_add_B;
	wire [`CmpCounter_width:0] BLOCK_SIZE_add_B_4;
	//add
	wire [`CmpCounter_width-1:0] q_up_add1_mulB_add4;
	
	assign q_up_add1_mulB_add4 = ((q_up + 1'b1) << `window_width) + 4'b0100;
	
	assign B_mul_2 = B << 1;
	assign B_mul_3 = B_mul_2 + {1'b0,B};
	assign CmpCounter_sub_4 = CmpCounter - 3'b100;
	assign BLOCK_SIZE_add_2B = {1'b0,blockSize} + B_mul_2;
	assign BLOCK_SIZE_add_2B_14 = BLOCK_SIZE_add_2B + 4'b1110;
	assign BLOCK_SIZE_add_B = {1'b0,blockSize} + B;
	assign BLOCK_SIZE_add_B_4 = BLOCK_SIZE_add_B + 3'b100;
	assign BUF_w = {BUFA_w,BUF2_w,BUF1_w,BUF0_w};
	
	//when q_up=2,the initial mode cann't init the second SW of each BPU in SW-decoder correctly.Because it should store the beta_value from the 1st SW first,
	//and then read for the next SW. So, for the code block that has only 2 SW in each subdecoder, the InitBeta should be modified
	//assign InitBeta0_2SW = (q_up == 4'b0010 && CmpCounter == 197) ? Beta1 : InitBeta0;
	assign InitBeta0_2SW = (q_up == 4'b0010 && Init_Flag_BPU_L == 1'b1) ? Beta1 : InitBeta0;
	assign InitBeta1_2SW = (q_up == 4'b0010 && Init_Flag_BPU_L == 1'b1) ? Beta2 : InitBeta1;
	assign InitBeta2_2SW = (q_up == 4'b0010 && Init_Flag_BPU_L == 1'b1) ? Beta3 : InitBeta2;
	assign InitBeta3_2SW = (q_up == 4'b0010 && Init_Flag_BPU_L == 1'b1) ? Beta4 : InitBeta3;
	assign InitBeta4_2SW = (q_up == 4'b0010 && Init_Flag_BPU_L == 1'b1) ? Beta5 : InitBeta4;
	assign InitBeta5_2SW = (q_up == 4'b0010 && Init_Flag_BPU_L == 1'b1) ? Beta6 : InitBeta5;
	assign InitBeta6_2SW = (q_up == 4'b0010 && Init_Flag_BPU_L == 1'b1) ? Beta7 : InitBeta6;
	assign InitBeta7_2SW = (q_up <= 4'b0010 && Init_Flag_BPU_L == 1'b1) ? Beta_tail_result : InitBeta7;
	
	//store the result of BPU_tail for the code length that has only 2 SW in a subdecoder
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Beta_tail_result <= 0;
		end
		else if(Updata_BPUtail_beta == 1'b1)
		begin
			Beta_tail_result <= Beta_tail_In;
		end
		else
		begin
			Beta_tail_result <= Beta_tail_result;
		end
	end
	//CmpCounter控制信号
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0 || Init_flag == 1'b1 || CmpCounter == BLOCK_SIZE_add_2B_14)
		begin
			CmpCounter <= 0;
		end
		else if(enable_Subde == 1'b1)
		begin
			CmpCounter <= CmpCounter + 1'b1;
		end
		else
		begin
			CmpCounter <= CmpCounter;
		end
	end
	//end_Subde
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			end_Subde <= 1'b0;
		end
		else if(CmpCounter == BLOCK_SIZE_add_2B_14)
		begin
			end_Subde <= 1'b1;
		end
		else
		begin
			end_Subde <= 1'b0;
		end
	end
	//Addr_control的输出延时
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			Le_w_ad_delay1 <= 0;
			Le_w_delay1 <= 0;
		end
		else
		begin
			Le_w_ad_delay1 <= Le_w_ad;
			Le_w_delay1 <= Le_w;
		end
	end
/*	SRL16	//delay 4
	Le_w_ad_Delay [`Data_Addr_width-1:0] (.Q(Le_w_ad_delay4),.A0(1'b1),.A1(1'b1),.A2(1'b0),.A3(1'b0),.CLK(clk),.D(Le_w_ad));
	SRL16	//delay 4
	Le_w_Delay [0:0] (.Q(Le_w_delay4),.A0(1'b1),.A1(1'b1),.A2(1'b0),.A3(1'b0),.CLK(clk),.D(Le_w));
	SRL16	//delay 3
	Le_sort_Delay [23:0] (.Q(Le_w_sort_delay3),.A0(1'b0),.A1(1'b1),.A2(1'b0),.A3(1'b0),.CLK(clk),.D(Le_w_sort));
*/
	Modu_Shift_Reg8	//delay 4
	#(`Data_Addr_width) Le_w_ad_Delay(.clk(clk),.delay(3'b011),.data_in(Le_w_ad),.data_out(Le_w_ad_delay4));
	Modu_Shift_Reg8	//delay 4
	#(`Data_Addr_width) w_ad_Le_par1_Delay(.clk(clk),.delay(3'b011),.data_in(w_ad_Le_par1),.data_out(w_ad_Le_par1_delay4));
	Modu_Shift_Reg8	//delay 4
	#(1) Le_w_Delay(.clk(clk),.delay(3'b011),.data_in(Le_w),.data_out(Le_w_delay4));
	
	Modu_Shift_Reg8	//delay 3
	#(24) Le_sort_Delay(.clk(clk),.delay(3'b010),.data_in(Le_w_sort),.data_out(Le_w_sort_delay3));
	
	/*Control signals for BPU_Tail unit*/
	always @(posedge clk or negedge reset)//1时BPU_tail的初始信号有效
	begin
		if(reset == 1'b0)
		begin
			Init_Flag_BPU_tail <= 1'b0;
		end
		else if(CmpCounter == 0)
		begin
			Init_Flag_BPU_tail <= 1'b1;
		end
		else
		begin
			Init_Flag_BPU_tail <= 1'b0;
		end
	end
	always @(posedge clk or negedge reset)//4时updata信号有效
	begin
		if(reset == 1'b0)
		begin
			Updata_BPUtail_beta <= 1'b0;
		end
		else if(CmpCounter == 3)
		begin
			Updata_BPUtail_beta <= 1'b1;
		end
		else
		begin
			Updata_BPUtail_beta <= 1'b0;
		end
	end
	always @(posedge clk or negedge reset)//3B+5时Updata_BPUtail_beta_delay信号有效
	begin
		if(reset == 1'b0)
		begin
			Updata_BPUtail_beta_delay <= 1'b0;
		end
//		else if(CmpCounter == B_mul_3 + 4)
		else if(((q_up >= 4'd2) && (CmpCounter == B_mul_3 + 4)) || ((q_up == 4'd1) && (CmpCounter == BLOCK_SIZE_add_2B + 4)) ) // revised by shaxiaoshi 2016.3.8, consider the actual first window size is less than B
		begin
			Updata_BPUtail_beta_delay <= 1'b1;
		end
		else
		begin
			Updata_BPUtail_beta_delay <= 1'b0;
		end
	end
	/*Control signals for BPU_Tail unit*/
	
	/*Control signals for FPU unit*/
	always @(posedge clk or negedge reset)//B+5时FPU的初始信号有效
	begin
		if(reset == 1'b0)
		begin
			Init_Flag_FPU <= 1'b0;
		end
		else if(CmpCounter == B + 4)
		begin
			Init_Flag_FPU <= 1'b1;
		end
		else
		begin
			Init_Flag_FPU <= 1'b0;
		end
	end
	always @(posedge clk or negedge reset)//NB+B+5时updata信号有效
	begin
		if(reset == 1'b0)
		begin
			Updata_FPU_alpha <= 1'b0;
		end
		else if(CmpCounter == BLOCK_SIZE_add_B_4)
		begin
			Updata_FPU_alpha <= 1'b1;
		end
		else
		begin
			Updata_FPU_alpha <= 1'b0;
		end
	end
	always @(posedge clk or negedge reset)//NB+2B+6时信号有效
	begin
		if(reset == 1'b0)
		begin
			Updata_FPU_alpha_delay <= 1'b0;
		end
		else if(CmpCounter == BLOCK_SIZE_add_2B + 5)
		begin
			Updata_FPU_alpha_delay <= 1'b1;
		end
		else
		begin
			Updata_FPU_alpha_delay <= 1'b0;
		end
	end	
	/*Control signals for FPU unit*/
	
	/*Control signals for BPU unit*/
	always @(posedge clk or negedge reset)//Init_Flag_BPU_M在2B+5、3B+5...NB+5时有效
	begin
		if(reset == 1'b0)
		begin
			Init_Flag_BPU_M <= 1'b0;
		end
		else if((CmpCounter > B_mul_2) && (CmpCounter <= BLOCK_SIZE_add_B + 4) && (CmpCounter_sub_4[`window_width-1:0] == 0)) // revised by shaxiaoshi 2016.3.6, CmpCounter <= BLOCK_SIZE_add_B  *** + 4 ***
		begin
			Init_Flag_BPU_M <= 1'b1;
		end
		else
		begin
			Init_Flag_BPU_M <= 1'b0;
		end
	end
	always @(posedge clk or negedge reset)//Init_Flag_BPU_L在BLOCK_SIZE+B+5时有效
	begin
		if(reset ==1'b0)
		begin
			Init_Flag_BPU_L <= 1'b0;
		end
		else if(CmpCounter == q_up_add1_mulB_add4)
		begin
			Init_Flag_BPU_L <= 1'b1;
		end
		else
		begin
			Init_Flag_BPU_L <= 1'b0;
		end
	end
	always @(posedge clk or negedge reset)//Updata_BPU_beta在3B+5、4B+5...BLOCK_SIZE+2B+5时有效
	begin
		if(reset == 1'b0)
		begin
			Updata_BPU_beta <= 1'b0;
		end
		//else if((CmpCounter > B_mul_3) && (CmpCounter_sub_4[`window_width-1:0] == 0))///////////////////////////////////////////////////modified
		else if(((CmpCounter > B_mul_3) && ((r==0 && CmpCounter_sub_4[`window_width-1:0]==0)||
		(r!=0 && ((CmpCounter <= BLOCK_SIZE_add_2B + 4 && CmpCounter_sub_4[`window_width-1:0]==0) || (CmpCounter>BLOCK_SIZE_add_2B && CmpCounter==BLOCK_SIZE_add_2B+4))))) 
		|| ((q_up == 4'd1) && (CmpCounter == BLOCK_SIZE_add_2B + 4))
		) // revised by shaxiaoshi 2016.3.6 (CmpCounter <= BLOCK_SIZE_add_2B *** + 4 *** && CmpCounter_sub_4[`window_width-1:0]==0)
		begin
			Updata_BPU_beta <= 1'b1;
		end
		else
		begin
			Updata_BPU_beta <= 1'b0;
		end
	end
	/*Control signals for BPU unit*/
	
	/*Control signals for Init_Value uint*/
	always @(posedge clk or negedge reset)//B+2时FPU_Init_Req有效
	begin
		if(reset == 1'b0)
		begin
			FPU_Init_Req <= 1'b0;
		end
		else if(CmpCounter == B + 1)
		begin
			FPU_Init_Req <= 1'b1;
		end
		else
		begin
			FPU_Init_Req <= 1'b0;
		end
	end
	always @(posedge clk or negedge reset)//BPU_Init_Req在2B+2、3B+2...NB+B+2时有效
	begin
		if(reset ==1'b0)
		begin
			BPU_Init_Req <= 1'b0;
		end
		else if((CmpCounter > B_mul_2) && (CmpCounter < BLOCK_SIZE_add_2B) && (CmpCounter[`window_width-1:0] == 1))
		begin
			BPU_Init_Req <= 1'b1;
		end
		else
		begin
			BPU_Init_Req <= 1'b0;
		end
	end


/*********the SystemBit_RAM and ParityBit_RAM should are be uncommented when for the decoder test singly********/
//	//Tail_RAM :[Parity,System]*6
//	/*以6个字长为`sys_par_width*2的reg来实现尾信息的存储和读取*/
//	Modu_Distributed_Dual_RAM_tail #((`sys_par_width*2),3) TailBit_RAM(
//	.clk(clk),.write_address(Tail_RAM_w_addr),.write_enable(Tail_RAM_w),.input_data(TailBit),.read_address(BPU_tail_Ad),
//	.output_data(BPU_tail_data_In));
	
	//SystemBit_RAM :[System7,System6,System5,System4,System3,System2,System1,System0]*768
//	Modu_SystemBit_RAM SystemBit_RAM(
//	//input
//	.clk(clk),.SystemBit_In(SystemBit),.SYS_Ram_w_addr(SYS_PAR_Ram_w_addr),.SYS_Ram_w(SYS_PAR_Ram_w),
//	.AddrSL(AddrSL),.resortSL(resortSL_delay),
//	//output
//	.Sys_data_sort(Sys_data_sort)
//	);
	
	//ParityBit_RAM :[Parity07,Parity06,Parity05,Parity04,Parity03,Parity02,Parity01,Parity00]*768 
	//					  [Parity17,Parity16,Parity15,Parity14,Parity13,Parity12,Parity11,Parity10]*768
//	Modu_ParityBit_RAM ParityBit_RAM(
//	//input
//	.clk(clk),.decMode(decMode),.ParityBit0_In(ParityBit0),.ParityBit1_In(ParityBit1),
//	.PAR_Ram_w_addr(SYS_PAR_Ram_w_addr),.PAR_Ram_w(SYS_PAR_Ram_w),
//	.AddrP(AddrP),.resortP(resortP_delay),
//	//output
//	.Par_data_sort(Par_data_sort)
//	);
/*********the SystemBit_RAM and ParityBit_RAM should are be uncommented when for the decoder test singly********/

/***********************add for the joint debugging for all the modules in LTE DL**************************/
	Modu_Reorder_writeEn_0 #(`sys_par_width) Reorder_SystemBit(
	//input
	.clk(clk),.data_in(SystemBit),.resortSE(resortSL_delay),
	//output
	.data_out(Sys_data_sort)
	);
	
	assign ParityBit = (decMode == 1'b0) ? ParityBit0 : ParityBit1;
	
	Modu_Reorder_writeEn_0 #(`sys_par_width) Reorder_ParityBit(
	//input
	.clk(clk),.data_in(ParityBit),.resortSE(resortP_delay),
	//output
	.data_out(Par_data_sort)
	);
/***********************add for the joint debugging for all the modules in LTE DL**************************/

	//Le_sysBit and Le_parBit RAM :[Le_sys*8]*768 [Le_par*8]*768
	Modu_LeBit_RAM LeBit_RAM(
	//input
	.clk(clk),.Le_sysBit_In(Le_sys_RAM_In),.Le_parBit_In(Le_par_RAM_In),.Le_w_ad_delay4(Le_w_ad_delay4),
	.Le_w_sort_delay3(Le_w_sort_delay3),.Le_w_delay4(Le_w_delay4),.AddrSL(read_Ad_Le),.resortSL(resort_Ad_Le),
	.Iter_Max(Iter_Max),.Iter(Iter),.decMode(decMode),
	.w_ad_Le_par1_delay4(w_ad_Le_par1_delay4),//Add at 2012.10.18
	//output
	.Le_sysBit_Out_sort(Le_sys_data_sort),.Le_parBit0_Out_sort(Le_par0_data_sort),.Le_parBit1_Out_sort(Le_par1_data_sort)
	);
	
	//D_RAM, the decoding result :[D*8]*768
	Modu_D_RAM D_RAM(
	//input
	.clk(clk),.D_In(D_RAM_In),.Le_w_ad_delay1(Le_w_ad_delay1),.Le_w_sort(Le_w_sort),.Le_w_delay1(Le_w_delay1),
	.D_r_ad(D_r_ad),
	.decMode(decMode), // add by shaxiaoshi 2016.5.5
	//output
	.D_out(decode_result)
	);
	
	/*Addr_control uint*/
	Modu_Addr_control Addr_control(
	//input
	.clk(clk),.reset(reset),.Init_flag(Init_flag),.CmpCounter(CmpCounter),.decMode(decMode),.r(r),.q_up(q_up),
	.decNum(decNum),.blockSize(blockSize),.Rf2(Rf2),.Qf2(Qf2),.Req_A_Init(Req_A_Init),
	.Req_Rf_Init(Req_Rf_Init),.Req_Qf_Init(Req_Qf_Init),.Req_Rg_Init(Req_Rg_Init),.Req_Qg_Init(Req_Qg_Init),.B(B),
	//output
	.AddrP(AddrP),.resortP_delay(resortP_delay),.AddrSL(AddrSL),.resortSL_delay(resortSL_delay),
	.Le_w_ad(Le_w_ad),.Le_w_sort(Le_w_sort),.Le_w(Le_w),.dir_BUFA(dir_BUFA),
	.Ad_BUFA_read(Ad_BUFA_read),.Ad_BUF0(Ad_BUF0),.Ad_BUF1(Ad_BUF1),.Ad_BUF2(Ad_BUF2),
	.BUFA_w(BUFA_w),.BUF0_w(BUF0_w),.BUF1_w(BUF1_w),.BUF2_w(BUF2_w),
	.id_FPU(id_FPU),.id_BPU(id_BPU),.BPU_tail_Ad(BPU_tail_Ad),
	.w_ad_Le_par1(w_ad_Le_par1)//Add at 2012.10.18
	);
	
	/*Init_Value uint*/
	Modu_Init_Value Init_Value(
	//input
	.clk(clk),.q_up(q_up),.decMode(decMode),.decNum(decNum),
	.BPU_Init_Req(BPU_Init_Req),.FPU_Init_Req(FPU_Init_Req),.Updata_BPUtail_beta(Updata_BPUtail_beta),
	.Updata_FPU_alpha(Updata_FPU_alpha),.Updata_BPU_beta(Updata_BPU_beta),.Updata_FPU_alpha_delay(Updata_FPU_alpha_delay),
	.Updata_BPUtail_beta_delay(Updata_BPUtail_beta_delay),.Beta_tail_In(Beta_tail_In),
	.Beta_BPU0_In(Beta0),.Beta_BPU1_In(Beta1),.Beta_BPU2_In(Beta2),.Beta_BPU3_In(Beta3),
	.Beta_BPU4_In(Beta4),.Beta_BPU5_In(Beta5),.Beta_BPU6_In(Beta6),.Beta_BPU7_In(Beta7),
	.Alph_FPU0_In(Alph0),.Alph_FPU1_In(Alph1),.Alph_FPU2_In(Alph2),.Alph_FPU3_In(Alph3),
	.Alph_FPU4_In(Alph4),.Alph_FPU5_In(Alph5),.Alph_FPU6_In(Alph6),.Alph_FPU7_In(Alph7),
	//output
	.Beta_out0(InitBeta0),.Beta_out1(InitBeta1),.Beta_out2(InitBeta2),.Beta_out3(InitBeta3),
	.Beta_out4(InitBeta4),.Beta_out5(InitBeta5),.Beta_out6(InitBeta6),.Beta_out7(InitBeta7),
	.Alph_out0(InitAlph0),.Alph_out1(InitAlph1),.Alph_out2(InitAlph2),.Alph_out3(InitAlph3),
	.Alph_out4(InitAlph4),.Alph_out5(InitAlph5),.Alph_out6(InitAlph6),.Alph_out7(InitAlph7)
	);
	
	/*BPU_tail unit*/
	/*CmpCounter==2输出开始有效，存储CmpCounter==4的输出值*///.BPU_tail_data_In()如果为单独调试译码器，则填BPU_tail_data_In；若为联调，则填TailBit
	Modu_BPU_Tail BPU_Tail(
	//input
	.clk(clk),.Init_Flag_BPU_tail(Init_Flag_BPU_tail),.BPU_tail_data_In(TailBit),
	//output
	.Beta_temp(Beta_tail_In)
	);
	
	Modu_SW_MAP_3BUF SW_MAP_3BUF_0(
	//input
	.clk(clk),.Iter(Iter),.decMode(decMode),.blockIndex(3'b000),.decNum(decNum),
	.System(Sys_SW0),.Parity(Par_SW0),.La(La_SW0),.dir_BUFA(dir_BUFA),
	.Ad_BUFA_read(Ad_BUFA_read),.Ad_BUF0(Ad_BUF0),.Ad_BUF1(Ad_BUF1),.Ad_BUF2(Ad_BUF2),.BUF_w(BUF_w),
	.id_FPU(id_FPU),.id_BPU(id_BPU),.Init_Flag_BPU_M(Init_Flag_BPU_M),.Init_Flag_BPU_L(Init_Flag_BPU_L),
	.Init_Flag_FPU(Init_Flag_FPU),.initBeta(InitBeta0_2SW),.initAlpha(InitAlph0),
	.q_up(q_up), // add by shaxiaoshi 2016.3.8
	//output
	.BPU_beta_out_next(Beta0),.FPU_alpha_out_next(Alph0),
	.D(D0),.Le_sys(Le_sys0),.Le_par(Le_par0)
	);
	
	Modu_SW_MAP_3BUF SW_MAP_3BUF_1(
	//input
	.clk(clk),.Iter(Iter),.decMode(decMode),.blockIndex(3'b001),.decNum(decNum),
	.System(Sys_SW1),.Parity(Par_SW1),.La(La_SW1),.dir_BUFA(dir_BUFA),
	.Ad_BUFA_read(Ad_BUFA_read),.Ad_BUF0(Ad_BUF0),.Ad_BUF1(Ad_BUF1),.Ad_BUF2(Ad_BUF2),.BUF_w(BUF_w),
	.id_FPU(id_FPU),.id_BPU(id_BPU),.Init_Flag_BPU_M(Init_Flag_BPU_M),.Init_Flag_BPU_L(Init_Flag_BPU_L),
	.Init_Flag_FPU(Init_Flag_FPU),.initBeta(InitBeta1_2SW),.initAlpha(InitAlph1),
	.q_up(q_up), // add by shaxiaoshi 2016.3.8
	//output
	.BPU_beta_out_next(Beta1),.FPU_alpha_out_next(Alph1),
	.D(D1),.Le_sys(Le_sys1),.Le_par(Le_par1)
	);
	
	Modu_SW_MAP_3BUF SW_MAP_3BUF_2(
	//input
	.clk(clk),.Iter(Iter),.decMode(decMode),.blockIndex(3'b010),.decNum(decNum),
	.System(Sys_SW2),.Parity(Par_SW2),.La(La_SW2),.dir_BUFA(dir_BUFA),
	.Ad_BUFA_read(Ad_BUFA_read),.Ad_BUF0(Ad_BUF0),.Ad_BUF1(Ad_BUF1),.Ad_BUF2(Ad_BUF2),.BUF_w(BUF_w),
	.id_FPU(id_FPU),.id_BPU(id_BPU),.Init_Flag_BPU_M(Init_Flag_BPU_M),.Init_Flag_BPU_L(Init_Flag_BPU_L),
	.Init_Flag_FPU(Init_Flag_FPU),.initBeta(InitBeta2_2SW),.initAlpha(InitAlph2),
	.q_up(q_up), // add by shaxiaoshi 2016.3.8
	//output
	.BPU_beta_out_next(Beta2),.FPU_alpha_out_next(Alph2),
	.D(D2),.Le_sys(Le_sys2),.Le_par(Le_par2)
	);
	
	Modu_SW_MAP_3BUF SW_MAP_3BUF_3(
	//input
	.clk(clk),.Iter(Iter),.decMode(decMode),.blockIndex(3'b011),.decNum(decNum),
	.System(Sys_SW3),.Parity(Par_SW3),.La(La_SW3),.dir_BUFA(dir_BUFA),
	.Ad_BUFA_read(Ad_BUFA_read),.Ad_BUF0(Ad_BUF0),.Ad_BUF1(Ad_BUF1),.Ad_BUF2(Ad_BUF2),.BUF_w(BUF_w),
	.id_FPU(id_FPU),.id_BPU(id_BPU),.Init_Flag_BPU_M(Init_Flag_BPU_M),.Init_Flag_BPU_L(Init_Flag_BPU_L),
	.Init_Flag_FPU(Init_Flag_FPU),.initBeta(InitBeta3_2SW),.initAlpha(InitAlph3),
	.q_up(q_up), // add by shaxiaoshi 2016.3.8
	//output
	.BPU_beta_out_next(Beta3),.FPU_alpha_out_next(Alph3),
	.D(D3),.Le_sys(Le_sys3),.Le_par(Le_par3)
	);
	
	Modu_SW_MAP_3BUF SW_MAP_3BUF_4(
	//input
	.clk(clk),.Iter(Iter),.decMode(decMode),.blockIndex(3'b100),.decNum(decNum),
	.System(Sys_SW4),.Parity(Par_SW4),.La(La_SW4),.dir_BUFA(dir_BUFA),
	.Ad_BUFA_read(Ad_BUFA_read),.Ad_BUF0(Ad_BUF0),.Ad_BUF1(Ad_BUF1),.Ad_BUF2(Ad_BUF2),.BUF_w(BUF_w),
	.id_FPU(id_FPU),.id_BPU(id_BPU),.Init_Flag_BPU_M(Init_Flag_BPU_M),.Init_Flag_BPU_L(Init_Flag_BPU_L),
	.Init_Flag_FPU(Init_Flag_FPU),.initBeta(InitBeta4_2SW),.initAlpha(InitAlph4),
	.q_up(q_up), // add by shaxiaoshi 2016.3.8
	//output
	.BPU_beta_out_next(Beta4),.FPU_alpha_out_next(Alph4),
	.D(D4),.Le_sys(Le_sys4),.Le_par(Le_par4)
	);
	
	Modu_SW_MAP_3BUF SW_MAP_3BUF_5(
	//input
	.clk(clk),.Iter(Iter),.decMode(decMode),.blockIndex(3'b101),.decNum(decNum),
	.System(Sys_SW5),.Parity(Par_SW5),.La(La_SW5),.dir_BUFA(dir_BUFA),
	.Ad_BUFA_read(Ad_BUFA_read),.Ad_BUF0(Ad_BUF0),.Ad_BUF1(Ad_BUF1),.Ad_BUF2(Ad_BUF2),.BUF_w(BUF_w),
	.id_FPU(id_FPU),.id_BPU(id_BPU),.Init_Flag_BPU_M(Init_Flag_BPU_M),.Init_Flag_BPU_L(Init_Flag_BPU_L),
	.Init_Flag_FPU(Init_Flag_FPU),.initBeta(InitBeta5_2SW),.initAlpha(InitAlph5),
	.q_up(q_up), // add by shaxiaoshi 2016.3.8
	//output
	.BPU_beta_out_next(Beta5),.FPU_alpha_out_next(Alph5),
	.D(D5),.Le_sys(Le_sys5),.Le_par(Le_par5)
	);
	
	Modu_SW_MAP_3BUF SW_MAP_3BUF_6(
	//input
	.clk(clk),.Iter(Iter),.decMode(decMode),.blockIndex(3'b110),.decNum(decNum),
	.System(Sys_SW6),.Parity(Par_SW6),.La(La_SW6),.dir_BUFA(dir_BUFA),
	.Ad_BUFA_read(Ad_BUFA_read),.Ad_BUF0(Ad_BUF0),.Ad_BUF1(Ad_BUF1),.Ad_BUF2(Ad_BUF2),.BUF_w(BUF_w),
	.id_FPU(id_FPU),.id_BPU(id_BPU),.Init_Flag_BPU_M(Init_Flag_BPU_M),.Init_Flag_BPU_L(Init_Flag_BPU_L),
	.Init_Flag_FPU(Init_Flag_FPU),.initBeta(InitBeta6_2SW),.initAlpha(InitAlph6),
	.q_up(q_up), // add by shaxiaoshi 2016.3.8
	//output
	.BPU_beta_out_next(Beta6),.FPU_alpha_out_next(Alph6),
	.D(D6),.Le_sys(Le_sys6),.Le_par(Le_par6)
	);
	
	Modu_SW_MAP_3BUF SW_MAP_3BUF_7(
	//input
	.clk(clk),.Iter(Iter),.decMode(decMode),.blockIndex(3'b111),.decNum(decNum),
	.System(Sys_SW7),.Parity(Par_SW7),.La(La_SW7),.dir_BUFA(dir_BUFA),
	.Ad_BUFA_read(Ad_BUFA_read),.Ad_BUF0(Ad_BUF0),.Ad_BUF1(Ad_BUF1),.Ad_BUF2(Ad_BUF2),.BUF_w(BUF_w),
	.id_FPU(id_FPU),.id_BPU(id_BPU),.Init_Flag_BPU_M(Init_Flag_BPU_M),.Init_Flag_BPU_L(Init_Flag_BPU_L),
	.Init_Flag_FPU(Init_Flag_FPU),.initBeta(InitBeta7_2SW),.initAlpha(InitAlph7),
	.q_up(q_up), // add by shaxiaoshi 2016.3.8
	//output
	.BPU_beta_out_next(Beta7),.FPU_alpha_out_next(Alph7),
	.D(D7),.Le_sys(Le_sys7),.Le_par(Le_par7)
	);
endmodule
