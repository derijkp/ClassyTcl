Classy::Dialog subclass settingsdialog
settingsdialog method init args {
	super init
	# Create windows
	Classy::NumEntry $object.options.numentry1 \
		-label {General base distance} \
		-textvariable tempinfo(dist) \
		-width 4
	grid $object.options.numentry1 -row 0 -column 0 -sticky nesw
	Classy::NumEntry $object.options.numentry2 \
		-label {Helix base distance} \
		-textvariable tempinfo(xs) \
		-width 4
	grid $object.options.numentry2 -row 1 -column 0 -sticky nesw
	Classy::NumEntry $object.options.numentry3 \
		-label {base pair distance} \
		-textvariable tempinfo(ys) \
		-width 4
	grid $object.options.numentry3 -row 2 -column 0 -sticky nesw
	Classy::NumEntry $object.options.numentry4 \
		-label {Base pair width} \
		-textvariable tempinfo(dotwidth) \
		-width 4
	grid $object.options.numentry4 -row 3 -column 0 -sticky nesw
	Classy::NumEntry $object.options.numentry5 \
		-label {Base pair length} \
		-textvariable tempinfo(dotlen) \
		-width 4
	grid $object.options.numentry5 -row 4 -column 0 -sticky nesw
	Classy::NumEntry $object.options.numentry7 \
		-label {ns base pair width} \
		-textvariable tempinfo(nsdotwidth) \
		-width 4
	grid $object.options.numentry7 -row 6 -column 0 -sticky nesw
	checkbutton $object.options.checkbutton1 \
		-text {Show non standard base pairs} \
		-variable tempinfo(nsshow)
	grid $object.options.checkbutton1 -row 7 -column 0 -sticky nesw
	Classy::NumEntry $object.options.numentry8 \
		-label {ns base pair length} \
		-textvariable tempinfo(nsdotlen) \
		-width 4
	grid $object.options.numentry8 -row 8 -column 0 -sticky nesw
	Classy::NumEntry $object.options.numentry9 \
		-label {Auto connect width} \
		-textvariable tempinfo(connectsize) \
		-width 4
	grid $object.options.numentry9 -row 9 -column 0 -sticky nesw
	Classy::NumEntry $object.options.numentry10 \
		-label Treshhold \
		-textvariable tempinfo(connectdist) \
		-width 4
	grid $object.options.numentry10 -row 10 -column 0 -sticky nesw
	frame $object.options.frame1  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $object.options.frame1 -row 0 -column 1 -sticky nesw
	Classy::NumEntry $object.options.frame1.numentry1 \
		-label {ns bulge} \
		-textvariable tempinfo(nsbulge) \
		-width 4
	grid $object.options.frame1.numentry1 -row 0 -column 0 -sticky nesw
	grid columnconfigure $object.options 1 -weight 1

	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object configure  \
		-help settings \
		-title Toplevel
	$object add b1 Set [varsubst object {_settings_set $object}] default
	$object add b2 {Set as default} [varsubst object {_settings_setasdefault $object}]
	$object add b3 Defaults [varsubst object {_settings_defaults $object}]
	$object add b4 {Program defaults} [varsubst object {_settings_programdefaults $object}]
	$object persistent set b1 b2 b3 b4
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
	return $object
}