#Functions

proc testing {} {

}

#Functions

proc test3 {} {
	puts 3
}




proc test2 {} {
	puts 2
}

proc t2 args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lpop args]
	} else {
		set window .t2
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Toplevel $window  \
		-keepgeometry 0
	Classy::Text $window.text1  \
		-height 5 \
		-width 10
	grid $window.text1 -row 0 -column 0 -sticky nesw
	$window.text1 insert end "

"
	Classy::Text $window.text2  \
		-height 5 \
		-width 10
	grid $window.text2 -row 0 -column 1 -sticky nesw
	$window.text2 insert end "

"
	Classy::DynaMenu attachmainmenu Classy::Test $window.text1
	Classy::DynaMenu attachmainmenu Classy::Test $window.text2
	grid columnconfigure $window 0 -weight 1
	grid columnconfigure $window 1 -weight 1
	grid rowconfigure $window 0 -weight 1

}

proc testframe args {# ClassyTcl generated Frame
	if [regexp {^\.} $args] {
		set window [lpop args]
	} else {
		set window .t2
	}
	Classy::parseopt $args opt {}
	# Create windows
	frame $window \
		-class Classy::Topframe  \
		-borderwidth 2 \
		-relief groove
	button $window.b1 \
		-command {puts ok} \
		-text button
	grid $window.b1 -row 0 -column 0 -sticky nesw
	checkbutton $window.checkbutton1 \
		-text button \
		-variable checkbutton1
	grid $window.checkbutton1 -row 1 -column 0 -sticky nesw
	button $window.button1 \
		-command {puts test} \
		-text test
	grid $window.button1 -row 2 -column 0 -sticky nesw
	grid columnconfigure $window 0 -weight 1

}





proc trfr args {# ClassyTcl generated Frame
	if [regexp {^\.} $args] {
		set window [lpop args]
	} else {
		set window .trfr
	}
	Classy::parseopt $args opt {}
	# Create windows
	frame $window \
		-class Classy::Topframe 
	button $window.button1 \
		-text button
	grid $window.button1 -row 0 -column 0 -sticky nesw

}





