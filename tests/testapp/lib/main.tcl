proc main {args} {
	mainw
}


proc mainw args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .mainw
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Toplevel $window 
	Classy::DynaTool $window.dynatool1  \
		-type MainTool \
		-height 21 \
		-width 179
	grid $window.dynatool1 -row 0 -column 0 -sticky new
	grid columnconfigure $window 0 -weight 1
	grid rowconfigure $window 0 -weight 1

	# Parse this
	$window configure \
		-destroycommand "exit"
	$window.dynatool1 configure \
		-cmdw [varsubst window {$window}]
	Classy::DynaMenu attachmainmenu MainMenu $window
	return $window
}






