#!/bin/sh
# the next line restarts using wish \
exec tclsh "$0" "$@"

source tools.tcl
lappend auto_path autoload_test

catch {Test destroy}
set temp [Test new]





# - 4240
# 2416 4952
Class subclass Test
time {
for {set i 0} {$i < 10000} {incr i} {
	Test new
}
}

test class {changeclass} {
	clean
	Class subclass Test
	Test subclass STest
	Test method amethod {} {
		return Test
	}
	STest method amethod {} {
		return STest
	}
	set object [Test new]
	set result [$object amethod]
	$object changeclass STest
	lappend result [$object amethod]
} {Test STest}

