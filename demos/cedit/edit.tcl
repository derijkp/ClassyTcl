#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"
#
# ClassyTcl
# --------- Peter De Rijk
#

wm withdraw .
tk appname cedit
package require ClassyTcl
set pwd [pwd]

proc end {w} {
	destroy $w
	if {"[winfo children .]" == ".classy__editormenu"} {
		exit
	}
}

proc savestate {} {
	global pwd
	set state ""
	foreach win [winfo children .] {
		if [regexp {^.classy__edit[0-9]+} $win] {
			lappend state [wm geometry $win] [$win.editor private reopenlist] [$win.editor private curfile]
		}
	}
	Classy::Default set app state_$pwd $state
	Classy::Default save app
}

set state [Classy::Default get app state_$pwd]
if {("$state" == "")||("$argv" != "")} {
	set w .classy__edit1
	catch {destroy $w}
	toplevel $w -bd 0 -highlightthickness 0
	wm protocol $w WM_DELETE_WINDOW "destroy $w"
	Classy::Editor $w.editor -loadcommand "Classy::title $w" -closecommand "after idle \{end $w\}"
	pack $w.editor -fill both -expand yes
	eval $w.editor load $argv
} else {
	set num 1
	foreach {geom files curfile} $state {
		set w .classy__edit$num
		catch {destroy $w}
		toplevel $w -bd 0 -highlightthickness 0
		wm geometry $w $geom
		wm protocol $w WM_DELETE_WINDOW "destroy $w"
		Classy::Editor $w.editor -loadcommand "Classy::title $w" -closecommand "after idle \{end $w\}"
		pack $w.editor -fill both -expand yes
		eval $w.editor load $files
		$w.editor load $curfile
		incr num
	}
}


proc edit {args} {
	if {"$args"==""} {set args "Newfile"}
	set w .classy__edit
	set num 1
	while {[winfo exists $w$num] == 1} {incr num}
	set w $w$num
	catch {destroy $w}
	toplevel $w -bd 0 -highlightthickness 0
	wm protocol $w WM_DELETE_WINDOW "destroy $w"
	Classy::Editor $w.editor -loadcommand "Classy::title $w" -closecommand "after idle \{end $w\}"
	pack $w.editor -fill both -expand yes
	eval $w.editor load $args
	return $w
}
