#!/bin/sh
# the next line restarts using wish \
exec tclsh8.0 "$0" "$@"

source tools.tcl
lappend auto_path autoload_test

test autoload {Classy::auto_mkindex} {
	Classy::auto_mkindex autoload_test
} {}

test autoload {autoload method from object} {
	catch {Test destroy}
	Test new try 1
	try add 2
	try getdata
} {3}

test autoload {autoload classmethod from Class} {
	catch {Test destroy}
	Test setdef 2
	Test new try
	try add 2
	try getdata
} {4}

testsummarize
