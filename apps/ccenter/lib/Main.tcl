proc main args {
	set ::clock(format) [Classy::Default get app clock_format "%b %d %H:%M:%S"]
	mainw
	clock_update
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
	frame $window.tools  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $window.tools -row 0 -column 2 -sticky nesw
	button $window.tools.clock \
		-relief flat \
		-text {Jul 02 15:29:06} \
		-textvariable clock(value)
	grid $window.tools.clock -row 0 -column 2 -sticky nesw
	Classy::CmdWidget $window.tools.cmd \
		-prompt {% } \
		-height 5 \
		-width 10
	grid $window.tools.cmd -row 1 -column 0 -columnspan 3 -sticky nesw
	Classy::OptionMenu $window.tools.connect  \
		-text ccenter
	grid $window.tools.connect -row 0 -column 0 -sticky nesw
	$window.tools.connect set ccenter
	button $window.tools.button1 \
		-text L
	grid $window.tools.button1 -row 0 -column 1 -sticky nsw
	grid columnconfigure $window.tools 1 -weight 1
	grid rowconfigure $window.tools 1 -weight 1
	Classy::ScrolledFrame $window.progs  \
		-bd 0 \
		-borderwidth 0 \
		-height 1 \
		-width 1
	grid $window.progs -row 0 -column 0 -sticky nesw
		Classy::Paned $window.paned1
	grid $window.paned1 -row 0 -column 1 -sticky nesw
	grid columnconfigure $window 0 -weight 1
	grid rowconfigure $window 0 -weight 1

	# End windows
	# Parse this
	$window configure \
		-destroycommand "exit" \
		-title [tk appname]
	$window.tools.connect configure \
		-command [varsubst window {$window.tools.cmd connect [$window.tools.connect get]}] \
		-list [winfo interps]
	$window.tools.button1 configure \
		-command [varsubst window {set w [Classy::cmd]
$w.edit configure -prompt {[tk appname] % }
$w.edit connect [$window.tools.connect get]}]
	$window.paned1 configure \
		-window [varsubst window {$window.tools}]
# ClassyTcl Finalise
$window.tools.cmd clearall
	return $window
}











