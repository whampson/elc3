# Legal Notice: (C)2017 Altera Corporation. All rights reserved.  Your
# use of Altera Corporation's design tools, logic functions and other
# software and tools, and its AMPP partner logic functions, and any
# output files any of the foregoing (including device programming or
# simulation files), and any associated documentation or information are
# expressly subject to the terms and conditions of the Altera Program
# License Subscription Agreement or other applicable license agreement,
# including, without limitation, that your use is for the sole purpose
# of programming logic devices manufactured by Altera and sold by Altera
# or its authorized distributors.  Please refer to the applicable
# agreement for further details.

#**************************************************************
# Timequest JTAG clock definition
#   Uncommenting the following lines will define the JTAG
#   clock in TimeQuest Timing Analyzer
#**************************************************************

#create_clock -period 10MHz {altera_reserved_tck}
#set_clock_groups -asynchronous -group {altera_reserved_tck}

#**************************************************************
# Set TCL Path Variables 
#**************************************************************

set 	elc3_soc_nios2_qsys_0 	elc3_soc_nios2_qsys_0:*
set 	elc3_soc_nios2_qsys_0_oci 	elc3_soc_nios2_qsys_0_nios2_oci:the_elc3_soc_nios2_qsys_0_nios2_oci
set 	elc3_soc_nios2_qsys_0_oci_break 	elc3_soc_nios2_qsys_0_nios2_oci_break:the_elc3_soc_nios2_qsys_0_nios2_oci_break
set 	elc3_soc_nios2_qsys_0_ocimem 	elc3_soc_nios2_qsys_0_nios2_ocimem:the_elc3_soc_nios2_qsys_0_nios2_ocimem
set 	elc3_soc_nios2_qsys_0_oci_debug 	elc3_soc_nios2_qsys_0_nios2_oci_debug:the_elc3_soc_nios2_qsys_0_nios2_oci_debug
set 	elc3_soc_nios2_qsys_0_wrapper 	elc3_soc_nios2_qsys_0_jtag_debug_module_wrapper:the_elc3_soc_nios2_qsys_0_jtag_debug_module_wrapper
set 	elc3_soc_nios2_qsys_0_jtag_tck 	elc3_soc_nios2_qsys_0_jtag_debug_module_tck:the_elc3_soc_nios2_qsys_0_jtag_debug_module_tck
set 	elc3_soc_nios2_qsys_0_jtag_sysclk 	elc3_soc_nios2_qsys_0_jtag_debug_module_sysclk:the_elc3_soc_nios2_qsys_0_jtag_debug_module_sysclk
set 	elc3_soc_nios2_qsys_0_oci_path 	 [format "%s|%s" $elc3_soc_nios2_qsys_0 $elc3_soc_nios2_qsys_0_oci]
set 	elc3_soc_nios2_qsys_0_oci_break_path 	 [format "%s|%s" $elc3_soc_nios2_qsys_0_oci_path $elc3_soc_nios2_qsys_0_oci_break]
set 	elc3_soc_nios2_qsys_0_ocimem_path 	 [format "%s|%s" $elc3_soc_nios2_qsys_0_oci_path $elc3_soc_nios2_qsys_0_ocimem]
set 	elc3_soc_nios2_qsys_0_oci_debug_path 	 [format "%s|%s" $elc3_soc_nios2_qsys_0_oci_path $elc3_soc_nios2_qsys_0_oci_debug]
set 	elc3_soc_nios2_qsys_0_jtag_tck_path 	 [format "%s|%s|%s" $elc3_soc_nios2_qsys_0_oci_path $elc3_soc_nios2_qsys_0_wrapper $elc3_soc_nios2_qsys_0_jtag_tck]
set 	elc3_soc_nios2_qsys_0_jtag_sysclk_path 	 [format "%s|%s|%s" $elc3_soc_nios2_qsys_0_oci_path $elc3_soc_nios2_qsys_0_wrapper $elc3_soc_nios2_qsys_0_jtag_sysclk]
set 	elc3_soc_nios2_qsys_0_jtag_sr 	 [format "%s|*sr" $elc3_soc_nios2_qsys_0_jtag_tck_path]

#**************************************************************
# Set False Paths
#**************************************************************

set_false_path -from [get_keepers *$elc3_soc_nios2_qsys_0_oci_break_path|break_readreg*] -to [get_keepers *$elc3_soc_nios2_qsys_0_jtag_sr*]
set_false_path -from [get_keepers *$elc3_soc_nios2_qsys_0_oci_debug_path|*resetlatch]     -to [get_keepers *$elc3_soc_nios2_qsys_0_jtag_sr[33]]
set_false_path -from [get_keepers *$elc3_soc_nios2_qsys_0_oci_debug_path|monitor_ready]  -to [get_keepers *$elc3_soc_nios2_qsys_0_jtag_sr[0]]
set_false_path -from [get_keepers *$elc3_soc_nios2_qsys_0_oci_debug_path|monitor_error]  -to [get_keepers *$elc3_soc_nios2_qsys_0_jtag_sr[34]]
set_false_path -from [get_keepers *$elc3_soc_nios2_qsys_0_ocimem_path|*MonDReg*] -to [get_keepers *$elc3_soc_nios2_qsys_0_jtag_sr*]
set_false_path -from *$elc3_soc_nios2_qsys_0_jtag_sr*    -to *$elc3_soc_nios2_qsys_0_jtag_sysclk_path|*jdo*
set_false_path -from sld_hub:*|irf_reg* -to *$elc3_soc_nios2_qsys_0_jtag_sysclk_path|ir*
set_false_path -from sld_hub:*|sld_shadow_jsm:shadow_jsm|state[1] -to *$elc3_soc_nios2_qsys_0_oci_debug_path|monitor_go
