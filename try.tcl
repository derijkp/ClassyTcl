source cdraw
set object .classy__.builder
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

