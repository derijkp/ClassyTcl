Classy::Toplevel subclass Classy_configedit
Classy_configedit method init args {
	super init
	# Create windows
	Classy::Entry $object.entry1 \
		-labelwidth 10 \
		-label Node \
		-textvariable Classy::config(cnode) \
		-width 20
	grid $object.entry1 -row 0 -column 0 -columnspan 3 -sticky nesw
	Classy::Entry $object.entry2 \
		-labelwidth 10 \
		-label Key \
		-textvariable Classy::config(ckey) \
		-width 4
	grid $object.entry2 -row 2 -column 0 -columnspan 3 -sticky nesw
	Classy::Entry $object.entry3 \
		-labelwidth 10 \
		-label Description \
		-textvariable Classy::config(cdescr) \
		-width 4
	grid $object.entry3 -row 1 -column 0 -columnspan 3 -sticky nesw
	button $object.button1 \
		-text Add
	grid $object.button1 -row 4 -column 0
	button $object.button2 \
		-text Delete
	grid $object.button2 -row 4 -column 1
	Classy::Selector $object.selector1 \
		-label Type \
		-orient vertical \
		-type {select line text bool int color font key mouse relief orient justify select} \
		-variable Classy::config(ctype)
	grid $object.selector1 -row 3 -column 0 -columnspan 3 -sticky nesw
	button $object.button3 \
		-text Close
	grid $object.button3 -row 4 -column 2
	grid columnconfigure $object 0 -weight 1
	grid columnconfigure $object 1 -weight 1
	grid columnconfigure $object 2 -weight 1

	# End windows
	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object.button3 configure \
		-command [varsubst object {destroy $object}]
	return $object

	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
}

Classy_configedit addoption -configwindow {configwindow Configwindow .classy__.config} {
	$object.entry1 configure \
		-command [list Classy::config_movenode $value]
	$object.entry2 configure \
		-command [list Classy::config_changenode $value key]
	$object.entry3 configure \
		-command [list Classy::config_changenode $value descr]
	$object.button1 configure \
		-command [list Classy::config_addnode $value]
	$object.button2 configure \
		-command [list Classy::config_deletenode $value]
	$object.selector1 configure \
		-command [list Classy::config_changenode $value type]
}
