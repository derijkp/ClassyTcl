#Functions

proc test2 {} {
	puts test2
}

proc test3 {} {
	puts test3
}


proc ttt args {# ClassyTcl generated Dialog
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .ttt
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Dialog $window  \
		-title Toplevel
	button $window.options.button1 \
		-text {button 1}
	grid $window.options.button1 -row 0 -column 1 -sticky nesw
	button $window.options.button2 \
		-text {button 3}
	grid $window.options.button2 -row 1 -column 1 -sticky nesw
	button $window.options.button3 \
		-text {button 2}
	grid $window.options.button3 -row 0 -column 2 -sticky nesw
	button $window.options.button4 \
		-text {button 4}
	grid $window.options.button4 -row 2 -column 1 -sticky nesw
	Classy::Entry $window.options.entry1 \
		-label label \
		-width 4
	grid $window.options.entry1 -row 3 -column 1 -columnspan 2 -sticky nesw
	button $window.options.button5 \
		-text button
	grid $window.options.button5 -row 0 -column 0 -sticky nesw
	button $window.options.button6 \
		-text button
	grid $window.options.button6 -row 1 -column 0 -sticky nesw
	button $window.options.button7 \
		-text button
	grid $window.options.button7 -row 2 -column 0 -sticky nesw
	button $window.options.button8 \
		-text button
	grid $window.options.button8 -row 3 -column 0 -sticky nesw
	# End windows

	return $window
}









proc top args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .top
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Toplevel $window 
	button $window.button1 \
		-text try
	grid $window.button1 -row 1 -column 0 -sticky nesw
	Classy::Entry $window.entry1 \
		-label label \
		-width 4
	grid $window.entry1 -row 0 -column 0 -sticky nesw

	# End windows
# ClassyTcl Initialise
puts ok
	# Parse this
	$window configure \
		-destroycommand 
	$window.button1 configure \
		-command [varsubst window {$window.entry1 set try}]
	Classy::DynaMenu attachmainmenu Try $window
# ClassyTcl Finalise
puts ok
	return $window
	return $window
	return $window
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
	#Initialisation code
}














