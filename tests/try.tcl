source tools.tcl

set object .try
	classyclean
	proc test args {puts $args}
	Classy::Entry .try
	pack .try -fill x -expand yes
	.try configure -label test -combo 10
	.try configure -state disabled
	.try configure -state combo

if 0 {
.try configure -relief raised -bd 2
.try configure -relief sunken -bd 1
.try configure -orient horizontal
.try configure -state disabled
.try configure -default test

time {package require ClassyTcl}
Classy::Builder .builder
#.builder configure -dir ../dialogs
}