set dir test
package require ClassyTcl
package require BioDesc

source cdraw.tcl
Builder .try
set object .try
set file lib/Main.tcl
set function mainw
set object .try.dedit
private $object data

set data [Classy::config_get $level {}]

source tools.tcl
set object .try
canvas .try
pack .try -fill both -expand yes
set id [.try create text 10 10]
	.try itemconfigure $id -anchor nw -text "Hallo allemaal" -width 50
.try delete all
for {set y 10} {$y < 500} {incr y 50} {
	for {set x 10} {$x < 500} {incr x 50} {
		.try create text $x $y -anchor nw -text "Hallo allemaal" -width 50
	}
}

classyclean
catch {CanvasSeq destroy}
catch {try destroy}
canvas .try
pack .try -fill both -expand yes
update idletasks
Classy::CanvasSeq new try -boxwidth 0 -canvas .try -area {10 10 210 250}
try configure -area {10 10 510 250} -end 780 -basesperline 500
try configure -endtick 1
bind .try <1> {
	puts "set x %x"
	puts "set y %y"
	puts [try xpos %x %y]
}
proc getboxes {start end} {
	return {
		{blue 20 160 20 {-fill blue}}
		{green 400 550 20 {-fill green}}
		{orange 650 720 -20 {-fill orange}}
	}
}
try configure -getboxes getboxes




source cfiles
set object .try
Classy::Builder .try
set object .try
set window .try.work

proc t {} {
	global data
	set level 0
	while 1 {
		if ![info exists data(v,$level)] break
		puts "$level: $data(v,$level) $data(a,$level)"
		incr level
	}
}

#.try configure -dir /home/peter/dev/ClassyTcl/widgets/

#caused segfault
source tools.tcl
set object .try
Classy::Builder .try
set object .try.dedit
set window .try.dedit.work
source ../../dialogs/ConfigDialogs.tcl
.try open /home/peter/dev/ClassyTcl/dialogs/ConfigDialogs.tcl Classy::config_frame frame
proc wrong {} {sfdgsdh}
Classy::Dialog .classy__.try
.classy__.try add go "Go" "$object test try" default
Classy::Dialog method invoke {item {button Action}} {
	after idle destroy $object
	.try.dedit test try
}
.classy__.try invoke go

#caused segfault
source tools.tcl
set args {}
set base .try
Classy::Selector $base -type color
$base set white
eval $base configure $args
after idle "$base redraw"
after idle "$base redraw"
$base redraw


