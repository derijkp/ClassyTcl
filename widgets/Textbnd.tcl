#
# ####  #####  ####   #### 
# #   # #     #    # # 
# ####  ####  #    #  #### 
# #     #     #    #      # 
# #     #####  ####   ####  Peter De Rijk
#
# default bindings for Classy text widgets
# ----------------------------------------------------------------------

# adapted from
# This file defines the default bindings for Tk text widgets and provides
# procedures that help in implementing the bindings.
#
# @(#) text.tcl 1.36 95/06/28 10:24:23
#
# Copyright (c) 1992-1994 The Regents of the University of California.
# Copyright (c) 1994-1995 Sun Microsystems, Inc.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#

#-------------------------------------------------------------------------
# Elements of tkPriv that are used in this file:
#
# afterId -		If non-null, it means that auto-scanning is underway
#			and it gives the "after" id for the next auto-scan
#			command to be executed.
# char -		Character position on the line;  kept in order
#			to allow moving up or down past short lines while
#			still remembering the desired position.
# mouseMoved -		Non-zero means the mouse has moved a significant
#			amount since the button went down (so, for example,
#			start dragging out a selection).
# prevPos -		Used when moving up or down lines via the keyboard.
#			Keeps track of the previous insert position, so
#			we can distinguish a series of ups and downs, all
#			in a row, from a new up or down.
# selectMode -		The style of selection currently underway:
#			char, word, or line.
# x, y -		Last known mouse coordinates for scanning
#			and auto-scanning.
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# The code below creates the default class bindings for entries.
#-------------------------------------------------------------------------

bind Classy::Text <<Drop>> {
	catch {%W textinsert [DragDrop get]}
}
bind Classy::Text <<Drag-Motion>> {
	%W position [::class::Tk_%W index @%x,%y]
}

bind Classy::Text <<Action>> {
	%W position [::class::Tk_%W index @%x,%y]
}
bind Classy::Text <<Action-Motion>> {
	set tkPriv(x) %x
	set tkPriv(y) %y
	Classy::Text_SelectTo %W %x %y
}
bind Classy::Text <<MSelectWord>> {
	set tkPriv(selectMode) word
	Classy::Text_SelectTo %W %x %y
	catch {%W mark set insert sel.first}
}
bind Classy::Text <<MSelectLine>> {
	set tkPriv(selectMode) line
	Classy::Text_SelectTo %W %x %y
	catch {%W mark set insert sel.first}
}
bind Classy::Text <<MExtend>> {
	Classy::Text_ResetAnchor %W @%x,%y
	set tkPriv(selectMode) char
	Classy::Text_SelectTo %W %x %y
}
bind Classy::Text <<MExtendWord>>	{
	set tkPriv(selectMode) word
	Classy::Text_SelectTo %W %x %y
}
bind Classy::Text <<MExtendLine>>	{
	set tkPriv(selectMode) line
	Classy::Text_SelectTo %W %x %y
}
bind Classy::Text <<Action-Leave>> {
	set tkPriv(x) %x
	set tkPriv(y) %y
	Classy::Text_AutoScan %W
}
bind Classy::Text <<Action-Enter>> {
	tkCancelRepeat
}
bind Classy::Text <<ButtonRelease-Action>> {
	tkCancelRepeat
}
bind Classy::Text <<Control-Action>> {
	%W mark set insert @%x,%y
}
bind Classy::Text <<MXPaste>> {
	catch {%W textinsert [selection get -displayof %W]}
}
bind Classy::Text <<Left>> {
	%W move left
}
bind Classy::Text <<Right>> {
	%W move right
}
bind Classy::Text <<Up>> {
	%W move up
}
bind Classy::Text <<Down>> {
	%W move down
}
bind Classy::Text <<SelectLeft>> {
	%W select left
}
bind Classy::Text <<SelectRight>> {
	%W select right
}
bind Classy::Text <<SelectUp>> {
	%W select up
}
bind Classy::Text <<SelectDown>> {
	%W select down
}
bind Classy::Text <<WordLeft>> {
	%W move wordstart
}
bind Classy::Text <<WordRight>> {
	%W move wordend
}
bind Classy::Text <<SelectWordLeft>> {
	%W select wordstart
}
bind Classy::Text <<SelectWordRight>> {
	%W select wordend
}
bind Classy::Text <<ParaUp>> {
	%W move uppara
}
bind Classy::Text <<ParaDown>> {
	%W move downpara
}
bind Classy::Text <<SelectParaUp>> {
	%W select uppara
}
bind Classy::Text <<SelectParaDown>> {
	%W select downpara
}
bind Classy::Text <<PageUp>> {
	%W move pageup
}
bind Classy::Text <<SelectPageUp>> {
	%W select pageup
}
bind Classy::Text <<ScrolPageUp>> {
	%W xview scroll -1 page
}
bind Classy::Text <<PageDown>> {
	%W move pagedown
}
bind Classy::Text <<SelectPageDown>> {
	%W select pagedown
}
bind Classy::Text <<ScrollPageDown>> {
	%W xview scroll 1 page
}

