Classy::Dialog subclass tdialog

tdialog method init args {
	super init
	# Create windows
	button $object.options.button1 \
		-text button
	grid $object.options.button1 -row 0 -column 0 -sticky nesw
	frame $object.options.frame1  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $object.options.frame1 -row 1 -column 0 -sticky nesw
	grid columnconfigure $object.options 0 -weight 1
	grid rowconfigure $object.options 1 -weight 1

	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object configure  \
		-title Toplevel
	$object add b1 {button 1} {}
	$object add b2 {button 2} {}
	$object persistent set b1 b2
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

