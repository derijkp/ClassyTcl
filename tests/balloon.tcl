#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::Balloon {create and configure} {
	clean
	eval destroy [winfo children .]
	tk appname test
	package require ClassyTcl
	button .try -text try
	button .try2 -text try2
	pack .try .try2
	Classy::Balloon add .try "Trying it"
	Classy::Balloon add .try2 "Trying it too"
} {char}

testsummarize
catch {unset errors}

