proc main {args} {
	mainw
}

proc mainw args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lpop args]
	} else {
		set window .mainw
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Toplevel $window \
		-destroycommand "exit"
	Classy::DynaMenu makemenu MainMenu $window.mainmenu $window MainMenu_bnd
	$window configure -menu $window.mainmenu
	Classy::DynaTool maketool MainTool $window.maintool $window
	grid $window.maintool -row 0 -column 0 -sticky nwe
	grid columnconfigure $window 0 -weight 1
}
