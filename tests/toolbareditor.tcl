#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"

source tools.tcl
proc builder {} {
	catch {destroy .classy__.error}
	set object .builder
	catch {Classy::Builder destroy}
	Classy::Builder .builder
	.builder configure -dir /home/peter/dev/ClassyTcl/dialogs
}

proc tproc {w} {
	Classy::Entry $w
	return [list $w configure -command [list invoke {v} {puts %W:$v}]]
}

set data {
	action open "Open" {fileload %W}
	action save "Save" {filesave %W}
	separator
	action "Test" "Test" {%W insert end test}
	action "OK" "OK" {%W insert end OK}
	label label "Just a label"
	tool tproc "Proc"
	widget Classy::Entry "Entry" {-command {invoke v {puts %W:$v}}}
	check copy "Copy" {-variable copy -command {puts %W:$copy}}
	radio opt1 "opt1" {-variable opt -value opt1 -command {puts %W:$opt}}
	radio opt2 "opt2" {-variable opt -value opt2 -command {puts %W:$opt}}
}

#builder
set object .try
catch {destroy $object}
Classy_toolbareditor $object -savecommand puts
$object load $data
private $object current toolbar

$object load $data

if 0 {
	$object load $data
	.try copy
	.try paste
	.try delete
	Classy::toolbar_edit def Classy_Test

.try copy {}
}

