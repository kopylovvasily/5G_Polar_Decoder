# Script to compile RTL sourcecode

set DEBUG ON
set COVERAGE OFF

# Set working library.
set LIB work

# If a simulation is loaded, quit it so that it compiles in a clean working library.
set STATUS [runStatus]
if {$STATUS ne "nodesign"} {
    quit -sim
}

# Start with a clean working library.
if { [file exists $LIB] == 1} {
    echo "lib exist"
    file delete -force -- $LIB
}
vlib $LIB

if {$COVERAGE == "ON"} {
    set COV_TYPE bcst
} else {
    set COV_TYPE 0
}


# Compile DUT from file list.
vlog -sv -pedanticerrors -cover $COV_TYPE -work $LIB ../sourcecode/pkg.sv 
vlog -sv -pedanticerrors -cover $COV_TYPE -work $LIB ../sourcecode/SC_512_decoder.sv 
vlog -sv -pedanticerrors -cover $COV_TYPE -work $LIB ../sourcecode/G_Acc.sv 
vlog -sv -pedanticerrors -cover $COV_TYPE -work $LIB ../sourcecode/F_Acc.sv 
vlog -sv -pedanticerrors -cover $COV_TYPE -work $LIB ../sourcecode/F_func.sv 
vlog -sv -pedanticerrors -cover $COV_TYPE -work $LIB ../sourcecode/G_func.sv 
vlog -sv -pedanticerrors -cover $COV_TYPE -work $LIB ../sourcecode/GGF.sv 
vlog -sv -pedanticerrors -cover $COV_TYPE -work $LIB ../sourcecode/FFG.sv 
vlog -sv -pedanticerrors -cover $COV_TYPE -work $LIB ../sourcecode/MemoryAlpha1.sv 
vlog -sv -pedanticerrors -cover $COV_TYPE -work $LIB ../sourcecode/MemoryAlpha2.sv 
vlog -sv -pedanticerrors -cover $COV_TYPE -work $LIB ../sourcecode/combiner.sv 
vlog -sv -pedanticerrors -cover $COV_TYPE -work $LIB ../sourcecode/getN.sv 
vlog -sv -pedanticerrors -cover $COV_TYPE -work $LIB ../sourcecode/clog2.sv 
vlog -sv -pedanticerrors -cover $COV_TYPE -work $LIB ../sourcecode/FrozenPattern_Generator.sv 
vlog -sv -pedanticerrors -cover $COV_TYPE -work $LIB ../sourcecode/memory_Frozen.sv 
vlog -sv -work $LIB -cover $COV_TYPE ../sourcecode/tb/SC_512_decoder_tb.sv



