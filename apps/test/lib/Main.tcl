


























proc main {} {
	mainw
}














proc t args {# ClassyTcl generated Frame
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .t
	}
	Classy::parseopt $args opt {}
	# Create windows
	frame $window \
		-class Classy::Topframe
	# End windows
}

proc mainw args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .mainw
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Toplevel $window \
		-destroycommand [list destroy $window]
	# End windows
}
