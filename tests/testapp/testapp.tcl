#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" ${1+"$@"}
# ClassyTcl Builder v0.2

wm withdraw .
if {"[lindex $argv 0]" == "-builder"} {
	set builder 1
	set argv [lrange $argv 1 end]
}
set script [info script]
if {"$script"==""} {
	set appname classyapp
} else {
	if {"$tcl_platform(platform)"=="unix"} {
		if {"[file pathtype $script]"!="absolute"} {
			set script [file join [pwd] $script]
		}
		while 1 {
			if [catch {set link [file readlink $script]}] break
			if {"[file pathtype $link]"=="absolute"} {
				set script $link
			} else {
				set script [file join [file dirname $script] $link]
			}
		}
	}
	set appname [file root [file tail $script]]
}
tk appname $appname
# $Format: "package require -exact ClassyTcl 0.$ProjectMajorVersion$"$
package require -exact ClassyTcl 0.3
set pwd [pwd]
lappend Classy::help_path [file join $Classy::appdir help]
lappend auto_path [file join $Classy::appdir lib interface] [file join $Classy::appdir lib code]
set Classy::starterror [catch {eval main $argv} Classy::result]
set Classy::starterrorinfo $errorInfo
if $Classy::starterror {
	puts $Classy::result
}
if [info exists builder] {
	Classy::Builder .classy__.builder
	raise .classy__.builder
	if $Classy::starterror {
		set errorInfo $Classy::starterrorinfo
		bgerror $Classy::result
	}
} elseif $Classy::starterror {
	error $Classy::result $Classy::starterrorinfo
}
