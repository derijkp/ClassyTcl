proc function {a b args} {
	return "$a $b $args"
}

#
# comments
#

proc try args {# ClassyTcl generated Dialog
	if [regexp {^\.} $args] {
		set window [lpop args]
	} else {
		set window .newd
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Dialog $window 
	entry $window.options.o1 -textvariable ::Dialog::value(.try.work.options.o1) -validate none
	grid $window.options.o1 -row 2 -column 0 -sticky nesw
	label $window.options.o3 -text [list label \[ it] ;#f -text {[list label \[ it]}
	grid $window.options.o3 -row 3 -column 0 -sticky nesw

}

# something else



proc test args {# ClassyTcl generated Dialog
	if [regexp {^\.} $args] {
		set window [lpop args]
	} else {
		set window .newd
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Dialog $window 
	entry $window.options.o1 -textvariable ::Dialog::value(.try.work.options.o1) -validate none
	grid $window.options.o1 -row 0 -column 0 -sticky nesw
	label $window.options.o2 -text label
	grid $window.options.o2 -row 1 -column 0 -sticky nesw
	radiobutton $window.options.o3 -highlightbackground black
	grid $window.options.o3 -row 2 -column 0 -sticky nesw
	entry $window.options.o4 -highlightbackground black -textvariable ::Dialog::value(.try.work.options.o4) -validate none
	grid $window.options.o4 -row 3 -column 0 -sticky nesw

	$window add b1 {button 1} {{puts go}}
}


proc plainf {a b args} {
	return "$a $b $args"
}


proc t args {# ClassyTcl generated Dialog
	if [regexp {^\.} $args] {
		set window [lpop args]
	} else {
		set window .newd
	}
	# Create windows
	Classy::Dialog $window

}

proc geom args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lpop args]
	} else {
		set window .geom
	}
	Classy::parseopt $args opt {}
	# Create windows
	toplevel $window
	#Initialisation code
}
