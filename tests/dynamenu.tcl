#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl
source dynamenuinit.tcl
set object Classy::DynaMenu

test Classy::DynaMenu {topmenu} {
	classyclean
	text .b -width 10 -height 5
	text .t -width 10 -height 5
	pack .b .t -side left -fill both -expand yes
	Classy::DynaMenu define Test $::trydata
	Classy::DynaMenu attachmainmenu Test .t
	Classy::DynaMenu attachmainmenu Test .b
	Classy::DynaMenu attachmenu Test .t
	bindtags .t "Test_active [bindtags .t]"
	bindtags .b "Test_active [bindtags .b]"
	manualtest
	set try 1
} {1}

test Classy::DynaMenu {popopmenu} {
	classyclean
	text .b -width 10 -height 5
	text .t -width 10 -height 5
	pack .b .t -side left -fill both -expand yes
	Classy::DynaMenu define Test $::trydata
	set bindtag [Classy::DynaMenu bindtag Test]
	bindtags .t "$bindtag Test_active [bindtags .t]"
	bindtags .b "$bindtag Test_active [bindtags .b]"
	bind .t <<Menu>> {Classy::DynaMenu popup Test %X %Y}
	bind .b <<Menu>> {Classy::DynaMenu popup Test %X %Y}
	manualtest
	set try 1
} {1}

test Classy::DynaMenu {redefine error} {
	classyclean
	text .t -width 10 -height 5
	pack .t -side left -fill both -expand yes
	Classy::DynaMenu define Test $::trydata
	Classy::DynaMenu attachmainmenu Test .t
	update
	catch {Classy::DynaMenu define Test {dfgsdgf}} error
	regexp {^error while defining menu; restored old} $error
} {1}

test Classy::DynaMenu {activemenu} {
	classyclean
	text .t -width 10 -height 5
	pack .t -side left -fill both -expand yes
	proc p {} {
		return {{action OK {puts ok} Alt-a} Test_active}
	}
	Classy::DynaMenu define Test {
		activemenu "Active" p
	}
	Classy::DynaMenu attachmainmenu Test .t
	bindtags .t "Test_active [bindtags .t]"
	update
	proc p {} {
		return {{action OK {puts ok} Alt-b} Test_active}
	}
	Classy::DynaMenu updateactive Test
	bind Test_active
} {<Alt-Key-b>}

testsummarize
