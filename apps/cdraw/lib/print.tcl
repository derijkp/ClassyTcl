#Functions

proc printdialog args {# ClassyTcl generated Dialog
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .printdialog
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Dialog $window \
		-destroycommand [list destroy $window]
	# End windows
}
