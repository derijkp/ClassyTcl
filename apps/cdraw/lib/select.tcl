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
