#Functions

proc text_action {w x y} {
puts text_action
putsvars w x y
global current
$w select clear
set x [$w canvasx $x]
set y [$w canvasy $y]
if [info exists current(cur)] {
	if {"[$w itemcget $current(cur) -text]" == ""} {
		$w delete $current(cur)
	}
}
foreach item [$w find overlapping $x $y $x $y] {
	if {"[$w type $item]" == "text"} {
		set current(cur) $item
		$w focus $current(cur)
		$w icursor $current(cur) @$x,$y
		$w select from $current(cur) @$x,$y
		$w selection set $current(cur)
		return
	}
}
set current(cur) [$w create text $x $y]
$w focus $current(cur)
$w icursor $current(cur) 0
$w selection set $current(cur)
}

proc text_start w {
global current status
catch {unset current}
$w selection set {}
bindtags $w [list DrawText $w Classy::Menu_MainMenu Classy::Canvas Canvas .mainw all]
set status($w,type) text
}

proc text_key {w value} {
global current
if {"[$w select item]" != ""} {set select 1} else {set select 0}
switch $value {
	cut {
		if $select {
			set text [$w itemcget $current(cur) -text]
			set fpos [$w index $current(cur) sel.first]
			set epos [$w index $current(cur) sel.last]
			clipboard clear -displayof $w
			clipboard append -displayof $w [string range $text $fpos $epos]
			$w dchars $current(cur) $fpos $epos
			$w select clear
		}
	}
	copy {
		if $select {
			set text [$w itemcget $current(cur) -text]
			set fpos [$w index $current(cur) sel.first]
			set epos [$w index $current(cur) sel.last]
			clipboard clear -displayof $w
			clipboard append -displayof $w [string range $text $fpos $epos]
		}
	}
	paste {
		$w insert $current(cur) insert [selection get -displayof $w \
				-selection CLIPBOARD]
	}
	backspace {
		$w dchars $current(cur) [expr {[$w index $current(cur) insert]-1}]
	}
	delete {
		if $select {
			$w dchars $current(cur) sel.first sel.last
			$w select clear
		} else {
			$w dchars $current(cur) insert
		}
	}
	left {
		if $select {$w select clear}
		$w icursor $current(cur) [expr {[$w index $current(cur) insert]-1}]
	}
	right {
		if $select {$w select clear}
		$w icursor $current(cur) [expr {[$w index $current(cur) insert]+1}]
	}
	up {
		if $select {$w select clear}
		set pos [$w index $current(cur) insert]
		set text [$w itemcget $current(cur) -text]
		set list [text_findline $text $pos]
		set spos [lindex $list 1]
		set len [expr {$pos-$spos}]
		set npos [expr {[lindex $list 0]+$len}]
		if {$npos > $spos} {set npos $spos}
		$w icursor $current(cur) $npos
	}
	down {
		if $select {$w select clear}
		set pos [$w index $current(cur) insert]
		set text [$w itemcget $current(cur) -text]
		set list [text_findline $text $pos]
		set spos [lindex $list 1]
		set len [expr {$pos-$spos}]
		set max [lindex $list 3]
		incr max
		if {$len != 0} {
			set npos [expr {[lindex $list 2]+$len}]
		} else {
			set npos $max
		}
		if {$npos > $max} {set npos $max}
		$w icursor $current(cur) $npos
	}
	linestart {
		if $select {$w select clear}
		set pos [$w index $current(cur) insert]
		set text [$w itemcget $current(cur) -text]
		set list [text_findline $text $pos]
		set npos [lindex $list 1]
		if {$npos == $pos} {set npos [lindex $list 0]}
		incr npos
		$w icursor $current(cur) $npos
	}
	lineend {
		if $select {$w select clear}
		set pos [$w index $current(cur) insert]
		set text [$w itemcget $current(cur) -text]
		set list [text_findline $text $pos]
		$w icursor $current(cur) [lindex $list 2]
	}
	textstart {
		$w icursor $current(cur) 0
	}
	textend {
		$w icursor $current(cur) end
	}
	default {
		$w insert $current(cur) insert $value
	}
}
}

proc text_select {w value args} {
global current
if {"[$w select item]" != ""} {set select 1} else {set select 0}
if !$select {
	$w select from $current(cur) insert
	$w select to $current(cur) insert
}
switch $value {
	drag {
		set x [$w canvasx [lindex $args 0]]
		set y [$w canvasy [lindex $args 1]]
		set npos [$w index $current(cur) @$x,$y]
	}
	left {
		if !$select {$w select from $current(cur) insert}
		set npos [expr {[$w index $current(cur) insert]-1}]
		$w icursor $current(cur) $npos
	}
	right {
		if !$select {$w select from $current(cur) insert}
		set npos [expr {[$w index $current(cur) insert]+1}]
		$w icursor $current(cur) $npos
	}
	up {
		set pos [$w index $current(cur) insert]
		set text [$w itemcget $current(cur) -text]
		set list [text_findline $text $pos]
		set spos [lindex $list 1]
		set len [expr {$pos-$spos}]
		set npos [expr {[lindex $list 0]+$len}]
		if {$npos > $spos} {set npos $spos}
		$w icursor $current(cur) $npos
	}
	down {
		set pos [$w index $current(cur) insert]
		set text [$w itemcget $current(cur) -text]
		set list [text_findline $text $pos]
		set spos [lindex $list 1]
		set len [expr {$pos-$spos}]
		set max [lindex $list 3]
		incr max
		if {$len != 0} {
			set npos [expr {[lindex $list 2]+$len}]
		} else {
			set npos $max
		}
		if {$npos > $max} {set npos $max}
		$w icursor $current(cur) $npos
	}
	linestart {
		set pos [$w index $current(cur) insert]
		set text [$w itemcget $current(cur) -text]
		set list [text_findline $text $pos]
		set npos [lindex $list 1]
		if {$npos == $pos} {set npos [lindex $list 0]}
		incr npos
		$w icursor $current(cur) $npos
	}
	lineend {
		set pos [$w index $current(cur) insert]
		set text [$w itemcget $current(cur) -text]
		set list [text_findline $text $pos]
		set npos [lindex $list 2]
		$w icursor $current(cur) $npos
	}
	textstart {
		$w icursor $current(cur) 0
		set npos [$w index $current(cur) insert]
	}
	textend {
		$w icursor $current(cur) end
		set npos [$w index $current(cur) insert]
	}
	all {
		$w select from $current(cur) 0
		set npos [$w index $current(cur) end]
	}
	none {
		$w select clear
		return
	}
}
set pos [$w index $current(cur) sel.first]
if {$npos > $pos} {
	incr npos -1
}
$w select to $current(cur) $npos

}

proc text_findline {text pos} {
set spos [string last "\n" [string range $text 0 $pos]]
set ppos [string last "\n" [string range $text 0 [expr {$spos-1}]]]
set dist [string first "\n" [string range $text $pos end]]
if {$dist == -1} {
	set npos [string length $text]
	set nnpos [string length $text]
} else {
	set npos [expr {$pos+$dist}]
	set dist [string first "\n" [string range $text [expr {$npos+1}] end]]
	if {$dist == -1} {
		set nnpos [string length $text]
	} else {
		set nnpos [expr {$npos+$dist}]
	}
}
return [list $ppos $spos $npos $nnpos]
}
