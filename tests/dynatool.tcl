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
	Classy::DynaTool maketool Test .t .
	pack .t -fill x
	text .text
	pack .text -side bottom -fill both -expand yes
	manualtest
	set try 1
} {1}

test Classy::DynaTool {pictures} {
	classyclean
	Classy::DynaTool define Test {
		action print "Print" {puts print}
		action "OK" "OK" {puts OK}
		check copy "Copy" {-variable copy}
	}
	Classy::DynaTool maketool Test .t .
	pack .t -fill x
	text .text
	pack .text -side bottom
	manualtest
	set try 1
} {1}

test Classy::DynaTool {pictures} {
	classyclean
	Classy::DynaTool maketool Classy::Editor .t .text
	pack .t -fill x
	text .text
	pack .text -side bottom
	set try 1
} {1}

test Classy::DynaTool {text} {
	classyclean
	Classy::DynaTool define Test {
		action "Test" "Test" {puts test}
		action "OK" "OK" {puts OK}
		widget Entry Entry .try
	}
	entry .try
	Classy::DynaTool maketool Test .t .
	pack .t -fill x
	text .text
	pack .text -side bottom
	manualtest
	set try 1
} {1}

testsummarize
