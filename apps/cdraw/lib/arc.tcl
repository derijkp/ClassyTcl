#Functions

proc arc_start w {
	global current status
	catch {unset current}
	$w selection set {}
	bindtags $w [list Arc $w Classy::Menu_MainMenu Classy::Canvas Canvas .mainw all]
	set status($w,type) arc
}

proc arc_action {w x y} {
	global current
	set current(x) [$w canvasx $x]
	set current(y) [$w canvasy $y]
	set current(cur) [$w create arc $x $y $x $y]
}

proc arc_motion {w x y} {
	global current
	$w coord $current(cur) 1 $x $y	
}

proc arc_abort {w x y} {
	global current
	$w delete $current(cur)
	catch {unset current(cur)}
}

