#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl 

set trydata {
	menu file "File" {
		action Load "Open file" {%W insert insert "Open: %W"}
		action LoadNext "Open next" {%W insert insert "Open next: %W"}
		action Try "Test" {%W insert insert "Test: %W"}
		menu trying "Trying" {
			action Try "Trying" {puts try}
		}
		action Save Save {puts save}
		radio Radio1 "Radio try" {-variable test -value try}
		radio Radio2 "Radio try2" {-variable test -value try2}
	} Alt-f
	# The find menu
	menu find "Find" {
		action Goto "Goto line" {puts "Goto line"}
		action Find "Find" {%W insert end find}
		separator
		action ReplaceFindNext "Replace & Find next" {%W insert end replace}
		check SearchReopen "Search Reopen" {-variable test%W -onvalue yes -offvalue no}
	}
	action Trytop "Test" {%W insert insert "Test: %W"} Alt-t
	check SearchReopen "Search Reopen" {-variable [testit %W] -onvalue yes -offvalue no} Control-Alt-t
}
proc testit w {return ok}

test Classy::DynaMenu {popopmenu} {
	clean
	eval destroy [winfo children .]
	classyinit test

	text .b -width 10 -height 5
	text .t -width 10 -height 5
	pack .b .t -side left -fill both -expand yes
	Classy::DynaMenu define Test $::trydata
#	set object Classy::DynaMenu;set menutype Test; set menu .top;set cmdw .t;set bindtag TestBind
	Classy::DynaMenu makepopup Test .top .t TestBind
	bindtags .t "TestBind [bindtags .t]"
	bindtags .b "TestBind [bindtags .b]"
	. configure -menu .top
	manualtest
	set try 1
} {1}

test Classy::DynaMenu {topmenu} {
	clean
	. configure -menu {}
	eval destroy [winfo children .]
	classyinit test

	text .b -width 10 -height 5
	text .t -width 10 -height 5
	Classy::DynaMenu define Test $::trydata
#	set object Classy::DynaMenu;set menutype Test; set menu .top;set cmdw .t;set bindtag TestBind
	Classy::DynaMenu maketop Test .top .t TestBind
	pack .top -side top -fill x
	pack .b .t -side left -fill both -expand yes
	bindtags .t "TestBind [bindtags .t]"
	bindtags .b "TestBind [bindtags .b]"
	manualtest
	set try 1
} {1}

test Classy::DynaMenu {find definition} {
	clean
	. configure -menu {}
	eval destroy [winfo children .]
	classyinit test

	text .t -width 10 -height 5
	Classy::DynaMenu maketop Classy::Editor .top .t TestBind
	pack .top -side top -fill x
	pack .t -side left -fill both -expand yes
	bindtags .t "TestBind [bindtags .t]"
	manualtest
	set try 1
} {1}
testsummarize
catch {unset errors}
