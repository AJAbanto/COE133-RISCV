#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/home/aj/Vivado/2020.2/ids_lite/ISE/bin/lin64:/home/aj/Vivado/2020.2/bin
else
  PATH=/home/aj/Vivado/2020.2/ids_lite/ISE/bin/lin64:/home/aj/Vivado/2020.2/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/media/aj/Main_drive/Main_storage/Alfred/Ubuntu_storage/RISCV-single-cyle/MP1/MP1.runs/synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log processor.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source processor.tcl
