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
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Dialog $window 
	label $window.options.o1 -text label
	grid $window.options.o1 -row 0 -column 0 -sticky nesw
	button $window.options.o2 -text button
	grid $window.options.o2 -row 1 -column 0 -sticky nesw
	entry $window.options.o3 -textvariable ::Classy::value(.try.dedit.work.options.o3) -validate none
	grid $window.options.o3 -row 2 -column 0 -sticky nesw
	frame $window.options.o4  -borderwidth 2 -relief groove
	grid $window.options.o4 -row 3 -column 0 -sticky nesw
	button $window.options.o4.o1 -text button
	grid $window.options.o4.o1 -row 0 -column 0 -sticky nesw
	label $window.options.o4.o2 -text label
	grid $window.options.o4.o2 -row 1 -column 0 -sticky nesw

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

proc draw args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lpop args]
	} else {
		set window .draw
	}
	Classy::parseopt $args opt {}
	# Create windows
	toplevel $window 
	wm title $window work
	button $window.o2 -command {$window.c delete all} -text clear
	grid $window.o2 -row 1 -column 0 -sticky w
	canvas $window.c -height 207 -width 295
	grid $window.c -row 0 -column 0 -sticky nesw
	bind $window.c <<Action-Motion>> {#binding
%W create oval [expr %x-3] [expr %y-3] [expr %x+3] [expr %y+3]}
	bind $window.c <<Action>> {#binding
%W create oval [expr %x-3] [expr %y-3] [expr %x+3] [expr %y+3]}

}



