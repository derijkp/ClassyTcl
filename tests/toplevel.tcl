#!/bin/sh
# the next line restarts using wish \
exec wish8.3 "$0" "$@"
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
	update
	destroy .try
	set ::try
} {1}

test Classy::Toplevel {keepgeometry 0} {
	classyclean
	catch {Classy::Default unset geometry .try}
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
} {}

test Classy::Toplevel {keepgeometry 1} {
	classyclean
	catch {Classy::Default unset geometry .try}
	button .b -command {
		Classy::Toplevel .try -title "Try it" -keepgeometry 1
		button .try.b1 -text "button 1"
		button .try.b2 -text "close" -command "destroy .try"
		grid .try.b1 -sticky nwse
		grid .try.b2 -sticky nwse
		grid columnconfigure . 0 -weight 1
		bind .try <Escape> {destroy .try}
	} -text "Click for toplevel"
	pack .b
	manualtest
} {}

test Classy::Toplevel {keepgeometry all} {
	classyclean
	catch {Classy::Default unset geometry .try}
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
} {}

test Classy::Toplevel {resize} {
	classyclean
	catch {Classy::Default unset geometry .try}
	button .b -command {
		Classy::Toplevel .try -title "Try it" -resize {1 1}
		button .try.b1 -text "button 1"
		button .try.b2 -text "close" -command "destroy .try"
		grid .try.b1 -sticky nwse
		grid .try.b2 -sticky nwse
		grid columnconfigure . 0 -weight 1
	} -text "Click for toplevel"
	pack .b
	manualtest
} {}

test Classy::Toplevel {gridded} {
	classyclean
	catch {Classy::Default unset geometry .try}
	button .b -command {
		Classy::Toplevel .tryg -title "Try it" -resize {1 1} -keepgeometry all
		text .tryg.t -setgrid yes
		grid .tryg.t -sticky nwse
		grid columnconfigure .tryg 0 -weight 1
		grid rowconfigure .tryg 0 -weight 1
	} -text "Click for toplevel"
	pack .b
	manualtest
} {}

test Classy::Toplevel {do not execute destroycommand when error in init} {
	classyclean
	Classy::Toplevel subclass Test
	Test method init {args} {
		super init
		$object configure -destroycommand {set ::try 1}
		error error
	}
	set ::try 0
	catch {Test .try} res
	set ::try
} {0}

testsummarize


