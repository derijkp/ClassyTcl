#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::Notebook {create and configure} {
	clean
	eval destroy [winfo children .]
	classyinit test
	Classy::NoteBook .try
	pack .try -fill both -expand yes
	text .text
	.try manage Text .text -command {set ::try ok}
	button .b -text "Try"
	.try manage Button .b -sticky {}
	button .b2 -text "Try 2"
	.try manage {Button 2} .b2 -sticky {}
	.try select Text
	set ::try
} {ok}

test Classy::Notebook {propagate} {
	clean
	eval destroy [winfo children .]
	classyinit test
	toplevel .t
	Classy::NoteBook .t.try
	pack .t.try -fill both -expand yes
	text .t.text
	.t.try manage Text .t.text -command {set ::try ok}
	.t.try select Text
	if {[winfo reqwidth .t.try] == 1} {
		set result notok
	} else {
		set result ok
	}
} {ok}

testsummarize
catch {unset errors}

