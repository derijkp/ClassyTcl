#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"

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

test Classy::Config {node, level appuser} {
	Classy::Config dialog -node {Toolbars ClassyTcl Editor} -level appuser
	update idletasks
	manualtest
} {}

test Classy::Config {node, level appdef} {
	Classy::Config dialog -node {Menus ClassyTcl Editor} -level appdef
	update idletasks
	manualtest
} {}

testsummarize

