proc line_cap {window} {
	global current
	if {"[$window.arrow.l get]" == ""} {$window.arrow.l set 15}
	if {"[$window.arrow.w get]" == ""} {$window.arrow.w set 5}
	if {"[$window.arrow.sl get]" == ""} {$window.arrow.sl set 10}
	$current(w) itemconfigure _sel -arrow $current(-arrow) \
		-capstyle $current(-capstyle) \
		-arrowshape [list [$window.arrow.sl get] [$window.arrow.l get] [$window.arrow.w get]]
}

proc update_config {w} {
	global current
	foreach option {-width -text -smooth -arrow -arrowshape -capstyle -tags} {
		catch {set current($option) [$w itemcget $current(cur) $option]}
	}
	if [info exists current(-arrowshape)] {
		set current(arrow_sl) [lindex $current(-arrowshape) 0]
		set current(arrow_l) [lindex $current(-arrowshape) 1]
		set current(arrow_w) [lindex $current(-arrowshape) 2]
	}
	if [info exists current(cpos)] {
		set c [$w coords $current(cur)]
		set pos [expr {2*$current(cpos)}]
		set current(px) [lindex $c $pos]
		incr pos
		set current(py) [lindex $c $pos]
	} else {
		set bbox [$w bbox $current(cur)]
		set current(px) [lindex $bbox 0]
		set current(py) [lindex $bbox 1]
	}
}

proc bottom_objects {w tag} {
	$w lower $tag
	$w raise $tag _page
}

proc top_objects {w tag} {
	$w raise $tag
}

proc lower_objects {w tag} {
	$w dtag _temp _temp
	$w addtag _temp withtag $tag
	set items [$w find withtag $tag]
	set low [lindex $items 0]
	foreach item $items {
		eval $w addtag _temp overlapping [$w bbox $item]
	}
	set items [$w find withtag _temp]
	set pos [lsearch $items $low]
	if {$pos>0} {
		incr pos -1
		$w lower $tag [lindex $items $pos]
	}
	$w dtag _temp _temp
}

proc raise_objects {w tag} {
	$w dtag temp temp
	$w addtag temp withtag $tag
	set items [$w find withtag $tag]
	set high [lindex $items end]
	foreach item $items {
		eval $w addtag temp overlapping [$w bbox $item]
	}
	set items [$w find withtag temp]
	set pos [lsearch $items $high]
	set len [llength $items]
	incr len -1
	if {$pos<$len} {
		incr pos 1
		$w raise $tag [lindex $items $pos]
	}
	$w dtag temp temp
}

