if ![info exists classy_tools] {
set classy_tools 1

package require Class

catch {tk appname test}

catch {
wm geometry . +[expr [winfo screenwidth .]/2 - [winfo width .]/2]+[expr [winfo screenheight .]/2 - [winfo height .]/2]
raise .
}

proc clean {} {
	catch {Class destroy}
	catch {eval destroy [winfo children .]}
	catch {. configure -menu {}}
}

proc classyclean {} {
	catch {Class destroy}
	catch {eval destroy [winfo children .]}
	catch {. configure -menu {}}
	tk appname test
	package require ClassyTcl
}

proc test {name description script expected {causeerror 0}} {
	global errors
	
	puts "testing $name: $description"
	proc tools__try {} $script
	set error [catch tools__try result]
	if $causeerror {
		if !$error {
			puts "test should cause an error\nresult is \n$result"
			lappend errors "$name:$description" "test should cause an error\nresult is \n$result"
			return
		}	
	} else {
		if $error {
			puts "test caused an error\nerror is \n$result\n"
			lappend errors "$name:$description" "test caused an error\nerror is \n$result\n"
			return
		}
	}
	if {"$result"!="$expected"} {
		puts "error: result is:\n$result\nshould be\n$expected"
		lappend errors "$name:$description" "error: result is:\n$result\nshould be\n$expected"
	}
	return
}


proc manualtest {{message {}}} {
	destroy .manualtest
	toplevel .manualtest
	set message "Please test manually\nPress Ok when done\n$message"
	message .manualtest.m -text $message -justify center -width 500
	button .manualtest.b -text Ok -command {destroy .manualtest}
	pack .manualtest.m
	pack .manualtest.b
#	regexp {^([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)$} [winfo geometry .] temp w h x y
	wm geometry .manualtest +[expr [winfo screenwidth .]/2]+[expr [winfo screenheight .]/2]
#	wm geometry .manualtest +[expr $x+$w/2]+[expr $y+$h/2]
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
		puts $error
		catch {
			destroy .error
			toplevel .error
			wm geometry .error +0+0
			raise .error
			text .error.text
			pack .error.text -expand yes -fill both
			.error.text insert end $error
			button .error.b -text Exit -command {destroy .error}
			pack .error.b
			wm geometry .error +[expr [winfo screenwidth .]/2]+[expr [winfo screenheight .]/2]
		}
		tkwait window .error
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

if [info exists errors] {unset errors}
}
