#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::CmdWidget {create and configure} {
	clean
	eval destroy [winfo children .]
	tk appname test
	package require ClassyTcl
	Classy::CmdWidget .try
	pack .try
	.try cget -prompt
} {[pwd] % }

testsummarize
catch {unset errors}

