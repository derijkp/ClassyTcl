Class subclass Test
Test method init {args} {
	private $class def
	private $object data
	if {[llength $args] == 0} {
		if [info exists def] {
			set data $def
		} else {
			set data 0
		}
	} else {
		set data [lindex $args 0]
	}	
}

Test method add {a} {
	private $object data
	incr data $a
}
