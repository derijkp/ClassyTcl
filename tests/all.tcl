#!/bin/sh
# the next line restarts using wish \
exec tclsh "$0" "$@"

source tools.tcl
teststart
# testleak 100

testfile class.tcl
testfile autoload.tcl
testfile version.tcl

testsummarize
