#Functions

proc polygon_action {w x y} {
global current
set x [$w canvasx $x]
set y [$w canvasy $y]
if [info exists current(cur)] {
	set cur $current(cur)
	set coords [$w coords $cur]
	lappend coords $x $y
	if {[llength $coords] == 6} {
		if {([lindex $coords 0]==[lindex $coords 2])&&([lindex $coords 1]==[lindex $coords 3])} {
			set coords [lrange $coords 2 end]
		}
	}
	eval $w coords $cur $coords
} else {
	set current(cur) [$w create polygon $x $y $x $y $x $y]
}
}

proc polygon_motion {w x y} {
global current
if ![info exists current(cur)] return
set x [$w canvasx $x]
set y [$w canvasy $y]
set cur $current(cur)
set coords [$w coords $cur]
set pos [expr {[llength $coords]/2-1}]
$w coord $cur $pos $x $y
}

proc polygon_abort {w x y} {
global current
catch {unset current(cur)}
}

proc polygon_start w {
global current status
catch {unset current}
$w selection set {}
bindtags $w [list Polygon $w Classy::Menu_MainMenu Classy::Canvas Canvas .mainw all]
set status($w,type) polygon
}


