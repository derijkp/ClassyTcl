Classy::Toplevel subclass t2
t2 method init args {
	super init
	# Create windows
	Classy::Text $object.text1  \
		-height 5 \
		-width 10
	grid $object.text1 -row 0 -column 0 -sticky nesw
	Classy::Paned $object.paned1 \
		-snaptoborder 1
	grid $object.paned1 -row 0 -column 1 -sticky nesw
	Classy::Text $object.text2  \
		-height 5 \
		-width 10
	grid $object.text2 -row 0 -column 2 -sticky nesw
	button $object.button1 \
		-text button
	grid $object.button1 -row 1 -column 0 -columnspan 3 -sticky nesw
	Classy::Entry $object.entry1 \
		-label Entry \
		-width 4
	grid $object.entry1 -row 2 -column 0 -columnspan 3 -sticky nesw
	grid columnconfigure $object 2 -weight 1
	grid rowconfigure $object 0 -weight 1

	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object.paned1 configure \
		-window [varsubst object {$object.text1}]
	bind $object.entry1 <FocusIn> {focus .wbuilder.work.entry1.entry}
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

t2 method test {a b} {putsvars a b}