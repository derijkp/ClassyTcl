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
	Classy::DynaTool $window.maintool  \
		-width 179 \
		-type MainTool \
		-height 21
	grid $window.maintool -row 0 -column 0 -sticky new
	grid columnconfigure $window 0 -weight 1
	grid rowconfigure $window 1 -weight 1

	# Parse this
	$window configure \
		-destroycommand "exit" \
		-title [tk appname]
	$window.maintool configure \
		-cmdw [varsubst window {$window}]
	Classy::DynaMenu attachmainmenu MainMenu $window
	return $window
}
