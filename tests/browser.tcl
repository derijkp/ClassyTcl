#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

proc gettext {file} {
	return [file tail $file]
}

proc getimage {file} {
	if {[file isdirectory $file]} {
		return [Classy::geticon folder]
	} else {
		return [Classy::geticon file]
	}
}

proc getsmimage {file} {
	set pre {}
	if {[file isdirectory $file]} {
		return [Classy::geticon sm_folder]
	} else {
		return [Classy::geticon sm_file]
	}
}

proc getdata {file} {
	file lstat $file temp
	array set attr [file attributes $file]
	set data ""
	lappend data $attr(-permissions)
	lappend data "$attr(-owner).$attr(-group)"
	lappend data $temp(size)
	lappend data [clock format $temp(mtime) -format "%b %d %H:%M %Y"]
	return $data
}

proc getdir {dir} {
	if {"$dir" == ""} return
	set dirs {}
	set files {}
	foreach file [glob -nocomplain $dir/*] {
		if {[file isdirectory $file]} {
			lappend dirs $file
		} else {
			lappend files $file
		}
	}
	set result ..
	foreach file [lsort $dirs] {
		lappend result $file
	}
	foreach file [lsort $files] {
		lappend result $file
	}
	return $result
}

classyclean
set object .try

Browser .try -gettext gettext -getimage getimage -getdata getdata
pack .try -fill both -expand yes

.try configure -list [getdir try]

bind [.try component canvas] <<Action>> {
	set name [.try name %x %y]
	set type [.try type %x %y]
	.try active set $name
	puts [list %x %y $name $type]
	set curdir [file dirname [lindex [.try cget -list] 1]]
	if {"$name" == ".."} {set name [file dirname $curdir]}
	if [file isdir $name] {
		.try configure -list [getdir $name]
	} elseif {"$type"=="text"} {
		.try selection add $name
		puts $name
	} else {
		puts $name
	}
}
.try configure -order list -minx 0 -miny 0 -data {perm owner size date} \
	-dataunder 0 -getimage getsmimage

.try configure -order column -data {perm owner size date} -minx 0 -miny 0

.try configure -order list -minx 0 -miny 0 -dataunder 0

.try configure -order row -minx 0 -miny 0 -dataunder 1

.try configure -order column -minx 0 -miny 0 -dataunder 1

.try configure -order list -minx 0 -miny 0 -dataunder 0 -getimage getsmimage

# manualtest
# testsummarize
