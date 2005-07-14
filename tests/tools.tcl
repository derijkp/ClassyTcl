if ![info exists classy_tools] {
set classy_tools 1
set auto_path [concat [file dir [pwd]] $auto_path]
if [catch {package require Class}] {
	lappend auto_path [file dir [file dir [pwd]]]
	package require Class
}

if ![info exists testleak] {
	if {"$argv" != ""} {
		set testleak [lindex $argv 0]
	} else {
		set testleak 0
	}
}

proc clean {} {
	catch {Base destroy}
	catch {::Test destroy}
	catch {::Try destroy}
	catch {::try destroy}
	catch {::.try destroy}
	catch {rename ::Test {}}
	catch {rename ::try {}}
	catch {rename ::.try {}}
	Class subclass Base
}

proc display {e} {
	puts $e
}

proc test {name description script expected {causeerror 0} args} {
	global errors testleak
	
	set e "testing $name: $description"
	if ![info exists ::env(TCL_TEST_ONLYERRORS)] {display $e}
	proc tools__try {} $script
	set error [catch tools__try result]
	if $causeerror {
		if !$error {
			if [info exists ::env(TCL_TEST_ONLYERRORS)] {display "-- test $name: $description --"}
			set e "test should cause an error\nresult is \n$result"
			display $e
			lappend errors "$name:$description" "test should cause an error\nresult is \n$result"
			return
		}	
	} else {
		if $error {
			if [info exists ::env(TCL_TEST_ONLYERRORS)] {display "-- test $name: $description --"}
			set e "test caused an error\nerror is \n$result\n"
			display $e
			lappend errors "$name:$description" "test caused an error\nerror is \n$result\n"
			return
		}
	}
	if {"$result"!="$expected"} {
		if [info exists ::env(TCL_TEST_ONLYERRORS)] {display "-- test $name: $description --"}
		set e "error: result is:\n$result\nshould be\n$expected"
		display $e
		lappend errors "$name:$description" $e
	}
	if $testleak {
		set line1 [lindex [split [exec ps l [pid]] "\n"] 1]
		time {set error [catch tools__try result]} $testleak
		set line2 [lindex [split [exec ps l [pid]] "\n"] 1]
		if {([lindex $line1 6] != [lindex $line2 6])||([lindex $line1 7] != [lindex $line2 7])} {
			if {"$args" != "noleak"} {
				if [info exists ::env(TCL_TEST_ONLYERRORS)] {display "-- test $name: $description --"}
				puts "possible leak:"
				puts $line1
				puts $line2
				puts "\n"
			}
		}
	}
	return
}

proc testsummarize {} {
	if [info exists ::env(TCL_TEST_ONLYERRORS)] return
	global errors dontcleanerrors
	if [info exists errors] {
		global currenttest
		if [info exists currenttest] {
			set error "***********************\nThere were errors in testfile $currenttest"
		} else {
			set error "***********************\nThere were errors in the tests"
		}
		foreach {test err} $errors {
			append error "\n$test  ----------------------------"
			append error "\n$err"
		}
		display $error
		if {![info exists dontcleanerrors]} {
			unset errors
		}
	} else {
		puts "All tests ok"
	}
}

if {![info exists dontcleanerrors]} {
	catch {unset errors}
}

if $testleak {
	test test {initialise all memory for testing with leak detection} {
		set try 1
	} 1 0 noleak
}
}
