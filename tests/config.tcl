#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl
#Classy::Builder .classy__.builder -dir ../dialogs

test Classy::Config {basic} {
	classyclean
	Classy::Config dialog
	update idletasks
	manualtest
} {}

testsummarize

Classy::Config dialog -node {Menus Classy::Editor} -level appdef
Classy::Config dialog -node {Toolbars Classy::Editor} -level appuser
