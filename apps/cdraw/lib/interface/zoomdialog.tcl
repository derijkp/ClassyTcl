Classy::Dialog subclass zoomdialog
zoomdialog method init args {
	super init
	# Create windows
	Classy::NumEntry $object.options.numentry1 \
		-command {zoom $current(w)} \
		-label Zoom \
		-textvariable current(zoom) \
		-width 4
	grid $object.options.numentry1 -row 0 -column 0 -columnspan 3 -sticky nesw
	radiobutton $object.options.radiobutton1 \
		-command {zoom $current(w) 100} \
		-text {100 %} \
		-value 100 \
		-variable current(zoom)
	grid $object.options.radiobutton1 -row 1 -column 0 -sticky nesw
	radiobutton $object.options.radiobutton2 \
		-command {zoom $current(w) 200} \
		-text {200 %} \
		-value 200 \
		-variable current(zoom)
	grid $object.options.radiobutton2 -row 2 -column 0 -sticky nesw
	radiobutton $object.options.radiobutton3 \
		-command {zoom $current(w) 400} \
		-text {400 %} \
		-value 400 \
		-variable current(zoom)
	grid $object.options.radiobutton3 -row 3 -column 0 -sticky nesw
	radiobutton $object.options.radiobutton5 \
		-command {zoom $current(w) 75} \
		-text {75 %} \
		-value 75 \
		-variable current(zoom)
	grid $object.options.radiobutton5 -row 1 -column 1 -sticky nesw
	radiobutton $object.options.radiobutton6 \
		-command {zoom $current(w) 50} \
		-text {50 %} \
		-value 50 \
		-variable current(zoom)
	grid $object.options.radiobutton6 -row 2 -column 1 -sticky nesw
	radiobutton $object.options.radiobutton7 \
		-command {zoom $current(w) 25} \
		-text {25 %} \
		-value 25 \
		-variable current(zoom)
	grid $object.options.radiobutton7 -row 3 -column 1 -sticky nesw
	grid columnconfigure $object.options 2 -weight 1

	# End windows
	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object persistent set 
	return $object

	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}}
