#Functions

proc filesave w {
global status
if ![info exists status($w,file)] {
	saveas $w
} else {
	file_write $status($w,file) [$w save]
}
}

proc fileload w {
global status
if {(![info exists status($w,file)])||("$status($w,file)" == "")} {
	set init new.cld
} else {
	set init $status($w,file)
}
set temp [Classy::selectfile -title Open -selectmode persistent \
	-defaultextension .cld \
	-initialfile $init]
if {"$temp" == ""} return
set status($w,file) [lindex $temp 0]
$w load [file_read $status($w,file)]
}

proc saveas w {
global status
if {(![info exists status($w,file)])||("$status($w,file)" == "")} {
	set init new.cld
} else {
	set init $status($w,file)
}
set temp [Classy::savefile -title "Save as" \
	-defaultextension .cld\
	-initialfile $init]
if {"$temp" == ""} return
set status($w,file) $temp
file_write $status($w,file) [$w save]
}

