Classy::Toplevel subclass Classy_menueditor
Classy_menueditor method init args {
	super init
	# Create windows
	Classy::TreeWidget $object.treewidget1 \
		-width 50 \
		-height 50
	grid $object.treewidget1 -row 1 -column 0 -sticky nesw
	Classy::Paned $object.paned1
	grid $object.paned1 -row 1 -column 1 -sticky nesw
	frame $object.buttons  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $object.buttons -row 0 -column 0 -columnspan 3 -sticky nesw
	frame $object.frame  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $object.frame -row 1 -column 2 -sticky nesw
	grid columnconfigure $object 2 -weight 1
	grid rowconfigure $object 1 -weight 1

	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object configure  \
		-title {Menu Editor}
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

Classy_menueditor addoption -variable {variable Variable menu} {$object redraw}

Classy_menueditor method redraw {} {}