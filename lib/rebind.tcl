proc Classy::destroyrebind {w} {
	foreach name [array names ::Classy::rebind $w.*] {
		unset ::Classy::rebindw($::Classy::rebind($name))
		unset ::Classy::rebind($name)
	}
	foreach name [array names ::Classy::rebindw $w.*] {
		unset ::Classy::rebind($::Classy::rebindw($name))
		unset ::Classy::rebindw($name)
	}
	if [info exists ::Classy::rebind($w)] {
		unset ::Classy::rebindw($::Classy::rebind($w))
		unset ::Classy::rebind($w)
	}
	if [info exists ::Classy::rebindw($w)] {
		unset ::Classy::rebind($::Classy::rebindw($w))
		unset ::Classy::rebindw($w)
	}
}

proc Classy::rebind {w args} {
	if [llength $args] {
		set bindw [lindex $args 0]
		if [string length $bindw] {
			set ::Classy::rebind($w) $bindw
			set ::Classy::rebindw($bindw) $w
			set bindtags [list_remove [bindtags $bindw] $bindw . all]
			bindtags $w [list_remdup [concat $bindw $bindtags [bindtags $w]]]
			bindtags $bindw [list rebind::$bindw $bindw . all]
			bind rebind::$bindw <FocusIn> [list focus $w]
		} else {
			unset ::Classy::rebind($w)
		}
	} else {
		get ::Classy::rebind($w) $w
	}
}

proc Classy::rebindw {w} {
	get ::Classy::rebindw($w) $w
}

if {"[info commands ::Tk::bind]" == ""} {
	rename bind ::Tk::bind
}
proc bind {args} {
	switch [llength $args] {
		1 {
			return [::Tk::bind [lindex $args 0]]
		}
		2 {
			set result [::Tk::bind [lindex $args 0] [lindex $args 1]]
			return [string_change $result {{[::Classy::rebind %W]} %W %W %O}]
		}
		3 {
			set cmd [string_change [lindex $args 2] {%W {[::Classy::rebind %W]} %O %W}]
			return [::Tk::bind [lindex $args 0] [lindex $args 1] $cmd]
		}
		default {
			return -code error "wrong # args: should be \"Classy::bind window ?pattern? ?command?\""
		}
	}
}
