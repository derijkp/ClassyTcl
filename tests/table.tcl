#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::Table {create and configure} {
	classyclean
	proc getcommand {object w row col} {
		if {$col == 1} {
			$w configure -bg gray
		} elseif {$row == 5} {
			$w configure -bg yellow
		} else {
			$w configure -bg [$object cget -bg]
		}
		for {set i 1} {$i<1000} {incr i} {
		}
		if [info exists ::d($row,$col)] {return $::d($row,$col)} else {return {}}
	}
	proc setcommand {row col value} {
		if {"$value" == "error"} {error "some error"}
		if {"$value" == ""} {unset ::d($row,$col)} else {set ::d($row,$col) $value}
	}
	Classy::Table .try
	.try configure -getcommand getcommand  -setcommand setcommand \
		-xscrollcommand {.hbar set} -yscrollcommand {.vbar set}
	scrollbar .hbar -command {.try xview} -orient horizontal
	scrollbar .vbar -command {.try yview} -orient vertical
	grid .try .vbar -row 0 -sticky nwse
	grid .hbar -row 1 -sticky we
	grid columnconfigure . 0 -weight 1
	grid columnconfigure . 1 -weight 0
	grid rowconfigure . 0 -weight 1
	grid rowconfigure . 1 -weight 0

	proc xlabelcommand {object w col} {return "x $col"}
	proc ylabelcommand {object w row} {return "y $row"}
	.try configure -xlabelcommand xlabelcommand -ylabelcommand ylabelcommand \
		-rows 500 -cols 5
	for {set row 0} {$row<600} {incr row} {
		for {set col 0} {$col<10} {incr col} {
			set ::d($row,$col) "r $row c $col"
		}
	}
#	manualtest
} {}


#testsummarize
