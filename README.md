# SSC 512 Polar Decoder
		
## Usage:

This decoder requires as inputs, K(number of message Bits), E(number of rate matched bits), and input LLRS. Note: Input LLRS must be applied for 4 consecutive clock cycles.
Input LLRS must be 7 bits where first bit is used to represent the sign, 5 bits are used to represent the integer part of the LLRs,and last bit is used to represent the 
floating part. Decoder will always produce a 512 bits decoded output. This decoder operates for any N={32,64,128,256,512}, and it is important to emphasize that when N<512, 
only N first bits of the output sequence will represent the correct decoded bits, the rest will be just zeros. So, when N=256, you must consider only first 256 outputs of this decoder,
when N=32, you should consider only first 32 and so on. The same thing happens when you apply input LLRS for N<512. Only N first input LLRS will be considered by the decoder. It is advisable to
put zeors on the rest of LLRS which will not be considered. Moreover, this decoder will also show as an output N(number of coded bits). For the proper operation of this decoder, handshake 
signals must be considered as well. Put valid_i = 1, whenever you apply input LLRS and submit new LLRs whenever done_o=1. 

## Files:
	The HDL implementation of this polar decoder is found in Polar_Decoder folder and you will find the following files there:

	-pkg.sv: Contains Constant Parameter Definitions for the main decoder	
	-SC_512_decoder_tb: Testbench of Polar Decoder
	-SC_512_decoder: Main Decoder File
	-F_Func: F Processing Unit
	-G_Func: G Processing Unit
	-FFG: Radix 4 with 3 F Processing Unit and 1 G Processing Unit
	-GGF: Radix 4 with 3 G Processing unit and 1 F Processing unit
	-F_Accelerator: Radix 12 with 8 F Processing units and 4 G Processing units
	-G_Accelerator: Radix 12 with 8 G Processing units and 4 F Processing Units
	-combiner: Responsible for xor and FeedForward Operation when G is computed 
	-MemoryAlpha1: RAM memory which stores input and internal LLRS
	-MemoryAlpha2: RAM memory which stores internal LLRS
	-GetN: Computes number of coded bits from K and E
	-FrozenPattern_Generator: Generates the Frozen bit pattern for any K and E
	-clog2: Computes Ceiling of the logarithm with base 2
	-memory_Frozen: Stores Memory for Frozen Pattern Generation 
	-FilesForTestBench: Generates the stimuli for the testbench

## How to run it:

	1) Go to Matlab Folder
	2) Go to FilesForTestBench Folder
	3) Run startup.m, but please make sure to change the directory "arithlib_dir" to your own directory
	4) Open Generating_SimVectors.m file (you can change parameters in it in order to generate the stimuli according to your needs) 
	5) Run the code in order to generate the stimuli and expected response files
	6) Place those files in SimVectors File
	7) Open modelsim file and run in questasim compileSC_512_decoder.tcl file
	8) Run the runsim_SC_512_decoder.tcl File in questasim
	
