#Functions


proc d args {# ClassyTcl generated Dialog
	if [regexp {^\.} $args] {
		set window [lpop args]
	} else {
		set window .d
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Dialog $window
	radiobutton $window.options.o1 
	grid $window.options.o1 -row 0 -column 0 -sticky nesw
	label $window.options.o2 -image {} -text label
	grid $window.options.o2 -row 1 -column 0 -sticky nesw
	entry $window.options.o3 -textvariable ::Dialog::value($window.options.o3) -validate none
	grid $window.options.o3 -row 2 -column 0 -sticky nesw

}

proc top args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lpop args]
	} else {
		set window .top
	}
	Classy::parseopt $args opt {}
	# Create windows
	toplevel $window 
	text $window.o1 -height 10 -width 20
	grid $window.o1 -row 0 -column 0 -sticky nesw
	scrollbar $window.o2 
	grid $window.o2 -row 0 -column 1 -sticky nesw
	scrollbar $window.o3 -orient horizontal
	grid $window.o3 -row 2 -column 0 -sticky nesw
	grid columnconfigure $window 0 -weight 1
	grid rowconfigure $window 0 -weight 1
	grid rowconfigure $window 1 -weight 1 -weight 1
	grid rowconfigure $window 2 -weight 1 -weight 1 -weight 1

}

proc test2 {} {
}

proc test3 {} {
}


proc ttt args {# ClassyTcl generated Dialog
	if [regexp {^\.} $args] {
		set window [lpop args]
	} else {
		set window .ttt
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Dialog $window
	#Initialisation code
}
