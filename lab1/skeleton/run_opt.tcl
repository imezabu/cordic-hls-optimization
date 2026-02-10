#=============================================================================
# run-opt.tcl 
#=============================================================================
# @brief: A Tcl script for the optimization experiments from lab 1 section 4.3
#
# @desc: Fix the design configuration to use 20 iterations and 32-bit signed
# fixed-point type with 8 integer bits. The goal is to maximize the throughput
# of this design using optimization directives provided by Vivado HLS. 
#

# Your Vivado HLS project script goes here
# HINT: You can use run_fixed.tcl as a template. Then, run this script with
# `vivado_hls -f run_opt.tcl`

set filename "opt_result.csv"
file delete -force "./result/${filename}"

#-----------------------------------------------------
# You can specify a set of bitwidth configurations to 
# explore in the batch experiments. 
# Each configuration (line) is defined by a pair in  
# total bitwidth and integer bitwidth
# Examples are shown below. 
#-----------------------------------------------------
set bitwidth_pair { \
    32    8   \
}

#-----------------------------------
# run batch experiments
#-----------------------------------
foreach { TOT_W INT_W } $bitwidth_pair {

# Define the bitwidth macros from CFLAGs
set CFLAGS "-DFIXED_TYPE -DFULL_WIDTH=${TOT_W} -DI_WIDTH=${INT_W}"

# Project name
set hls_prj "opt_${TOT_W}_${INT_W}_20.prj"

# Open/reset the project
open_project ${hls_prj} -reset
# Top function of the design is "cordic"
set_top cordic

# Add design and testbench files
add_files cordic.cpp -cflags $CFLAGS
add_files -tb cordic_test.cpp -cflags $CFLAGS

open_solution "solution1" -flow_target vitis
# use KV260 device (Kria K26 SOM - Zynq UltraScale+ MPSoC)
set_part xck26-sfvc784-2LV-c

# Target clock period is 10ns
create_clock -period 10

#------------------------------------
# optimizations
# ----------------------------------
#
set_directive_pipeline cordic/FIXED_STEP_LOOP -II 10

# Simulate the C++ design
csim_design
# Synthesize the design
csynth_design

# We will skip C-RTL cosimulation for now
#cosim_design

#---------------------------------------------
# Collect & dump out results from HLS reports
#---------------------------------------------
set argv [list $filename $hls_prj]
set argc 2
source "./script/collect_result.tcl"
}

quit
