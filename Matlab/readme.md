# 5G New Radio Polar Decoding

## Git Submodules

Initialize or update the submodules using:
```bash
git submodule update --init --recursive
```

## Files

 - Mapper.m/Demapper.m -----> Used for mapping/demapping bits into symbols and other way around(used for some experiments that we did)
 - main.f ----> responsible for plotting in the same way as "https://www.mathworks.com/help/5g/gs/polar-coding.html"
 - PolarEncoder.m -----> A working Polar Encoder Function
 - SC_Decoder-------> A working SC Decoder Function
 - InterLeaver/DeinterLeaver -----> 5G polar interleaver and deinterleaver
 - floatSCLdecoder.m -----> SCL Decoder for floating points
 - fixedSCLdecoder.m-------> SCL Decoder for fixed points

## ArithLib

The RealRESIZE binary should be built automatically (see startup.m) when you first start Matlab. You
can also build it manually by running 'build' in the RealARITH folder.

Small example:
```matlab
fixp = {6,5, 's'};
qtype = 'SatTrc_NoWarn';
x = RealRESIZE(pi, fixp, qtype);
% x = 3.1250
```
