proc rotate_switch {w x y} {
	global status
	set x [$w canvasx $x]
	set y [$w canvasy $y]
	if $status($w,rotate) {
		set status($w,rotate) 0 
	} else {
		set status($w,rotate) 1
	}
	rotate_set $w $x $y
}

proc rotate_set {w {x {}} {y {}}} {
	global status current
	if !$status($w,rotate) {
		$w noundo itemconfigure _sb -bitmap [Classy::getbitmap canvas_select]
		$w noundo delete _rotatepos
	} else {
		if {"$x" == ""} {
			if ![info exists current(cur)] {
				set status($w,rotate) 0
				return
			}
			set pos [$w coords $current(cur)]
			set x [lindex $pos 0]
			set y [lindex $pos 1]
		}
		$w noundo itemconfigure _sb -bitmap [Classy::getbitmap canvas_rotate]
		$w noundo create bitmap $x $y -bitmap [Classy::getbitmap rotatepos] -tags {_rotatepos _sel}
	}
}

