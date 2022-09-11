#!/bin/sh
# the next line restarts using wish \
exec tclsh "$0" "$@"

source tools.tcl
lappend auto_path autoload_test

test autoload {Class::auto_mkindex} {
	Class::auto_mkindex autoload_test
} {}

test autoload {bugfix: autoload with auto name should not segfault} {
	catch {Test destroy}
	set temp [Test new]
	set a 1
} {1}

test autoload {autoload method from object} {
	catch {Test destroy}
	Test new try 1
	try add 2
	try getdata
} {3}

test autoload {autoload method defined for superclass from object} {
	catch {Test destroy}
	SubTest new try 1
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

test autoload {autoload classmethod defined for superclass from Class} {
	catch {Test destroy}
	SubTest setdef 2
	SubTest new try
	try add 2
	try getdata
} {4}

testsummarize
