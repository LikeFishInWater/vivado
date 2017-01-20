@echo off
set xv_path=D:\\Xilinx\\Vivado\\2015.2\\bin
call %xv_path%/xsim test_chnl_turbo_decoder_behav -key {Behavioral:sim_1:Functional:test_chnl_turbo_decoder} -tclbatch test_chnl_turbo_decoder.tcl -view F:/PCIe-Turbo/pcie_turbo_debug/test_final_behav.wcfg -view F:/PCIe-Turbo/pcie_turbo_debug/test_turbocrc_behav.wcfg -view F:/PCIe-Turbo/pcie_turbo_debug/test_chnl_turbo_decoder_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
