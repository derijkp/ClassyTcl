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
	button $window.button1 \
		-text try
	grid $window.button1 -row 1 -column 0 -sticky nesw
	Classy::ScrolledText $window.scrolledtext1  \
		-height 5 \
		-width 10
	grid $window.scrolledtext1 -row 2 -column 0 -sticky nesw
	grid columnconfigure $window 0 -weight 1
	grid rowconfigure $window 2 -weight 1

	# End windows
	# Parse this
	$window configure \
		-destroycommand "exit" \
		-title [tk appname]
	$window.maintool configure \
		-cmdw [varsubst window {$window}]
	$window.button1 configure \
		-command [varsubst window {$window.scrolledtext1 insert insert try}]
	Classy::DynaMenu attachmainmenu MainMenu $window
	return $window
}


