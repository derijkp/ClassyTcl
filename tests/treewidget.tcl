#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl
classyclean

set object .try
package require ClassyTcl
proc browse {dir} {
	.try clearnode $dir
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
		.try addnode $dir $file -text [file tail $file]
	}
	foreach file [lsort $files] {
		.try addnode $dir $file -type end -text [file tail $file] -length [expr [file size $file]/1000.0]
	}
}

catch {Classy::TreeWidget destroy}
source ../widgets/TreeWidget.tcl
Classy::TreeWidget .try
pack .try -expand yes -fill both -side left

.try configure -endnodecommand puts
.try configure -closecommand ".try clearnode"
.try configure -opencommand browse
.try configure -rootcommand {puts root}

.try addnode {} .. -text ..
browse ..
browse ../help
update idletasks

if 0 {
	browse .try ../help/classy_defaults.html
	browse .try ../help/basic
	.try closenode ../help
	.try opennode ../help
	.try clearnode ../help
	.try deletenode ../help
}
# tree addnode ~ -image folder

#manualtest
#testsummarize

#.try deletenode ../apps/cedit/conf/init/Menus.tcl

