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
	Classy::Paned $window.paned1
	grid $window.paned1 -row 1 -column 1 -sticky nesw
	Classy::ListBox $window.widgets  \
		-height 4 \
		-width 10
	grid $window.widgets -row 1 -column 0 -sticky nesw
	frame $window.test  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $window.test -row 1 -column 2 -sticky nesw
	Classy::CmdWidget $window.cmdwidget1 \
		-height 4 \
		-width 20
	grid $window.cmdwidget1 -row 2 -column 0 -columnspan 3 -sticky nesw
	grid columnconfigure $window 2 -weight 1
	grid rowconfigure $window 1 -weight 1

	# End windows
	# Parse this
	$window configure \
		-destroycommand "exit" \
		-title [tk appname]
	$window.paned1 configure \
		-window [varsubst window {$window.widgets}]
	return $window
}





