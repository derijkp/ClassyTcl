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

set data {
menu "File" {
	action "Open file" {%W insert insert "Open: %W"} <<Load>>
	action "Open next" {%W insert insert "Open next: %W"} <<LoadNext>>
	action "Test" {%W insert insert "Test: %W"} <<Try>>
	menu "Trying" {
		action "Trying" {%W insert insert "submenu: %W"} <Alt-d>
		action "Trying2" {%W insert insert "submenu2: %W"}
	}
	action Save {puts save} Save
	radio "Radio try" {-variable test -value try} <<Radio1>>
	radio "Radio try2" {-variable test -value try2} <<Radio2>>
} <Alt-f>
menu "Find" {
	action "Goto line" {puts "Goto line"} <<Goto>>
	action "Find" {%W insert end find} <<Find>>
	separator
	action "Replace & Find next" {%W insert end replace} <<ReplaceFindNext>>
	check "Search Reopen" {-variable test%W -onvalue yes -offvalue no} <<SearchReopen>>
}
action "Test" {%W insert insert "Test: %W"} <Alt-t>
}

#builder
set object .try
catch {destroy $object}
Classy_menueditor $object -savecommand puts
$object load $data
private $object current menu
	set node {File Save}

$object load $data

if 0 {
	$object load $data
	.try copy
	.try paste
	.try delete
	Classy::menu_edit def Classy_Test
}
