#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::config {basic} {
	classyclean
	Classy::Config dialog
	update idletasks
	manualtest
} {}

testsummarize

