#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl 

test Classy::DynaTool {text} {
	classyclean
	Classy::DynaTool define Test {
		action open "Open" {puts open}
		action "Test" "Test" {puts test}
		action "OK" "OK" {puts OK}
	}
	Classy::DynaTool .try
	.try configure -type Test -cmdw .
	pack .try -fill x
	text .text
	pack .text -side bottom -fill both -expand yes
	manualtest
} {}

test Classy::DynaTool {no display} {
	classyclean
	Classy::DynaTool define Test {
		nodisplay
		action print "Print" {puts print}
		action "OK" "OK" {puts OK}
		check copy "Copy" {-variable copy}
	}
	Classy::DynaTool .t -type Test -cmdw .text
	pack .t -fill x
	text .text
	pack .text -side bottom
	set try 1
} {1}

test Classy::DynaTool {pictures} {
	classyclean
	Classy::DynaTool .try -type Classy::Dummy -cmdw .text
	pack .try -fill x
	text .text
	pack .text -side bottom
	set try 1
} {1}

test Classy::DynaTool {text} {
	classyclean
	Classy::DynaTool define Test {
		action "Test" "Test" {%W insert end test}
		action "OK" "OK" {%W insert end OK}
		label label "Just a label"
	}
	entry .e
	Classy::DynaTool .try -type Test -cmdw .text
	pack .try -fill x
	text .text
	pack .text -side bottom
	manualtest
} {}

test Classy::DynaTool {misc} {
	classyclean
	proc tproc {w} {
		Classy::Entry $w
		return [list $w configure -command [list invoke {v} {puts %W:$v}]]
	}
	Classy::DynaTool define Test {
		action "Test" "Test" {%W insert end test}
		action "OK" "OK" {%W insert end OK}
		label label "Just a label"
		tool tproc "Proc"
		widget Entry "Entry" {-command {invoke v {puts %W:$v}}}
		check copy "Copy" {-variable copy -command {puts %W:$copy}}
		radio opt1 "opt1" {-variable opt -value opt1 -command {puts %W:$opt}}
		radio opt2 "opt2" {-variable opt -value opt2 -command {puts %W:$opt}}
	}
	entry .e
	Classy::DynaTool .try -cmdw .text
	.try configure -type Test
	pack .try -fill x
	text .text
	pack .text -side bottom
	manualtest
} {}

test Classy::DynaTool {%W stress test} {
	classyclean
	catch {unset ::copy}
	catch {unset ::opt}
	proc tproc {w} {
		Classy::Entry $w
		return [list $w configure -command [list invoke {v} {puts %W:$v}]]
	}
	Classy::DynaTool define Test {
		action "Test" "Test" {%W insert end test}
		action "OK" "OK" {%W insert end OK}
		label label "Just a label"
		tool tproc "Proc"
		widget Entry "Entry" {-command {invoke v {puts %W:$v}}}
		check copy "Copy" {-variable copy(%W) -command {puts %W:$copy(%W)}}
		radio opt1 "opt1" {-variable opt -value opt1 -command {puts %W:$opt}}
		radio opt2 "opt2" {-variable opt -value opt2 -command {puts %W:$opt}}
	}
	entry .e
	Classy::DynaTool .try -cmdw .text
	.try configure -type Test
	pack .try -fill x
	text .text
	pack .text -side bottom
	manualtest
} {}

testsummarize

