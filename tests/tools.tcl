if ![info exists classy_tools] {
set classy_tools 1
set auto_path [concat [file dir [pwd]] $auto_path]
if [catch {package require Class}] {
	lappend auto_path [file dir [file dir [pwd]]]
	package require Class
}
catch {tk appname test}
catch {package require ClassyTcl}
catch {
wm geometry . +[expr [winfo screenwidth .]/2 - [winfo width .]/2]+[expr [winfo screenheight .]/2 - [winfo height .]/2]
raise .
}

if ![info exists testleak] {
	if {"$argv" != ""} {
		set testleak [lindex $argv 0]
	} else {
		set testleak 0
	}
}

catch {
	if !$tcl_interactive {
		destroy .classy__.error
		toplevel .classy__.error
		wm geometry .classy__.error +0+0
		raise .classy__.error
		text .classy__.error.text
		pack .classy__.error.text -expand yes -fill both
	}
}

proc display {e} {
	puts $e
	catch {
		.classy__.error.text insert end "$e\n"
		.classy__.error.text yview end
		update
	}
}

proc clean {} {
	catch {Base destroy}
	catch {eval destroy [winfo children .]}
	catch {. configure -menu {}}
	catch {::Test destroy}
	catch {::try destroy}
	catch {::.try destroy}
	catch {rename ::Test {}}
	catch {rename ::try {}}
	catch {rename ::.try {}}
	Class subclass Base
}

proc classyclean {} {
	catch {Widget destroy}
	catch {eval destroy [winfo children .]}
	catch {. configure -menu {}}
	catch {::Test destroy}
	catch {::try destroy}
	catch {::.try destroy}
	catch {rename ::Test {}}
	catch {rename ::try {}}
	catch {rename ::.try {}}
	catch {unset ::try}
	Classy::initconf
}

proc test {name description script expected {causeerror 0} args} {
	global errors testleak
	
	set e "testing $name: $description"
	display $e
	proc tools__try {} $script
	set error [catch tools__try result]
	if $causeerror {
		if !$error {
			set e "test should cause an error\nresult is \n$result"
			display $e
			lappend errors "$name:$description" "test should cause an error\nresult is \n$result"
			return
		}	
	} else {
		if $error {
			set e "test caused an error\nerror is \n$result\n"
			display $e
			lappend errors "$name:$description" "test caused an error\nerror is \n$result\n"
			return
		}
	}
	if {"$result"!="$expected"} {
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
				puts "possible leak:"
				puts $line1
				puts $line2
				puts "\n"
			}
		}
	}
	return
}

proc manualtest {{message {}}} {
return
	destroy .manualtest
	toplevel .manualtest
	set message "Please test manually\nPress Ok when done\n$message"
	message .manualtest.m -text $message -justify center -width 500
	button .manualtest.b -text Ok -command {destroy .manualtest}
	pack .manualtest.m
	pack .manualtest.b
	wm geometry .manualtest +[expr [winfo screenwidth .]/2]+[expr [winfo screenheight .]/2]
	tkwait window .manualtest
}

proc testsummarize {} {
	global errors
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
		catch {
			raise .classy__.error
#			wm geometry .classy__.error +[expr [winfo screenwidth .]/2]+[expr [winfo screenheight .]/2]
			toplevel .classy__.ask
			message .classy__.ask.msg -text "There were errors"
			button .classy__.ask.continue -text Continue -command {destroy .classy__.ask}
			button .classy__.ask.exit -text Exit -command {exit}
			grid .classy__.ask.msg - -sticky nwse
			grid .classy__.ask.exit .classy__.ask.continue 
			wm geometry .classy__.ask +[expr [winfo screenwidth .]/2]+[expr [winfo screenheight .]/2]
			tkwait window .classy__.ask
		}
		unset errors
	} else {
		catch {destroy .final}
		if ![catch {toplevel .final}] {
			message .final.m -text "All tests ok" -justify center
			button .final.b -text Exit -command exit
			pack .final.m
			pack .final.b
			wm geometry .final +[expr [winfo screenwidth .]/2]+[expr [winfo screenheight .]/2]
		} else {
			puts "All tests ok"
		}
	}
}

catch {unset errors}
if $testleak {
	test test {initialise all memory for testing with leak detection} {
		set try 1
	} 1 0 noleak
}
}
