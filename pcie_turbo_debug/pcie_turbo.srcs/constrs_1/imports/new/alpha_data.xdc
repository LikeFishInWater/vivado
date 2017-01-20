#----------------------------------------------------------------------------
# Filename:            VC709_Top.xdc
# Version:             1.00.a
# Verilog Standard:    Verilog-2001
# Description:         Xilinx Design Constraints for the VC709 board.
# These constrain the PCIE_REFCLK, its DSBUF, LED Pins, and PCIE_RESET_N pin
# 
# Author:              Dustin Richmond (@darichmond)
#-----------------------------------------------------------------------------
#
#########################################################################################################################
# User Constraints
#########################################################################################################################

###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################

###############################################################################
# User Physical Constraints
###############################################################################

#########################################################################################################################
# End User Constraints
#########################################################################################################################
#
#
#
#########################################################################################################################
# PCIE Core Constraints
#########################################################################################################################

#
# SYS reset (input) signal.  The sys_reset_n signal should be
# obtained from the PCI Express interface if possible.  For
# slot based form factors, a system reset signal is usually
# present on the connector.  For cable based form factors, a
# system reset signal may not be available.  In this case, the
# system reset signal must be generated locally by some form of
# supervisory circuit.  You may change the IOSTANDARD and LOC
# to suit your requirements and VCCO voltage banking rules.
# Some 7 series devices do not have 3.3 V I/Os available.
# Therefore the appropriate level shift is required to operate
# with these devices that contain only 1.8 V banks.
#

# set_property PACKAGE_PIN AV35 [get_ports PCIE_RESET_N]
set_property PACKAGE_PIN W27 [get_ports PCIE_RESET_N]
set_property IOSTANDARD LVCMOS18 [get_ports PCIE_RESET_N]
set_property PULLUP true [get_ports PCIE_RESET_N]

#
#
# SYS clock 100 MHz (input) signal. The sys_clk_p and sys_clk_n
# signals are the PCI Express reference clock. Virtex-7 GT
# Transceiver architecture requires the use of a dedicated clock
# resources (FPGA input pins) associated with each GT Transceiver.
# To use these pins an IBUFDS primitive (refclk_ibuf) is
# instantiated in user's design.
# Please refer to the Virtex-7 GT Transceiver User Guide
# (UG) for guidelines regarding clock resource selection.
#
#set_property LOC IBUFDS_GTE2_X1Y11 [get_cells refclk_ibuf]

# alpha data
# set_property LOC IBUFDS_GTE2_X1Y8 [get_cells refclk_ibuf]
set_property PACKAGE_PIN F5 [get_ports PCIE_REFCLK_N]
set_property PACKAGE_PIN F6 [get_ports PCIE_REFCLK_P]
# set_property IOSTANDARD LVDS [get_ports PCIE_REFCLK_N]
# set_property IOSTANDARD LVDS [get_ports PCIE_REFCLK_P]

# set_property PACKAGE_PIN F5 [get_ports pcie100_clk_n]
# set_property PACKAGE_PIN AE29 [get_ports refclk200_clk_n]
# set_property IOSTANDARD LVDS [get_ports refclk200_clk_p]
# set_property IOSTANDARD LVDS [get_ports refclk200_clk_n]


###############################################################################
# Timing Constraints
###############################################################################
create_clock -period 10.000 -name pcie_refclk [get_pins refclk_ibuf/O]

###############################################################################
# Physical Constraints
###############################################################################

set_false_path -from [get_ports PCIE_RESET_N]
###############################################################################
# End
###############################################################################