bind Classy::Text <<Home>> {
	%W move linestart
}
bind Classy::Text <<SelectHome>> {
	%W select linestart
}
bind Classy::Text <<End>> {
	%W move lineend
}
bind Classy::Text <<SelectEnd>> {
	%W select lineend
}
bind Classy::Text <<Top>> {
	%W move textstart
}
bind Classy::Text <<SelectTop>> {
	%W select textstart
}
bind Classy::Text <<Bottom>> {
	%W move textend
}
bind Classy::Text <<SelectBottom>> {
	%W select textend
}

bind Classy::Text <Tab> {
	%W textinsert \t
	focus %W
	break
}
bind Classy::Text <Shift-Tab> {
	# Needed only to keep <Tab> binding from triggering;  doesn't
	# have to actually do anything.
}
bind Classy::Text <<SpecialFocusNext>> {
	focus [tk_focusNext %W]
}
bind Classy::Text <<SpecialFocusPrev>> {
	focus [tk_focusPrev %W]
}
bind Classy::Text <Control-i> {
	%W textinsert \t
}
bind Classy::Text <Return> {
	%W textinsert \n
}
bind Classy::Text <<Delete>> {
	%W textdelete
}
bind Classy::Text <<BackSpace>> {
	%W backspace
}

bind Classy::Text <<StartSelect>> {
	%W select start
}
bind Classy::Text <Select> {
	%W select start
}
bind Classy::Text <<EndSelect>> {
	%W select end
}
bind Classy::Text <<SelectAll>> {
	%W select all
}
bind Classy::Text <<SelectNone>> {
	%W select none
}
bind Classy::Text <Insert> {
	catch {%W textinsert [selection get -displayof %W]}
}
bind Classy::Text <KeyPress> {
	if {"%A"!="{}"} {
		%W textinsert %A
	}
}

# The new bindings

bind Classy::Text <<Copy>> {
	%W copy			
}												  
bind Classy::Text <<Cut>> {
	%W cut
}
bind Classy::Text <<Paste>> {
	%W paste
}
bind Classy::Text <<Undo>> {
	%W undo
}
bind Classy::Text <<Redo>> {
	%W redo
}

# Ignore all Alt, Meta, and Control keypresses unless explicitly bound.
# Otherwise, if a widget binding for one of these is defined, the
# <KeyPress> class binding will also fire and insert the character,
# which is wrong.  Ditto for <Escape>.

