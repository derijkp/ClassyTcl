#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::Table {create and configure} {
	classyclean
	Classy::Table .try
	.try configure -xscrollcommand {.hbar set} -yscrollcommand {.vbar set} -getcommand {
		if {%x == 1} {
			%w configure -bg gray
		} elseif {%y == 5} {
			%w configure -bg yellow
		} else {
			%w configure -bg [%W cget -bg]
		}
		get d(%y,%x)
	} -setcommand {
		if {"%v" == "error"} {error "some error"}
		set d(%y,%x) %v
	}
	scrollbar .hbar -command {.try xview} -orient horizontal
	scrollbar .vbar -command {.try yview} -orient vertical
	grid .try .vbar -row 0 -sticky nwse
	grid .hbar -row 1 -sticky we
	grid columnconfigure . 0 -weight 1
	grid columnconfigure . 1 -weight 0
	grid rowconfigure . 0 -weight 1
	grid rowconfigure . 1 -weight 0

	.try configure -xlabelcommand {echo "x %x"} -ylabelcommand {echo "y %y"} \
		-rows 500 -cols 5
	for {set row 0} {$row<600} {incr row} {
		for {set col 0} {$col<10} {incr col} {
			set ::d($row,$col) "r $row c $col"
		}
	}
#	manualtest
} {}


#testsummarize
