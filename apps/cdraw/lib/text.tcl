#Functions
proc text_init {} {
bind DrawText <<Action>> {text_action %W %x %y}
bind DrawText <<Adjust>> {text_action %W %x %y}
bind DrawText <KeyPress> {text_key %W %A}
bind DrawText <BackSpace> {text_key %W backspace}
bind DrawText <Delete> {text_key %W delete}
bind DrawText <<Left>> {text_key %W left}
bind DrawText <<Right>> {text_key %W right}
bind DrawText <<Up>> {text_key %W up}
bind DrawText <<Down>> {text_key %W down}

bind DrawText <<Action-Motion>> {
	text_select %W drag %x %y
}
bind DrawText <<MXPaste>> {
	catch {%W insert $current(cur) insert [selection get -displayof %W]}
}
bind DrawText <<SelectLeft>> {
	text_select %W left
}
bind DrawText <<SelectRight>> {
	text_select %W right
}
bind DrawText <<SelectUp>> {
	text_select %W up
}
bind DrawText <<SelectDown>> {
	text_select %W down
}
bind DrawText <<WordLeft>> {
	text_move %W wordstart
}
bind DrawText <<WordRight>> {
	text_move %W wordend
}
bind DrawText <<SelectWordLeft>> {
	text_select %W wordstart
}
bind DrawText <<SelectWordRight>> {
	text_select %W wordend
}
bind DrawText <<ParaUp>> {
	text_move %W uppara
}
bind DrawText <<ParaDown>> {
	text_move %W downpara
}
bind DrawText <<SelectParaUp>> {
	text_select %W uppara
}
bind DrawText <<SelectParaDown>> {
	text_select %W downpara
}
bind DrawText <<PageUp>> {
	text_move %W pageup
}
bind DrawText <<SelectPageUp>> {
	text_select %W pageup
}
bind DrawText <<ScrolPageUp>> {
	text_key %W xview scroll -1 page
}
bind DrawText <<PageDown>> {
	text_move %W pagedown
}
bind DrawText <<SelectPageDown>> {
	text_select %W pagedown
}

bind DrawText <<Home>> {
	text_move %W linestart
}
bind DrawText <<SelectHome>> {
	text_select %W linestart
}
bind DrawText <<End>> {
	text_move %W lineend
}
bind DrawText <<SelectEnd>> {
	text_select %W lineend
}
bind DrawText <<Top>> {
	text_move %W textstart
}
bind DrawText <<SelectTop>> {
	text_select %W textstart
}
bind DrawText <<Bottom>> {
	text_move %W textend
}
bind DrawText <<SelectBottom>> {
	text_select %W textend
}

bind DrawText <Tab> {
	%W textinsert \t
	focus %W
	break
}
bind DrawText <Shift-Tab> {
	# Needed only to keep <Tab> binding from triggering;  doesn't
	# have to actually do anything.
}
bind DrawText <<SpecialFocusNext>> {
	focus [tk_focusNext %W]
}
bind DrawText <<SpecialFocusPrev>> {
	focus [tk_focusPrev %W]
}
bind DrawText <Control-i> {
	text_key %W \t
}
bind DrawText <Return> {
	text_key %W \n
}
bind DrawText <<Delete>> {
	text_key %W textdelete
}
bind DrawText <<BackSpace>> {
	text_key %W backspace
}

bind DrawText <<StartSelect>> {
	text_select %W start
}
bind DrawText <Select> {
	text_select %W start
}
bind DrawText <<EndSelect>> {
	text_select %W end
}
bind DrawText <<SelectAll>> {
	text_select %W all
}
bind DrawText <<SelectNone>> {
	text_select %W none
}
bind DrawText <Insert> {
	catch {%W textinsert [selection get -displayof %W]}
}

# The new bindings

bind DrawText <<Copy>> {
	text_key %W copy			
}												  
bind DrawText <<Cut>> {
	text_key %W cut
}
bind DrawText <<Paste>> {
	text_key %W paste
}
bind DrawText <<Undo>> {
	text_key %W undo
}
bind DrawText <<Redo>> {
	text_key %W redo
}

# Ignore all Alt, Meta, and Control keypresses unless explicitly bound.
# Otherwise, if a widget binding for one of these is defined, the
# <KeyPress> class binding will also fire and insert the character,
# which is wrong.  Ditto for <Escape>.

bind DrawText <Alt-KeyPress> {# nothing }
bind DrawText <Meta-KeyPress> {# nothing}
bind DrawText <Control-KeyPress> {# nothing}
bind DrawText <Escape> {# nothing}
bind DrawText <KP_Enter> {# nothing}
}

proc text_action {w x y} {
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
$w undo check

}

proc text_start w {
global current status
catch {unset current}
$w selection set {}
bindtags $w [list DrawText $w Classy::Menu_MainMenu Classy::Canvas Canvas .mainw all]
set status(type) text
}

proc text_key {w value} {
global current
if {"[$w select item]" != ""} {set select 1} else {set select 0}
switch $value {
	cut {
		$w dchars $current(cur) [expr {[$w index $current(cur) insert]-1}]
	}
	backspace {
		$w dchars $current(cur) [expr {[$w index $current(cur) insert]-1}]
		$w undo check
	}
	delete {
		if $select {
			$w dchars $current(cur) sel.first sel.last
			$w select clear
		} else {
			$w dchars $current(cur) insert
		}
		$w undo check
	}
	left {
		if $select {$w select clear}
		$w icursor $current(cur) [expr {[$w index $current(cur) insert]-1}]
	}
	right {
		if $select {$w select clear}
		$w icursor $current(cur) [expr {[$w index $current(cur) insert]+1}]
	}
	default {$w insert $current(cur) insert $value}
}
}

proc text_select {w value args} {
global current
if {"[$w select item]" != ""} {set select 1} else {set select 0}
switch $value {
	drag {
		set x [$w canvasx [lindex $args 0]]
		set y [$w canvasy [lindex $args 1]]
		$w select to $current(cur) @$x,$y
	}
	left {
		if !$select {$w select from $current(cur) insert}
		$w icursor $current(cur) [expr {[$w index $current(cur) insert]-1}]
		$w select to $current(cur) insert
	}
	right {
		if !$select {$w select from $current(cur) insert}
		$w icursor $current(cur) [expr {[$w index $current(cur) insert]+1}]
		$w select to $current(cur) insert
	}
}
}


