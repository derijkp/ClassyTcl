#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

proc d {} {
	Classy::Dialog .d -title "Test"
	entry .d.options.e
	grid .d.options.e
	frame .d.options.f
	grid .d.options.f
	button .d.options.f.b -text try -command {puts ok}
	grid .d.options.f.b
	.d add go "Go" {puts go} default
}

set object .try
set base .d
catch {destroy .d}
catch {Classy::Builder destroy}
Classy::Builder .try
#d
#.try edit .d

#test Classy::Builder {} {
#} {}

#testsummarize

if 0 {
	set object .try.dedit
	set w .try.confedit.geom
	eval destroy [winfo children $w]
	Classy::cleargrid $w
}

set object .try.dedit
set window .try.dedit.work

proc browse {w dir} {
	$w clearnode $dir
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
		$w addnode $dir $file -text [file tail $file]
	}
	foreach file [lsort $files] {
		$w addnode $dir $file -type end -text [file tail $file] -length [expr [file size $file]/1000.0]
	}
}

#testapp
if 0 {
	set object .try
	Classy::Builder .try
	set object .try.dedit
	set window .try.dedit.work
}