bind Classy::Text <Alt-KeyPress> {# nothing }
bind Classy::Text <Meta-KeyPress> {# nothing}
bind Classy::Text <Control-KeyPress> {# nothing}
bind Classy::Text <Escape> {# nothing}
bind Classy::Text <KP_Enter> {# nothing}

set tkPriv(prevPos) {}

# Classy::Text_SelectTo --
# This procedure is invoked to extend the selection, typically when
# dragging it with the mouse.  Depending on the selection mode (character,
# word, line) it selects in different-sized units.  This procedure
# ignores mouse motions initially until the mouse has moved from
# one character to another or until there have been multiple clicks.
#
# Arguments:
# w -		The text window in which the button was pressed.
# x -		Mouse x position.
# y - 		Mouse y position.
proc Classy::Text_SelectTo {w x y} {
	global tkPriv

	set w [Classy::window $w]
	set cur [$w index @$x,$y]
	if [catch {$w index anchor}] {
		$w mark set anchor $cur
	}
	set anchor [$w index anchor]
	if {[$w compare $cur != $anchor] || (abs($tkPriv(pressX) - $x) >= 3)} {
		set tkPriv(mouseMoved) 1
	}
	switch $tkPriv(selectMode) {
		char {
			if [$w compare $cur < anchor] {
				set first $cur
				set last anchor
			} else {
				set first anchor
				set last [$w index "$cur + 1c"]
			}
		}
		word {
			if [$w compare $cur < anchor] {
				set first [$w index "$cur wordstart"]
				set last [$w index "anchor - 1c wordend"]
			} else {
				set first [$w index "anchor wordstart"]
				set last [$w index "$cur wordend"]
			}
		}
		line {
			if [$w compare $cur < anchor] {
				set first [$w index "$cur linestart"]
				set last [$w index "anchor - 1c lineend + 1c"]
			} else {
				set first [$w index "anchor linestart"]
				set last [$w index "$cur lineend + 1c"]
			}
		}
	}
	if {$tkPriv(mouseMoved) || ($tkPriv(selectMode) != "char")} {
		$w tag remove sel 0.0 $first
		$w tag add sel $first $last
		$w tag remove sel $last end
		update idletasks
	}
}

# Classy::Text_AutoScan --
# This procedure is invoked when the mouse leaves a text window
# with button 1 down.  It scrolls the window up, down, left, or right,
# depending on where the mouse is (this information was saved in
# tkPriv(x) and tkPriv(y)), and reschedules itself as an "after"
# command so that the window continues to scroll until the mouse
# moves back into the window or the mouse button is released.
#
# Arguments:
# w -		The text window.

proc Classy::Text_AutoScan {w} {
	global tkPriv
	if {![winfo exists $w]} return
	if {$tkPriv(y) >= [winfo height $w]} {
		::class::Tk_$w yview scroll 2 units
	} elseif {$tkPriv(y) < 0} {
		::class::Tk_$w yview scroll -2 units
	} elseif {$tkPriv(x) >= [winfo width $w]} {
		::class::Tk_$w xview scroll 2 units
	} elseif {$tkPriv(x) < 0} {
		::class::Tk_$w xview scroll -2 units
	} else {
		return
	}
	Classy::Text_SelectTo $w $tkPriv(x) $tkPriv(y)
	set tkPriv(afterId) [after 50 Classy::Text_AutoScan $w]
}

# Classy::Text_ResetAnchor --
# Set the selection anchor to whichever end is farthest from the
# index argument.  One special trick: if the selection has two or
# fewer characters, just leave the anchor where it is.  In this
# case it doesn't matter which point gets chosen for the anchor,
# and for the things like Shift-Left and Shift-Right this produces
# better behavior when the cursor moves back and forth across the
# anchor.
#
# Arguments:
# w -		The text widget.
# index -	Position at which mouse button was pressed, which determines
#		which end of selection should be used as anchor point.

proc Classy::Text_ResetAnchor {w index} {
	global tkPriv

	set w [Classy::window $w]
	if {[$w tag ranges sel] == ""} {
		$w mark set anchor $index
		return
	}
	set a [$w index $index]
	set b [$w index sel.first]
	set c [$w index sel.last]
	if [$w compare $a < $b] {
		$w mark set anchor sel.last
		return
	}
	if [$w compare $a > $c] {
		$w mark set anchor sel.first
		return
	}
	scan $a "%d.%d" lineA chA
	scan $b "%d.%d" lineB chB
	scan $c "%d.%d" lineC chC
	if {$lineB < $lineC+2} {
		set total [string length [$w get $b $c]]
	if {$total <= 2} {
		return
	}
	if {[string length [$w get $b $a]] < ($total/2)} {
		$w mark set anchor sel.last
	} else {
		$w mark set anchor sel.first
	}
	return
	}
	if {($lineA-$lineB) < ($lineC-$lineA)} {
		$w mark set anchor sel.last
	} else {
		$w mark set anchor sel.first
	}
}

