#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::Editor {Editor and find} {
	classyclean
	Classy::Editor .try \
		-loadcommand "wm title . "
	pack .try -fill both -expand yes
	.try load try/init.txt try/a.tcl try/temp
	.try find try
	.try get sel.first sel.last
} {try}

test Classy::Editor {edit and insert} {
	classyclean
	set ::w [edit try/try.tcl]
	wm geometry $::w +0+0
	$::w.editor insert end try
	$::w.editor get "end-4c" "end-1c"
} {try}

catch {destroy $::w}

test Classy::Editor {links} {
	classyclean
	toplevel .t
	wm geometry .t +0+0
	Classy::Editor .t.try -width 20 -height 10
	Classy::Editor .t.try2 -width 20 -height 10
	Classy::Editor .t.try3 -width 20 -height 10
	Classy::Editor .t.try4 -width 20 -height 10
	grid .t.try .t.try2 -sticky nwse
	grid .t.try3 .t.try4 -sticky nwse
	grid columnconfigure .t 0 -weight 1
	grid columnconfigure .t 1 -weight 1
	grid rowconfigure .t 0 -weight 1
	grid rowconfigure .t 1 -weight 1
	.t.try load try/try try/init.txt try/a.tcl try/temp
	.t.try2 load [pwd]/try/try try/init.txt try/a.tcl try/temp
	.t.try insert end try
	.t.try2 get "end-4c" "end-1c"
} {try}

catch {destroy .t}

testsummarize
