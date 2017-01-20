##-----------------------------------------------------------------------------
##
## (c) Copyright 2012-2012 Xilinx, Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of Xilinx, Inc. and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith. Except as
## otherwise provided in a valid license issued to you by
## Xilinx, and to the maximum extent permitted by applicable
## law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
## WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
## AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
## BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
## (2) Xilinx shall not be liable (whether in contract or tort,
## including negligence, or under any other theory of
## liability) for any loss or damage of any kind or nature
## related to, arising under or in connection with these
## materials, including for any direct, or any indirect,
## special, incidental, or consequential loss or damage
## (including loss of data, profits, goodwill, or any type of
## loss or damage suffered as a result of any action brought
## by a third party) even if such damage or loss was
## reasonably foreseeable or Xilinx had been advised of the
## possibility of the same.
##
## CRITICAL APPLICATIONS
## Xilinx products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of Xilinx products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
##
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES.
##
##-----------------------------------------------------------------------------
##
## Project    : Virtex-7 FPGA Gen3 Integrated Block for PCI Express
## File       : PCIeGen2x8If128-PCIE_X0Y2.xdc
## Version    : 4.0
#
###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################

###############################################################################
# User Physical Constraints
###############################################################################


###############################################################################
# Pinout and Related I/O Constraints
###############################################################################
#
# Transceiver instance placement.  This constraint selects the
# transceivers to be used, which also dictates the pinout for the
# transmit and receive differential pairs.  Please refer to the
# Virtex-7 GT Transceiver User Guide (UG) for more information.
#
###############################################################################
# PCIe Lane 0
set_property LOC GTHE2_CHANNEL_X1Y35 [get_cells {gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gth_channel.gthe2_channel_i}]
# PCIe Lane 1
set_property LOC GTHE2_CHANNEL_X1Y34 [get_cells {gt_top_i/pipe_wrapper_i/pipe_lane[1].gt_wrapper_i/gth_channel.gthe2_channel_i}]
# PCIe Lane 2
set_property LOC GTHE2_CHANNEL_X1Y33 [get_cells {gt_top_i/pipe_wrapper_i/pipe_lane[2].gt_wrapper_i/gth_channel.gthe2_channel_i}]
# PCIe Lane 3
set_property LOC GTHE2_CHANNEL_X1Y32 [get_cells {gt_top_i/pipe_wrapper_i/pipe_lane[3].gt_wrapper_i/gth_channel.gthe2_channel_i}]
# PCIe Lane 4
set_property LOC GTHE2_CHANNEL_X1Y31 [get_cells {gt_top_i/pipe_wrapper_i/pipe_lane[4].gt_wrapper_i/gth_channel.gthe2_channel_i}]
# PCIe Lane 5
set_property LOC GTHE2_CHANNEL_X1Y30 [get_cells {gt_top_i/pipe_wrapper_i/pipe_lane[5].gt_wrapper_i/gth_channel.gthe2_channel_i}]
# PCIe Lane 6
set_property LOC GTHE2_CHANNEL_X1Y29 [get_cells {gt_top_i/pipe_wrapper_i/pipe_lane[6].gt_wrapper_i/gth_channel.gthe2_channel_i}]
# PCIe Lane 7
set_property LOC GTHE2_CHANNEL_X1Y28 [get_cells {gt_top_i/pipe_wrapper_i/pipe_lane[7].gt_wrapper_i/gth_channel.gthe2_channel_i}]
###############################################################################
#
# PCI Express Block placement. This constraint selects the PCI Express
# Block to be used.
#
###############################################################################
set_property LOC PCIE3_X0Y2 [get_cells pcie_top_i/pcie_7vx_i/PCIE_3_0_i]
###############################################################################
#
# Buffer (BRAM) Placement Constraints
#
###############################################################################
# Replay Buffer RAMB Placement
set_property LOC RAMB36_X12Y83 [get_cells {pcie_top_i/pcie_7vx_i/pcie_bram_7vx_i/replay_buffer/U0/RAMB36E1[0].u_buffer}]
set_property LOC RAMB36_X12Y84 [get_cells {pcie_top_i/pcie_7vx_i/pcie_bram_7vx_i/replay_buffer/U0/RAMB36E1[1].u_buffer}]

