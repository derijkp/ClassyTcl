#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::Dialog {create and test go button} {
	classyclean
	Classy::Dialog .try
	.try add go "Go" {puts stdout go;set ::try go} default
	.try add test "Test" {puts stdout test;set ::try test}
	set ::try 1
	update
	.try invoke go
	set ::try
} {go}

test Classy::Dialog {create and test default button} {
	classyclean
	Classy::Dialog .try
	.try add go "Go" {puts go;set ::try go} default
	.try add test "Test" {puts test;set ::try test}
	set ::try 1
	update
	event generate .try <Return>
	set ::try
} {go}

test Classy::Dialog {create and test escape} {
	classyclean
	Classy::Dialog .try
	.try add go "Go" {puts stdout go;set ::try go} default
	.try add test "Test" {puts stdout test;set ::try test}
	set ::try 1
	update
	event generate .try <Escape>
	set ::try
} {1}

test Classy::Dialog {create and test test button} {
	classyclean
	Classy::Dialog .try
	.try add go "Go" {puts stdout go;set ::try go} default
	.try add test "Test" {puts stdout test;set ::try test}
	set ::try 1
	update
	.try invoke test
	set ::try
} {test}

test Classy::Dialog {error in go button} {
	classyclean
	Classy::Dialog .try
	.try add go "Go" {error error} default
	.try add test "Test" {puts stdout test;set ::try test}
	set ::try 1
	update
	.try invoke go
	set ::try
} {error} 1

test Classy::Dialog {add options} {
	classyclean
	Classy::Dialog .try
	.try add go "Go" {puts stdout go;set ::try go} default
	.try add test "Test" {puts stdout test;set ::try test}
	.try add test2 "Test 2" {puts stdout test2;set ::try test2}
	set w [.try component options]
	entry $w.e
	pack $w.e
	focus $w.e
	update
	.try persistent remove -all
	set ::try 1
	.try invoke test2
	set ::try
} {test2}

test Classy::Dialog {with Classy::Entry} {
	classyclean
	Classy::Dialog .try
	.try add go "Go" {puts stdout go;set ::try [.try.options.entry get]} default
	.try add test "Test" {puts stdout test;set ::try [.try.options.entry get]}
	Classy::Entry .try.options.entry
	.try.options.entry set try
	pack .try.options.entry
	set ::try 1
	update
	.try invoke go
	set ::try
} {try}

test Classy::Dialog {no shifting} {
	classyclean
	Classy::Dialog .try -closecommand {
		destroy .try
		Classy::Dialog .try
	}
	.try persistent add close
	update idletasks
	wm geometry .try 200x200
	set try 1
} {1}

test Classy::SelectDialog {create and configure} {
	classyclean
	Classy::SelectDialog .try
	.try configure -command {
		set ::try 
	}
	.try fill {hallo daar {Hoe gaat het?} ermee jo}
	update
	set ::try ""
	.try activate 3
	.try invoke go
	set ::try
} {ermee}

test Classy::SelectDialog {hide if cache} {
	classyclean
	Classy::SelectDialog .try -cache 1
	update
	.try invoke go
	winfo exists .try
} {1}

test Classy::SelectDialog {destroy if no cache} {
	classyclean
	Classy::SelectDialog .try
	update
	.try invoke go
	update idletasks
	winfo exists .try
} {0}

test Classy::SelectDialog {add item} {
	classyclean
	Classy::SelectDialog .try -command {puts}
	.try configure -addcommand {invoke {} {puts add:$args;set temp {ok end}}}
	.try configure -deletecommand {invoke {} {puts del:$args}}
	.try configure -renamecommand {invoke {} {puts ren:$args}}
	.try fill {hallo daar {Hoe gaat het?} ermee jo}
	set ::try try
	update
	.try invoke add
	.try activate end
	.try get
} {ok}

test Classy::yorn {basic} {
	classyclean
	Classy::yorn "answer yes please"
} {1}

test Classy::FileSelect {basic} {
	classyclean
	Classy::FileSelect .try
	.try configure -textvariable try2 -selectmode persistent \
	    -default try -command {invoke {} {set ::try $args}}
	set w [.try component extra]
	button $w.test -text "Please select dialog.tcl"
	pack $w.test -fill x -expand yes
	.try configure -dir [pwd] -filter *
	.try set dialog.tcl
	set ::try ""
	tkwait window .try
	file tail [set ::try]
} {dialog.tcl}

test Classy::savefile {basic} {
	classyclean
	file tail [Classy::savefile -initialdir [pwd] -initialfile dialog.tcl]
} {dialog.tcl}

test Classy::selectfile {basic} {
	classyclean
	file tail [Classy::selectfile -initialdir [pwd] -initialfile dialog.tcl]
} {dialog.tcl}

test Classy::InputDialog {basic} {
	classyclean
	Classy::InputDialog .try -title Open -buttontext Open
	.try set try
	.try get
} {try}

test Classy::InputDialog {basic} {
	classyclean
	Classy::InputDialog .try -title Open -buttontext Open -command {set try}
	.try set try
	set ::try ""
	.try invoke go
	set ::try
} {try}

#test Classy::SaveDialog {basic} {
#	classyclean
#	Classy::SaveDialog .try -textvariable colfile
#	.try set try
#	file tail [.try get]
#} {try}
#
test Classy::savefile {basic} {
	classyclean
	file tail [Classy::savefile -initialfile try]
} {try}

testsummarize


