#Functions

proc rectangle_start w {
	global current status
	catch {unset current}
	$w selection set {}
	bindtags $w [list Rectangle $w Classy::Menu_MainMenu Classy::Canvas Canvas .mainw all]
	set status($w,type) rectangle
}

proc rectangle_action {w x y} {
	global current
	set x [$w canvasx $x]
	set y [$w canvasy $y]
	set current(x) $x
	set current(y) $y
	set current(cur) [$w create rectangle $x $y $x $y]
}

proc rectangle_motion {w x y} {
	global current
	set x [$w canvasx $x]
	set y [$w canvasy $y]
	$w coord $current(cur) 1 $x $y	
}

proc rectangle_abort {w x y} {
	global current
	$w delete $current(cur)
	catch {unset current(cur)}
}


