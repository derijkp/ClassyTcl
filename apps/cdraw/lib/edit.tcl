proc delete {w} {
	global current
	if ![info exists current(cpos)] {
		$w delete _sel
	} else {
		set coords [$w coords $current(cur)]
		set pos [expr {2*$current(cpos)}]
		$w coords $current(cur) [lreplace $coords $pos [expr {$pos+1}]]
		Classy::todo $w selection redraw
	}
	catch {unset current(cpos)}
}

proc addpoint {w {x {}} {y {}}} {
	global current
	if ![info exists current(cur)] return
	if ![info exists current(cpos)] {
		set current(cpos) 0
	}
	set coords [$w coords $current(cur)]
	set pos [expr {2*$current(cpos)}]
	if {"$x" == ""} {
		set x [expr {[lindex $coords $pos]+10}]
	} else {
		set x [$w canvasx $x]
	}
	if {"$y" == ""} {
		set y [expr {[lindex $coords [expr {$pos+1}]]+10}]
	} else {
		set y [$w canvasy $y]
	}
	set coords [lreplace $coords $pos -1 $x $y]
	eval $w coords $current(cur) $coords
	$w selection redraw
	set item [$w find withtag _ind_$current(cpos)]
	set current(citem) $item
	$w itemconfigure _ind -foreground red
	$w itemconfigure $item -foreground blue
}
