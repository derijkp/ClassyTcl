#
# Entry
#
proc ::Classy::WindowBuilder::edit_Classy::Entry {object base} {
	::Classy::WindowBuilder::defattredit $object $base {
		-label Label 0 -labelwidth Labelwidth 0 -textvariable Textvariable 0 -command Command 1
	} 10 0
}

proc ::Classy::WindowBuilder::add_Classy::Entry {object base args} {
	Classy::Entry $base -width 4 -label label
	eval $base configure $args
	return $base
}

proc ::Classy::WindowBuilder::edit_Classy::NumEntry {object base} {
	::Classy::WindowBuilder::defattredit $object $base {
		-label Label 0 -labelwidth Labelwidth 0 -textvariable Textvariable 0 -command Command 1
	} 10 0
}

proc ::Classy::WindowBuilder::add_Classy::NumEntry {object base args} {
	Classy::NumEntry $base -width 4 -label label
	eval $base configure $args
	return $base
}

#
# Progress
#

proc ::Classy::WindowBuilder::add_Classy::Progress {object base args} {
	Classy::Progress $base -width 50
	eval $base configure $args
	return $base
}

