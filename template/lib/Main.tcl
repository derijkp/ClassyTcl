proc main args {
mainw .mainw
focus .mainw
}

Classy::Toplevel subclass mainw
mainw classmethod init args {
	super init
	set window $object
	# Create windows
	Classy::DynaTool $window.maintool  \
		-width 179 \
		-type MainTool \
		-height 21
	grid $window.maintool -row 0 -column 0 -sticky new
	grid columnconfigure $window 0 -weight 1
	grid rowconfigure $window 1 -weight 1
	if {"$args" == "___Classy::Builder__create"} {return $window}
	# Parse this
	$window configure \
		-destroycommand "exit" \
		-title [tk appname]
	$window.maintool configure \
		-cmdw [varsubst window {$window}]
	Classy::DynaMenu attachmainmenu MainMenu $window
	# Configure initial arguments
	if {"$args" != ""} {eval $window configure $args}
	return $window
}

