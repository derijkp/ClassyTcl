#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl
classyinit test

proc browse {w pid dir} {
	set id [$w add $pid name [file tail $dir] image folder]
	set dirs {}
	set files {}
	foreach file [glob -nocomplain $dir/*] {
		if {[file isdirectory $file]} {
			lappend dirs $file
		} else {
			lappend files $file
		}
	}
	foreach file [lsort $dirs] {
		browse $w $id $file
	}
	foreach file [lsort $files] {
		$w add $id name [file tail $file] image document
	}
	return $id
}
Classy::TreeView .t -width 400 -height 400 -hide 1
pack .t -expand yes -fill both

.t put 0 name "TreeView Demo 1"
browse .t 0 ../../tcl++
browse .t 0 ../../tk++
browse .t 0 ../../widgets++


