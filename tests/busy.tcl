#!/bin/sh
# the next line restarts using wish \
exec wish8.3 "$0" "$@"

source tools.tcl

test Classy::Canvas {create and destroy canvas object} {
	classyclean
	Classy::Editor .try
	pack .try -fill both -expand yes
	Classy::busy .
	Classy::busy remove
} {}

testsummarize
