#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl
classyclean
set object .try
proc browse {dir {pre {sm_}}} {
	if {"$dir" == ""} return
	.try clear
	set dirs {}
	set files {}
	foreach file [glob -nocomplain $dir/*] {
		if {[file isdirectory $file]} {
			lappend dirs $file
		} else {
			lappend files $file
		}
	}
	set data {}
	.try add [file dir $dir] -text .. -image [Classy::geticon ${pre}folder]
	foreach file [lsort $dirs] {
		file lstat $file temp
		array set attr [file attributes $file]
		set data ""
		lappend data $attr(-permissions)
		lappend data "$attr(-owner).$attr(-group)"
		lappend data $temp(size)
		lappend data [clock format $temp(mtime) -format "%b %d %H:%M %Y"]
		.try add $file -text [file tail $file] -image [Classy::geticon ${pre}folder] \
			-data $data
	}
	foreach file [lsort $files] {
		file lstat $file temp
		array set attr [file attributes $file]
		set data ""
		lappend data $attr(-permissions)
		lappend data "$attr(-owner).$attr(-group)"
		lappend data $temp(size)
		lappend data [clock format $temp(mtime) -format "%b %d %H:%M %Y"]
		.try add $file -text [file tail $file] -image [Classy::geticon ${pre}file] \
			-data $data
	}
}

SmallBrowser .try
pack .try -fill both -expand yes

browse ..
bind .try.c <<Action>> {
	set name [.try name %x %y]
	puts [list %x %y $name [.try type %x %y]]
	if [file isdir $name] {
		browse $name {}
	} else {
		puts $name
	}
}

.try configure -order column -data {perm owner size date} -minx 0 -miny 0

.try configure -order list -minx 0 -miny 0 -dataunder 0

browse .. {}
.try configure -order row -minx 0 -miny 0 -dataunder 1

.try configure -order column -minx 0 -miny 0 -dataunder 1

manualtest
testsummarize
