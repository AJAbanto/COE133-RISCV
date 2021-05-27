# RISCV-single-cyle
![Processor Diagram](/docs/images/RISC-V_Processor.svg)

This particular implementation of the RISCV ISA only supports a subset of the original ISA spec. This was originally 
made to fulfill an academic requirement but since it coincided with my old plans to try implementing the RISCV architecture, 
I decided to make this available for others to use as referrence. In particular this implementation is based on the RV64I v2.0 detailed in
the RISC-V Instruction Set Manual ( Volume I: User-Level ISA , version 2.2)

## Features
As said, this processor only supports a subset of the RISCV ISA. For more indepth information to the RISC-V Instruction Set Manual which can be found here:
https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf
### Register-register
* add
* sub
* and
* or
* xor
### Register-Immediate
* addi
### Conditional Branch
* beq
* bne
### Unconditional Branch
* jal
* jalr
### Load and Store
* ld
* lw
* lh
* lwu
* lhu
* sd
* sw
* sh

## Usage
Everything was writen and simulated using vivado. This should make it easy for one to replicate what I've done in the project. 
I've also included sample assembly code which I've also compiled into hexadecimal text with RARS. They can be found in docs/RARS along with
a .jar release of the RARS (You can find more info on RARS and how to use it here: https://github.com/TheThirdOne/rars)
  
## Notes:
* Do take note that the memory modules placed in the "provided_files" directory were provided by my professor which can be found here:
https://github.com/snapdensing/CoE113/tree/master/memory_model 
This was done to standardize testing of the individual outputs of our class.
* Due to the fact that the memory modules were provided and are different from the RARS addressing convention
, you wont be able to execute the load and store instructions as intended to be used in the processor in RARS.

## Changelog
* May 28, 2021 - Fixed slt , it should work with signed values now. I also fixed register zero so it should not be writeable now.
