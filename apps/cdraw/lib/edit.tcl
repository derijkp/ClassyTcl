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

proc update_x {w x} {
	global current
	set w $current(w)
	set zoom [$w zoom]
	if [info exists current(cpos)] {
		set x [expr {$x*$zoom}]
		set y [expr {$current(py)*$zoom}]
		$w coord $current(cur) $current(cpos) $x $y
		$w noundo coords _ind_$current(cpos) $x $y
		set current(x) $x
	} else {
		set x [expr {$x*$zoom}]
		set xmove [expr {$x-$current(x)}]
		$w move _sel $xmove 0
		set current(x) $x
	}
}

proc update_y {w y} {
	global current
	set w $current(w)
	set zoom [$w zoom]
	if [info exists current(cpos)] {
		set x [expr {$current(px)*$zoom}]
		set y [expr {$y*$zoom}]
		$w coord $current(cur) $current(cpos) $x $y
		$w noundo coords _ind_$current(cpos) $x $y
		set current(y) $y
	} else {
		set y [expr {$y*$zoom}]
		set ymove [expr {$y-$current(y)}]
		$w move _sel 0 $ymove
		set current(y) $y
	}
}

