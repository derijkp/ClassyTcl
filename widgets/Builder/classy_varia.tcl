#
# Entry
#
proc ::Classy::WindowBuilder::edit_Classy::Entry {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-label Label 0 -labelwidth Labelwidth 0 -textvariable Textvariable 0 -command Command 1
	} 10 0
}

proc ::Classy::WindowBuilder::add_Classy::Entry {object w args} {
	Classy::Entry $w -width 4 -label label
	eval $w configure $args
}

proc ::Classy::WindowBuilder::edit_Classy::NumEntry {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-label Label 0 -labelwidth Labelwidth 0 -textvariable Textvariable 0 -command Command 1
	} 10 0
}

proc ::Classy::WindowBuilder::add_Classy::NumEntry {object w args} {
	Classy::NumEntry $w -width 4 -label label
	eval $w configure $args
}

#
# Text
#

proc ::Classy::WindowBuilder::add_Classy::Text {object w args} {
	Classy::Text $w -width 10 -height 5
	eval $w configure $args
}

#
# Progress
#

proc ::Classy::WindowBuilder::add_Classy::Progress {object w args} {
	Classy::Progress $w -width 50
	eval $w configure $args
}