# Non-Posted Request Buffer RAMB Placement
set_property LOC RAMB18_X12Y150 [get_cells {pcie_top_i/pcie_7vx_i/pcie_bram_7vx_i/req_fifo/U0/RAMB18E1[0].u_fifo}]
set_property LOC RAMB18_X12Y151 [get_cells {pcie_top_i/pcie_7vx_i/pcie_bram_7vx_i/req_fifo/U0/RAMB18E1[1].u_fifo}]
set_property LOC RAMB18_X12Y152 [get_cells {pcie_top_i/pcie_7vx_i/pcie_bram_7vx_i/req_fifo/U0/RAMB18E1[2].u_fifo}]
set_property LOC RAMB18_X12Y153 [get_cells {pcie_top_i/pcie_7vx_i/pcie_bram_7vx_i/req_fifo/U0/RAMB18E1[3].u_fifo}]

# Completion Buffer RAMB Placement
set_property LOC RAMB36_X12Y78 [get_cells {pcie_top_i/pcie_7vx_i/pcie_bram_7vx_i/cpl_fifo/genblk1.CPL_FIFO_16KB.U0/SPEED_250MHz.RAMB36E1[0].u_fifo}]
set_property LOC RAMB36_X12Y79 [get_cells {pcie_top_i/pcie_7vx_i/pcie_bram_7vx_i/cpl_fifo/genblk1.CPL_FIFO_16KB.U0/SPEED_250MHz.RAMB36E1[1].u_fifo}]
set_property LOC RAMB36_X12Y80 [get_cells {pcie_top_i/pcie_7vx_i/pcie_bram_7vx_i/cpl_fifo/genblk1.CPL_FIFO_16KB.U0/SPEED_250MHz.RAMB36E1[2].u_fifo}]
set_property LOC RAMB36_X12Y81 [get_cells {pcie_top_i/pcie_7vx_i/pcie_bram_7vx_i/cpl_fifo/genblk1.CPL_FIFO_16KB.U0/SPEED_250MHz.RAMB36E1[3].u_fifo}]
###############################################################################
# Timing Constraints
###############################################################################
#
create_clock -period 10 [get_pins {gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gth_channel.gthe2_channel_i/TXOUTCLK}]
create_clock -period 4 [get_pins {gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gth_channel.gthe2_channel_i/RXOUTCLK}]


create_generated_clock -name pipeclk_125mhz_x0y2 -source [get_pins gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I0] -divide_by 1 [get_pins gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/second_stage_buf.pclk_i2/O]
create_generated_clock -name pipeclk_250mhz_x0y2 -source [get_pins gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I1] -divide_by 1 -add -master_clock [get_clocks -of_objects [get_pins gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I1]] [get_pins gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/second_stage_buf.pclk_i2/O]
set_clock_groups -name pcieclkmux_x0y2 -physically_exclusive -group pipeclk_125mhz_x0y2 -group pipeclk_250mhz_x0y2
set_false_path -to [get_pins gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S0]
set_false_path -to [get_pins gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S1]

create_generated_clock -name rxclk_125mhz_x0y2 -source [get_pins gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I0] -divide_by 1 [get_pins gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/second_stage_buf.rxusrclk_i2/O]
create_generated_clock -name rxclk_250mhz_x0y2 -source [get_pins gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I1] -divide_by 1 -add -master_clock [get_clocks -of_objects [get_pins gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I1]] [get_pins gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/second_stage_buf.rxusrclk_i2/O]
create_generated_clock -name rxclk_rxout_x0y2  -source [get_pins gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/second_stage_buf.rxusrclk_i2/I1] -divide_by 1 -add -master_clock [get_clocks -of_objects [get_pins gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/second_stage_buf.rxusrclk_i2/I1]] [get_pins gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/second_stage_buf.rxusrclk_i2/O]
set_clock_groups -name usrclkmux_x0y2 -physically_exclusive -group rxclk_125mhz_x0y2 -group rxclk_250mhz_x0y2 -group rxclk_rxout_x0y2
set_false_path -to [get_pins gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/second_stage_buf.rxusrclk_i2/S0]
set_false_path -to [get_pins gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/second_stage_buf.rxusrclk_i2/S1]

