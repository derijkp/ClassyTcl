source testapp
set object .try
Classy::Builder .try
set object .try.dedit
set window .try.dedit.work

.try configure -dir /home/peter/dev/ClassyTcl/widgets/

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

