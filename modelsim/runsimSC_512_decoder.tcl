if {$DEBUG == "ON"} {
    set VOPT_ARG "+acc"
    echo $VOPT_ARG
    set DB_SW "-debugdb"
} else {
    set DB_SW ""
}

if {$COVERAGE == "ON"} {
    set COV_SW -coverage
} else {
    set COV_SW ""
}

vsim -voptargs=$VOPT_ARG $DB_SW $COV_SW -pedanticerrors -lib $LIB SC_512_decoder_tb

if {$DEBUG == "ON"} {
    add wave -r /dut/*
}

run -a

if {$COVERAGE == "ON"} {
    coverage report -summary -out myreport.txt
    coverage report -html
}
