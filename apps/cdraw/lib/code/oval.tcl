#Functions

proc oval_start w {
	global current status
	catch {unset current}
	$w selection set {}
	bindtags $w [list Oval $w Classy::Menu_MainMenu Classy::Canvas Canvas .mainw all]
	set status($w,type) oval
}

proc oval_action {w x y} {
	global current
	set x [$w canvasx $x]
	set y [$w canvasy $y]
	set current(x) $x
	set current(y) $y
	set current(cur) [$w create oval $x $y $x $y]
}

proc oval_motion {w x y} {
	global current
	set x [$w canvasx $x]
	set y [$w canvasy $y]
	$w coord $current(cur) 1 $x $y	
}

proc oval_abort {w x y} {
	global current
	$w delete $current(cur)
	catch {unset current(cur)}
}

