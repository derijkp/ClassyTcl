#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl 

set trydata {
	menu file "File" {
		action Load "Open file" {%W insert insert "Open: %W"}
		action LoadNext "Open next" {%W insert insert "Open next: %W"}
		action Try "Test" {%W insert insert "Test: %W"}
		activemenu active "Active" {getmenu}
		menu trying "Trying" {
			action Try "Trying" {%W insert insert "submenu: %W"} Alt-d
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
}
proc testit w {return ok}
proc getmenu {} {
	puts ok
	return {
		action Test1 "Test1" {puts "Test1 ok"} Alt-a
		action Test2 "Test2" {%W insert end "Test2 ok"} Alt-b
	}
}

test Classy::DynaMenu {popopmenu} {
	classyclean
	text .b -width 10 -height 5
	text .t -width 10 -height 5
	pack .b .t -side left -fill both -expand yes
	Classy::DynaMenu define Test $::trydata
#	set object Classy::DynaMenu;set menutype Test; set menu .top;set cmdw .t;set bindtag TestBind
	Classy::DynaMenu makemenu Test .top .t TestBind
	bindtags .t "TestBind [bindtags .t]"
	bindtags .b "TestBind [bindtags .b]"
	. configure -menu .top
	manualtest
	set try 1
} {1}

test Classy::DynaMenu {find definition} {
	classyclean
	. configure -menu {}
	option add *Classy::Test.Menu $::trydata widgetDefault

	text .t -width 10 -height 5
	Classy::DynaMenu makemenu Classy::Test .top .t TestBind
	pack .t -side left -fill both -expand yes
	bindtags .t "TestBind [bindtags .t]"
	manualtest
	set try 1
} {1}

test Classy::DynaMenu {redefine error} {
	classyclean
	text .t -width 10 -height 5
	pack .t -side left -fill both -expand yes
	Classy::DynaMenu define Test $::trydata
	Classy::DynaMenu makemenu Test .top .t TestBind
	bindtags .t "TestBind [bindtags .t]"
	update
	catch {Classy::DynaMenu define Test {dfgsdgf}} error
	regexp {^error while defining menu; restored old} $error
} {1}

test Classy::DynaMenu {non existing cmdw} {
	classyclean
	Classy::DynaMenu define Test $::trydata
	Classy::DynaMenu makemenu Test .top .t TestBind .
	text .t -width 10 -height 5
	pack .t -side left -fill both -expand yes
	bindtags .t "TestBind [bindtags .t]"
	update
} {}

testsummarize
