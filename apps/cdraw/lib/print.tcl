#Functions

Classy::Dialog subclass printdialog
printdialog method init args {
	if {"$args" == "___Classy::Builder__create"} {return $object}
	super init
	# Create windows
	# End windows

	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}}

