#Functions

proc select_action {w ox oy args} {
global current
set current(w) $w
set x [$w canvasx $ox]
set y [$w canvasy $oy]
set list [$w find overlapping [expr {$x-1}] [expr {$y-1}] [expr {$x+1}] [expr {$y+1}]]
set item [lindex $list end]
set group [$w findgroup $item]
set current(group) $group
set current(x) $x
set current(y) $y
catch {unset current(cpos)}
set zoom [$w zoom]
set current(px) [expr {$x/$zoom}]
set current(py) [expr {$y/$zoom}]
if {[llength $item] != 0} {
set tags [$w itemcget $item -tags]
	if {"[lindex $tags 0]" == "_ind"} {
		set current(action) coords
		set current(citem) $item
		regexp {[0-9]+$} [lindex $tags 1] current(cpos)
		if {"$args" == "add"} {addpoint $w $ox $oy}
		$w noundo itemconfigure _ind -foreground red
		$w noundo itemconfigure $item -foreground blue
		set current(coords) [$w coords $current(cur)]
	} elseif {"[lindex $tags 0]" == "_rotatepos"} {
		set current(action) rotatepos
		set current(citem) $item
	} elseif {"[lindex $tags 0]" == "_sb"} {
		set current(action) scale
		set current(name) [lindex $tags 1]
		set current(citem) $item
		set bbox [$w bbox _sel]
		set current(x1) [lindex $bbox 0]
		set current(y1) [lindex $bbox 1]
		set current(x2) [lindex $bbox 2]
		set current(y2) [lindex $bbox 3]
	} else {
		catch {unset current(cpos)}
		set current(cur) $item
		if {"$args" != "add"} {
			if ![inlist [$w itemcget $item -tags] _sel] {
				if {"$group" != ""} {
					$w selection set $group
				} else {
					$w selection set $item
				}
			}
			$w current $item ind
		} else {
			if ![inlist [$w itemcget $item -tags] _sel] {
				if {"$group" != ""} {
					$w selection add $group
				} else {
					$w selection add $item
				}
				$w current $item ind
			} else {
				if {"$group" != ""} {
					$w selection remove $group
				} else {
					$w selection remove $item
				}
				$w current {}
			}
		}
		set current(action) move
		update_config $w
	}
	$w undo check start
} else {
	if {"$args" != "add"} {
		global status
		$w selection set {}
		$w current {}
		set status($w,rotate) 0
		rotate_set $w
	}
	$w selector $x $y $x $y
	set current(action) sel
}
}

proc sqangle {x1 y1 x2 y2} {
	if {$x1==$x2} {
		if {$y1>$y2} {return 90} else {return -90}
	} elseif {$x1>$x2} {
		set angle [expr atan(($y2-$y1)/($x2-$x1))+3.14159265]
	} else {
		set angle [expr atan(($y2-$y1)/($x2-$x1))]
	}
	if {$angle==0} {
		return 0
	} else {
		set angle [expr -$angle*180/3.14159265]
		while {$angle<0} {set angle [expr $angle+360.0]}
		return $angle
	}
}

proc select_drag {w x y} {
	global current
	catch {after cancel $current(id)}
	set current(id) [after idle select_updatedrag $w]
}

proc select_updatedrag {w} {
	global current
	set x [expr [winfo pointerx $w]-[winfo rootx $w]]
	set y [expr [winfo pointery $w]-[winfo rooty $w]]
	set x [$w canvasx $x]
	set y [$w canvasy $y]
	set zoom [$w zoom]
	set current(px) [expr {$x/$zoom}]
	set current(py) [expr {$y/$zoom}]
	if ![info exists current(action)] return
	if {"$current(action)" == "sel"} {
		$w selector $current(x) $current(y) $x $y
	} elseif {"$current(action)" == "coords"} {
		$w coord $current(cur) $current(cpos) $x $y
		$w noundo coords $current(citem) $x $y
	} elseif {"$current(action)" == "scale"} {
		switch $current(name) {
			_sb_nw {$w noundo selection draw [list $x $y $current(x2) $current(y2)]}
			_sb_se {$w noundo selection draw [list $current(x1) $current(y1) $x $y]}
			_sb_ne {$w noundo selection draw [list $current(x1) $y $x $current(y2)]}
			_sb_sw {$w noundo selection draw [list $x $current(y1) $current(x2) $y]}
			_sb_n {$w noundo selection draw [list $current(x1) $y $current(x2) $current(y2)]}
			_sb_s {$w noundo selection draw [list $current(x1) $current(y1) $current(x2) $y]}
			_sb_e {$w noundo selection draw [list $current(x1) $current(y1) $x $current(y2)]}
			_sb_w {$w noundo selection draw [list $x $current(y1) $current(x2) $current(y2)]}
		}
	} elseif {"$current(action)" == "rotatepos"} {
		$w noundo coords $current(citem) $x $y
	} else {
		global status
		if !$status($w,rotate) {
			$w move _sel [expr {$x-$current(x)}] [expr {$y-$current(y)}]
		} else {
			set rx [$w coords _rotatepos]
			set ry [lpop rx]
			set a [expr [sqangle $rx $ry $x $y]-[sqangle $rx $ry $current(x) $current(y)]]
			$w rotate _sel $rx $ry $a
			$w selection redraw
		}
		set current(x) $x
		set current(y) $y
	}
}

proc select_release {w x y args} {
	global current
	set x [$w canvasx $x]
	set y [$w canvasy $y]
	set zoom [$w zoom]
	set current(px) [expr {$x/$zoom}]
	set current(py) [expr {$y/$zoom}]
	if ![info exists current(action)] {
		$w undo check stop
		return
	}
	if {"$current(action)" == "sel"} {
		set list ""
		foreach item [$w find enclosed $current(x) $current(y) $x $y] {
			set group [$w findgroup $item]
			if {"$group" != ""} {
				eval lappend list [$w find withtag $group]
			} else {
				lappend list $item
			}
		}
		$w selection add $list
		$w selector -100 -100 -100 -100
	} elseif {"$current(action)" == "scale"} {
		if {($current(x) == $x) && ($current(y) == $y)} {
			return
		} else {
			set nw [$w coords _sb_nw]
			set se [$w coords _sb_se]
			set c [$w selection coords]
			set xscale [expr {([lindex $se 0]-[lindex $nw 0]) / ($current(x2)-$current(x1))}]
			set yscale [expr {([lindex $se 1]-[lindex $nw 1]) / ($current(y2)-$current(y1))}]
			switch $current(name) {
				_sb_n - _sb_nw {set x $current(x2) ; set y $current(y2)}
				_sb_s - _sb_se {set x $current(x1) ; set y $current(y1)}
				_sb_e - _sb_ne {set x $current(x1) ; set y $current(y2)}
				_sb_w - _sb_sw {set y $current(y1) ; set x $current(x2)}
			}
			$w scale _sel $x $y $xscale $yscale
			$w current $current(cur)
		}
	} elseif {"$current(action)" == "coords"} {
		Classy::todo $w selection redraw
	} elseif {"$current(action)" == "rotatepos"} {
	} else {
		$w undo check stop
	}
	unset current(action)
}

proc select_abort {w x y} {
global current
catch {unset current(cur)}
}

proc select_start w {
global current status
catch {unset current}
$w selection set {}
$w current {}
bindtags $w [list Select $w Classy::Menu_MainMenu Classy::Canvas Canvas .mainw all]
set status($w,type) select
}
