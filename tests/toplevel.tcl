#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"
source tools.tcl

test Classy::Toplevel {destroycommand} {
	classyclean
	set ::try 0
	Classy::Toplevel .try -title "Try it" -destroycommand {set ::try 1} -keepgeometry 0
	button .try.b1 -text "button 1"
	button .try.b2 -text "button two"
	grid .try.b1 -sticky nwse
	grid .try.b2 -sticky nwse
	grid columnconfigure . 0 -weight 1
	destroy .try
	set ::try
} {1}

test Classy::Toplevel {keepgeometry 0} {
	classyclean
	Classy::Default unset geometry .try
	button .b -command {
		Classy::Toplevel .try -title "Try it" -keepgeometry 0
		button .try.b1 -text "button 1"
		button .try.b2 -text "close" -command "destroy .try"
		grid .try.b1 -sticky nwse
		grid .try.b2 -sticky nwse
		grid columnconfigure . 0 -weight 1
	} -text "Click for toplevel"
	pack .b
	manualtest
} {1}

test Classy::Toplevel {keepgeometry 1} {
	classyclean
	Classy::Default unset geometry .try
	button .b -command {
		Classy::Toplevel .try -title "Try it" -keepgeometry 1
		button .try.b1 -text "button 1"
		button .try.b2 -text "close" -command "destroy .try"
		grid .try.b1 -sticky nwse
		grid .try.b2 -sticky nwse
		grid columnconfigure . 0 -weight 1
	} -text "Click for toplevel"
	pack .b
	manualtest
} {1}

test Classy::Toplevel {keepgeometry all} {
	classyclean
	Classy::Default unset geometry .try
	button .b -command {
		Classy::Toplevel .try -title "Try it" -keepgeometry all
		button .try.b1 -text "button 1"
		button .try.b2 -text "close" -command "destroy .try"
		grid .try.b1 -sticky nwse
		grid .try.b2 -sticky nwse
		grid columnconfigure . 0 -weight 1
	} -text "Click for toplevel"
	pack .b
	manualtest
} {1}


testsummarize

