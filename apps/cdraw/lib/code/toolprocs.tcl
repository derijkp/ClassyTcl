proc zoomentry {w} {
puts $w
	Classy::NumEntry $w
	return [varsubst w {
		bind $w <Enter> {$w nocmdset [expr {round([%W zoom]*1000)/10.0}]}
		$w configure -command [list zoom %W] -textvariable current(%W,zoom)
	}]
}

proc zoomtool {w} {
	radiobutton $w -image [Classy::geticon zoom] -indicatoron no
	return [varsubst w {
		$w configure -variable status(%W,type) -value zoom -command {zoom_start %W}
	}]
}

proc selecttool {w} {
	radiobutton $w -image [Classy::geticon select] -indicatoron no
	return [varsubst w {
		$w configure -variable status(%W,type) -value select -command {select_start %W}
	}]
}

proc texttool {w} {
	radiobutton $w -image [Classy::geticon text] -indicatoron no
	return [varsubst w {
		$w configure -variable status(%W,type) -value text -command {text_start %W}
	}]
}

proc linetool {w} {
	radiobutton $w -image [Classy::geticon line] -indicatoron no
	return [varsubst w {
		$w configure -variable status(%W,type) -value line -command {line_start %W}
	}]
}

proc polytool {w} {
	radiobutton $w -image [Classy::geticon poly] -indicatoron no
	return [varsubst w {
		$w configure -variable status(%W,type) -value polygon -command {polygon_start %W}
	}]
}

proc recttool {w} {
	radiobutton $w -image [Classy::geticon rect] -indicatoron no
	return [varsubst w {
		$w configure -variable status(%W,type) -value rectangle -command {rectangle_start %W}
	}]
}

proc ovaltool {w} {
	radiobutton $w -image [Classy::geticon oval] -indicatoron no
	return [varsubst w {
		$w configure -variable status(%W,type) -value oval -command {oval_start %W}
	}]
}

proc arctool {w} {
	radiobutton $w -image [Classy::geticon arc] -indicatoron no
	return [varsubst w {
		$w configure -variable status(%W,type) -value arc -command {arc_start %W}
	}]
}

proc rotatetool {w} {
	checkbutton $w -image [Classy::geticon rotate] -indicatoron no
	return [varsubst w {
		$w configure -variable status(%W,rotate) -command {rotate_set %W}
	}]
}

