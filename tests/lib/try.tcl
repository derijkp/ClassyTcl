#Functions

proc testing {} {

}

#Functions

proc test3 {} {
	puts 3
}




proc test2 {} {
	puts 2
}

proc t2 args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lpop args]
	} else {
		set window .t2
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Toplevel $window 
}

