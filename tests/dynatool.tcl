#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl 

test Classy::DynaTool {text} {
	classyclean
	Classy::DynaTool define Test {
		action open "Open" {puts open}
		action "Test" "Test" {puts test}
		action "OK" "OK" {puts OK}
	}
	Classy::DynaTool .try
	.try configure -type Test -cmdw .
	pack .try -fill x
	text .text
	pack .text -side bottom -fill both -expand yes
	manualtest
} {}

test Classy::DynaTool {no display} {
	classyclean
	Classy::DynaTool define Test {
		nodisplay
		action print "Print" {puts print}
		action "OK" "OK" {puts OK}
		check copy "Copy" {-variable copy}
	}
	Classy::DynaTool .t -type Test -cmdw .text
	pack .t -fill x
	text .text
	pack .text -side bottom
	set try 1
} {1}

test Classy::DynaTool {pictures} {
	classyclean
	Classy::DynaTool .try -type Classy::Dummy -cmdw .text
	pack .try -fill x
	text .text
	pack .text -side bottom
	set try 1
} {1}

test Classy::DynaTool {text} {
	classyclean
	Classy::DynaTool define Test {
		action "Test" "Test" {%W insert end test}
		action "OK" "OK" {%W insert end OK}
		widget Entry Entry .e
	}
	entry .e
	Classy::DynaTool .try -type Test -cmdw .text
	pack .try -fill x
	text .text
	pack .text -side bottom
	manualtest
} {}

testsummarize
