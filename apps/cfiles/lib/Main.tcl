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
		-height 41
	grid $window.maintool -row 0 -column 0 -sticky new
	Classy::Browser $window.browser  \
		-gettext gettext \
		-getdata getdata \
		-getimage getimage \
		-height 50 \
		-width 50
	grid $window.browser -row 1 -column 0 -sticky nesw
	grid columnconfigure $window 0 -weight 1
	grid rowconfigure $window 1 -weight 1

	# End windows
	# Parse this
	$window configure \
		-destroycommand "exit" \
		-title [tk appname]
	bind $window <<Action>> {filer_action %W %x %y}
	$window.maintool configure \
		-cmdw [varsubst window {$window.browser}]
	$window.browser configure \
		-list [concat .. [glob [pwd]/*]]
	Classy::DynaMenu attachmainmenu MainMenu $window.browser
	return $window
}









