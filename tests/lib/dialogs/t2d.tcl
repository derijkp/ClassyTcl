Classy::Dialog subclass t2d

t2d method init {args} {
	super init
	set window $object
	if {"$args" == "___Classy::Builder__create"} {return $window}
	# Configure initial {[.builder cmdw]}
	if {"$args" != ""} {eval $window configure $args}
	return $window
}
