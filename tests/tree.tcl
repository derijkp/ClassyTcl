#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl
classyclean

set object try
package require ClassyTcl
proc browse {tree dir} {
	if {"$dir" == ""} return
	switch [try type $dir] {
		end {
			try selection set $dir
			puts $dir
		}
		open {
			try clearnode $dir
		}
		closed {
			try clearnode $dir
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
				$tree addnode $dir $file -text [file tail $file]
			}
			foreach file [lsort $files] {
				$tree addnode $dir $file -type end -text [file tail $file] -length [expr [file size $file]/1000.0]
			}
		}
	}
	.c configure -scrollregion [.c bbox all]
}

canvas .c -yscrollcommand {.s set}
scrollbar .s -command {.c yview}
pack .s -fill y -side left
pack .c -expand yes -fill both -side left
Classy::Tree new try -canvas .c

try addnode {} .. -text ..
browse try ..
browse try ../help
update idletasks
.c configure -scrollregion [.c bbox all]
bind .c <<Action>> {
puts "%x %y"
	set node [try node %x %y]
	browse try $node
}
if 0 {
	browse try ../help/classy_defaults.html
	browse try ../help/basic
	try closenode ../help
	try opennode ../help
	try clearnode ../help
	try deletenode ../help
}
# tree addnode ~ -image folder

#manualtest
#testsummarize

#try deletenode ../apps/cedit/conf/init/Menus.tcl
