#Functions


proc line_action {w x y} {
global current
set x [$w canvasx $x]
set y [$w canvasy $y]
if [info exists current(cur)] {
	set cur $current(cur)
	set coords [$w coords $cur]
	lappend coords $x $y
	eval $w coords $cur $coords
} else {
	set current(cur) [$w create line $x $y]
}
$w undo check

}


proc line_adjust {w x y} {
global current
set x [$w canvasx $x]
set y [$w canvasy $y]
if [info exists current(cur)] {
	set cur $current(cur)
	set coords [$w coords $cur]
	lappend coords $x $y
	eval $w coords $cur $coords
	unset current(cur)
}
$w undo check

}

proc line_abort {w x y} {
global current
catch {unset current(cur)}
}





proc line_start w {
global current status
catch {unset current}
$w selection set {}
bindtags $w [list Line $w Classy::Menu_MainMenu Classy::Canvas Canvas .mainw all]
set status(type) line

}






























