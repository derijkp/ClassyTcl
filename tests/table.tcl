#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::Table {create and configure} {
	classyclean
	Classy::Table .try
	scrollbar .hbar -orient horizontal \
		-command {.try xview}
	scrollbar .vbar -orient vertical \
		-command {.try yview}
	.try configure \
		-xscrollcommand {.hbar set} \
		-yscrollcommand {.vbar set} \
		-getcommand {
		invoke {object w x y} {
			if {$x == 1} {
				$w configure -bg gray
			} elseif {$y == 5} {
				$w configure -bg yellow
			} else {
				$w configure -bg [$w cget -bg]
			}
			get ::d($x,$y)
		}
		} \
		-setcommand {
		invoke {object w x y v} {
			if {"$v" == "error"} {error "some error"}
			set ::d($x,$y) $v
		}
		}
	grid .try .vbar -row 0 -sticky nwse
	grid .hbar -row 1 -sticky we
	grid columnconfigure . 0 -weight 1
	grid columnconfigure . 1 -weight 0
	grid rowconfigure . 0 -weight 1
	grid rowconfigure . 1 -weight 0

	.try configure -xlabelcommand {invoke {object w col} {return "x $col"}} -ylabelcommand {invoke {object w row} {return "y $row"}} \
		-rows 500 -cols 5
	for {set row 0} {$row<600} {incr row} {
		for {set col 0} {$col<10} {incr col} {
			set ::d($row,$col) "r $row c $col"
		}
	}
#	manualtest
} {}

#testsummarize

if 0 {
lappend auto_path /peter/dev
package require ClassyTcl
cd /peter/dev/classytcl/tests
catch {destroy .t}
toplevel .t
scrollbar .t.v
.t.v configure -command {invoke {} {puts ".t.t yview $args" ; eval .t.t yview $args ; return -code break} }
text .t.t 
.t.t configure -yscrollcommand {invoke {} {puts ".t.v set $args" ; eval .t.v set $args}}
for {set i 0} {$i < 500} {incr i} {.t.t insert end $i\n}
pack .t.t .t.v -fill both -side left
}


