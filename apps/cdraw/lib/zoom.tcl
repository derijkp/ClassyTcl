#Functions

proc zoom {w zoom} {
	global status
	set x [$w canvasx 0]
	set y [$w canvasy 0]
	set page [$w coords _page]
	set pw [lindex $page 2]
	set ph [lindex $page 3]
	$w zoom [expr {$zoom/100.0}]
	set status($w,zoom) $zoom
	$w xview moveto [expr {$x/$pw}]
	$w yview moveto [expr {$y/$ph}]
}

proc zoom_action {w x y args} {
	global current
	set x [$w canvasx $x]
	set y [$w canvasy $y]
	set current(x) $x
	set current(y) $y
	$w selector $x $y $x $y
	set current(action) sel
}

proc zoom_drag {w x y} {
	global current
	set x [$w canvasx $x]
	set y [$w canvasy $y]
	$w selector $current(x) $current(y) $x $y
}

proc zoom_release {w x y args} {
	global current
	set x [$w canvasx $x]
	set y [$w canvasy $y]
	if {($x == $current(x))||($y == $current(y))} {
		$w undo check start
		set f 2.0
		zoom $w [expr {100.0*[$w zoom]/$f}]
		set page [$w coords _page]
		set pw [lindex $page 2]
		set ph [lindex $page 3]
		$w yview moveto [expr {($y/$f-[winfo height $w]/2)/$ph}]
		$w xview moveto [expr {($x/$f-[winfo width $w]/2)/$pw}]
		$w undo check stop
		
	} else {
		set page [$w coords _page]
		if {$x < $current(x)} {set temp $x; set x $current(x); set current(x) $temp}
		if {$y < $current(y)} {set temp $y; set y $current(y); set current(y) $temp}
		set pw [lindex $page 2]
		set ph [lindex $page 3]
		set width [expr {$x-$current(x)}]
		set height [expr {$y-$current(y)}]
		if {$x < $current(x)} {
			set temp $x
			set x $current(x)
			set current(x) $temp
		}
		if {$y < $current(y)} {
			set temp $y
			set y $current(y)
			set current(y) $temp
		}
		set zf [expr {[winfo width $w]/$width}]
		set zfy [expr {[winfo height $w]/$height}]
		if {$zfy < $zf} {set zf $zfy}
		$w undo check start
		zoom $w [expr {100.0*[$w zoom]*$zf}]
		$w yview moveto [expr {$current(y)/$ph}]
		$w xview moveto [expr {$current(x)/$pw}]
		$w undo check stop
	}
	$w selector -100 -100 -100 -100
	unset current(action)
}

proc zoom_adjust {w x y} {
}

proc zoom_abort {w x y} {
global current
catch {unset current(action)}
}

proc zoom_start w {
global current status
catch {unset current}
set current(w) $w
$w selection set {}
bindtags $w [list Zoom $w Classy::Menu_MainMenu Classy::Canvas Canvas .mainw all]
set status($w,type) zoom
catch {destroy .zoomdialog}
zoomdialog
}




