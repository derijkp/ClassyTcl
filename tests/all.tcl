#!/bin/sh
# the next line restarts using wish \
exec tclsh8.0 "$0" "$@"

if [info exists env(TCL_TEST_DIR)] {
	cd $env(TCL_TEST_DIR)
}

if ![info exists env(TCL_TEST_ONLYERRORS)] {
	proc alltest file {
		global currenttest
		set currenttest $file
		puts "-----------------------------------------------------"
		puts "Test file $file"
		puts "-----------------------------------------------------"
		uplevel #0 source $file
	}
} else {
	proc alltest file {
		uplevel #0 source $file
	}
}

alltest class.tcl
alltest autoload.tcl
alltest version.tcl
