#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"

source tools.tcl
destroy .classy__.error
classyclean
set object .try
set class Classy::Table
Classy::Table .try
scrollbar .hbar -orient horizontal \
	-command {.try xview}
scrollbar .vbar -orient vertical \
	-command {.try yview}
grid .try .vbar -row 0 -sticky nwse
grid .hbar -row 1 -sticky we
grid columnconfigure . 0 -weight 1
grid columnconfigure . 1 -weight 0
grid rowconfigure . 0 -weight 1
grid rowconfigure . 1 -weight 0

.try configure \
	-xscrollcommand {.hbar set} \
	-yscrollcommand {.vbar set}

.try configure -variable try
set ::d(0,0) "abcdefghijklmnopqrstuvwxyz r 0 c 0"
.try configure -command {
	invoke {object x y} {
		if [llength $args] {
			set value [lindex $args 0]
			if {"$value" != "% $x,$y"} {
				set ::d($x,$y) $value
			} else {
				catch {unset ::d($x,$y)}
			}
		} else {
			get ::d($x,$y) "% $x,$y"
		}
	}
}
.try configure -rows 1000 -cols 5
.try configure -titlerows 1 -roworigin -2
.try configure -titlecols 1 -colorigin -2

.try tag configure -2, -editable 0
.try tag configure title -bg {} -font {helvetica 10 bold}
.try tag configure title -bg gray -font {helvetica 10 bold}
.try tag configure 10, -bg white
.try tag configure ,1 -bg yellow
.try tag configure 10,1 -bg orange
.try tag configure 11,1 -bg blue -fg white
.try tag configure -1,-2 -bg green
.try rowconfigure 5 -size 50 -resize 1 -gridcolor blue -gridwidth 2
.try rowconfigure 1 -size 50
.try rowconfigure 100 -size 50
.try columnconfigure 1 -size 200
.try columnconfigure -2 -gridcolor blue -gridwidth 3
.try rowconfigure -2 -gridcolor blue -gridwidth 3

.try configure -xresize 1
.try configure -yresize 1
.try columnconfigure 1 -resize 0
.try rowconfigure 1 -resize 0
.try rowconfigure 0 -resize 1

.try configure -xgridwidth 1 -ygridwidth 1
#.try configure -xgridwidth 0 -ygridwidth 0
.try columnconfigure -2 -gridwidth {}
.try rowconfigure -2 -gridwidth 1

#.try configure -font {helvetica 14}

.try activate -1,9
.try selection set 1,-1 0,5
.try selection clear
