#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl
if 0 {
Classy::Builder .classy__.builder
.classy__.builder configure -dir ../dialogs
}

test Classy::Config {basic} {
	classyclean
	Classy::Config dialog
	update idletasks
	manualtest
} {}

testsummarize

Classy::Config dialog -node {Menus Classy::Editor} -level appdef
Classy::Config dialog -node {Toolbars Classy::Editor} -level appuser
