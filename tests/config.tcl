#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::config {basic} {
	clean
	eval destroy [winfo children .]
	classyinit test
	Classy::Configurator dialog
	update idletasks
	manualtest
} {}

testsummarize
catch {unset errors}