# physically exclusive because of bufg connectivity
set_clock_groups -name pcietousrclk0_x0y2 -physically_exclusive -group pipeclk_125mhz_x0y2 -group rxclk_250mhz_x0y2
set_clock_groups -name pcietousrclk1_x0y2 -physically_exclusive -group pipeclk_250mhz_x0y2 -group rxclk_125mhz_x0y2
# physically exclusive because of design RTL
set_clock_groups -name pcietousrclk2_x0y2 -physically_exclusive -group pipeclk_125mhz_x0y2 -group rxclk_rxout_x0y2

# False Paths for Valid CDC ciruits when in ASYNC mode
set_false_path -to [get_pins {gt_top_i/pipe_wrapper_i/pipe_lane[*].gt_wrapper_i/rxclk_rate_reg[*]/D}]
set_false_path -to [get_pins {gt_top_i/pipe_wrapper_i/pipe_lane[*].gt_wrapper_i/rxclk_polarity_reg/D}]
set_false_path -to [get_pins {gt_top_i/pipe_wrapper_i/pipe_lane[*].gt_wrapper_i/rxclk_gen3_reg/D}]
set_false_path -to [get_pins {gt_top_i/pipe_wrapper_i/pipe_lane[*].pipe_user_i/rate_gen3_reg1_reg/D}]
set_false_path -to [get_pins {gt_top_i/pipe_wrapper_i/pipe_lane[*].pipe_user_i/rate_rxsync_reg1_reg/D}]
set_false_path -to [get_pins {gt_top_i/pipe_wrapper_i/pipe_lane[*].pipe_user_i/rate_idle_reg1_reg/D}]
set_false_path -to [get_pins {gt_top_i/pipe_wrapper_i/pipe_lane[*].pipe_user_i/rate_done_reg1_reg/D}]
set_false_path -to [get_pins {gt_top_i/pipe_wrapper_i/pipe_lane[*].pipe_user_i/rst_idle_reg1_reg/D}]

set_false_path -to [get_pins {gt_top_i/pipe_wrapper_i/pipe_lane[*].pipe_rate_i/phystatus_reg1_reg/D}]
set_false_path -to [get_pins {gt_top_i/pipe_wrapper_i/pipe_lane[*].pipe_rate_i/rxratedone_reg1_reg/D}]
set_false_path -to [get_pins {gt_top_i/pipe_wrapper_i/pipe_lane[*].pipe_rate_i/rxresetdone_reg1_reg/D}]
set_false_path -to [get_pins {gt_top_i/pipe_wrapper_i/pipe_lane[*].pipe_user_i/rxresetdone_reg1_reg/D}]

set_false_path -to [get_pins {gt_top_i/pipe_wrapper_i/pipe_reset_i/phystatus_reg1_reg[*]/D}]

set_false_path -to [get_pins {pcie_top_i/pcie_init_ctrl_7vx_i/reg_phy_rdy_reg[*]/PRE}]
set_false_path -to [get_pins {pcie_top_i/force_adapt_i/rx_eq_adapt_reg/D}]
set_false_path -to [get_pins {pcie_top_i/force_adapt_i/speed_change_reg0_reg/D}]
set_false_path -to [get_pins {pcie_top_i/force_adapt_i/cfg_loopback_reg0_reg/D}]

#------------------------------------------------------------------------------
# Asynchronous Pins
#------------------------------------------------------------------------------
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/RXELECIDLE}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/RXCDRLOCK}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/TXPHALIGNDONE}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/TXPHINITDONE}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/CPLLLOCK}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/RXPMARESETDONE}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/RXPHALIGNDONE}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/RXSYNCDONE}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/TXDLYSRESETDONE}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/TXSYNCDONE}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/RXDLYSRESETDONE}]
set_false_path -through [get_pins -hierarchical -filter {NAME=~*/QPLLLOCK}]
#
###############################################################################
# Physical Constraints
###############################################################################

###############################################################################
# End
###############################################################################