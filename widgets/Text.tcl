#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Text
# ----------------------------------------------------------------------
#doc Text title {
#Text
#} index {
# Tk improvements
#} shortdescr {
# text widget with undo/redo and linking (~multiple views)
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# creates a widgets which acts nearly like a text widget but
# has several extra capabilities:
#<ul>
#<li>undo and redo
#<li>linking to other text widgets
#<li>textchanged state
#</ul>
#}
#doc {Text options} h2 {
#	Text specific options
#}
#doc {Text command} h2 {
#	Text specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Text {} {}
proc Text {} {}
}

source [file join $::class::dir widgets Textbnd.tcl]
update idletasks

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Text
Classy::export Text {}

Classy::Text classmethod init {args} {
	super init text
	# REM Initialise options and variables
	# ------------------------------------
	private $object undobuffer redobuffer linked textchanged
	set textchanged 0
	set linked {}
	set undobuffer {}
	set redobuffer {}

	# REM Create bindings
	# --------------------
	bindtags $object [list $object Classy::Text . all]

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::Text chainoptions {$object}

#doc {Text options -changedcommand} option {-changedcommand changedcommand Changedcommand} descr {
#}
Classy::Text addoption -changedcommand {changedcommand Changedcommand {}}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Text chainallmethods {$object} text

#doc {Text command link} cmd {
#pathname link ?linkedwindow?
#} descr {
# returns the current linked window if linkedwindow is not given.
# Otherwise $linkedwindow is linked
#}
Classy::Text method link {{lw {}}} {
	private $object undobuffer redobuffer linked
	set w [Classy::window $object]
	if {"$lw"==""} {return $linked}
	if {[lsearch -exact $linked $lw]!=-1} {return $linked}
	if ![winfo exists $lw] {error "Couldn't link: $lw does not exists"}
	foreach var {flinked fundobuffer fredobuffer ftextchanged} val [$lw _getlink] {
		set $var $val
	}
	set undobuffer $fundobuffer
	set redobuffer $redobuffer
	if $ftextchanged {$object _changed}
	$w delete 1.0 end
	$w insert end [$lw get 1.0 end]
	$w delete "end-1c"
	set linked $flinked
	lappend linked $lw
	foreach link $linked {
		uplevel #0 lappend [privatevar $link linked] $object
	}
	return $linked
}

Classy::Text method _getlink {} {
	return [list [getprivate $object linked] [getprivate $object undobuffer] \
	[getprivate $object redobuffer] [getprivate $object textchanged]]
}

#doc {Text command unlink} cmd {
#pathname unlink 
#} descr {
#}
Classy::Text method unlink {} {
	private $object linked
	foreach link $linked {
		uplevel #0 [concat set [privatevar $link linked] \[lremove \$\{[privatevar $link linked]\} $object\]]
	}
	set linked ""
}

#doc {Text command textinsert} cmd {
#pathname textinsert string
#} descr {
#}
Classy::Text method textinsert {s} {
	set w [Classy::window $object]
	if {($s == "") || ([$w cget -state] == "disabled")} {
		return
	}
	catch {
	if {[$w compare sel.first <= insert]
		&& [$w compare sel.last >= insert]} {
		$object delete sel.first sel.last
	}
	}
	$object insert insert $s
	$w see insert
}

#doc {Text command insert} cmd {
#pathname insert index chars ?tag ...?
#} descr {
#}
Classy::Text method insert {index chars args} {
	private $object undobuffer redobuffer linked textchanged
	set w [Classy::window $object]
	set redobuffer ""
	if {([$w cget -state] == "disabled") || ("$chars"=="")} return
	set ins [$w index insert]
	set index [$w index $index]
	foreach link $linked {
		eval {$link _linkinsert $index $chars} $args
	}
	$w mark set insert $index
	eval {$w insert insert $chars} $args
	lappend undobuffer [list Insert $chars $index [$w index insert]]
	$w mark set insert "$ins + [string length $chars] c"
	if {$textchanged != 1} {$object _changed}
}

Classy::Text method _linkinsert {index chars args} {
	private $object undobuffer redobuffer linked textchanged
	set w [Classy::window $object]
	set redobuffer ""
	$w mark set insert $index
	eval {$w insert insert $chars} $args
	lappend undobuffer [list Insert $chars $index [$w index insert]]
	if {$textchanged != 1} {$object _changed}
}

#doc {Text command textchanged} cmd {
#pathname textchanged ?1/0?
#} descr {
#query or set the textchanged state
#}
Classy::Text method textchanged {{bool {}}} {
	private $object textchanged linked
	if {"$bool"==""} {
		return $textchanged
	} else {
		if $bool {
			$object _changed
		} else {
			set textchanged $bool
		}
		foreach link $linked {
			if $bool {
				$link _changed
			} else {
				uplevel #0 set [privatevar $link textchanged] 0
			}
		}
	}
}

Classy::Text method _changed {} {
	private $object textchanged
	set textchanged 1
	uplevel #0 [getprivate $object options(-changedcommand)]
}

#doc {Text command delete} cmd {
#pathname delete args ?startindex endindex?
#} descr {
#}
Classy::Text method delete {args} {
	private $object undobuffer redobuffer linked textchanged
	set w [Classy::window $object]
	set redobuffer ""
	if {([$w cget -state] == "disabled") || ![llength $args]} return
	if {$args == ""} {
		set index1 [$w index sel.first]
		set index2 [$w index sel.last]
	} else {
		set index1 [$w index [lindex $args 0]]
		if {[llength $args]==1} {
			set index2 [$w index "$index1 + 1c"]
		} else {
			set index2 [$w index [lindex $args 1]]
		}
	}
	foreach link $linked {
		eval {$link _linkdelete $index1 $index2} $args
	}
	lappend undobuffer [list Delete [$w get $index1 $index2] $index1 $index2]
	$w delete $index1 $index2
	if {$textchanged != 1} {$object _changed}
}

Classy::Text method _linkdelete {index1 index2 args} {
	private $object undobuffer redobuffer textchanged
	set w [Classy::window $object]
	set redobuffer ""
	lappend undobuffer [list Delete [$w get $index1 $index2] $index1 $index2]
	$w delete $index1 $index2
	if {$textchanged != 1} {$object _changed}
}

#doc {Text command undo} cmd {
#pathname undo ?nolink?
#} descr {
#}
Classy::Text method undo {{link {}}} {
	private $object undobuffer redobuffer
	set w [Classy::window $object]
	if {$undobuffer == ""} {
		error "Nothing to undo"
	}
	set undo [lpop undobuffer]
	set index1 [lindex $undo 2]
	if {"$link" == ""} {
		$w mark set insert $index1
		$w see $index1
	}
	switch [lindex $undo 0] {
		Insert {
			$w delete $index1 [lindex $undo 3]
		}
		Delete {
			$w insert $index1 [lindex $undo 1]
		}
	}
	lappend redobuffer $undo
	if {"$link"==""} {
		private $object linked
		foreach link $linked {
			$link undo link
		}
	}
}

#doc {Text command redo} cmd {
#pathname redo ?nolink?
#} descr {
#}
Classy::Text method redo {{link {}}} {
	private $object undobuffer redobuffer
	set w [Classy::window $object]
	if {$redobuffer == ""} {
		error "Nothing to redo"
	}
	set redo [lpop redobuffer]
	set index1 [lindex $redo 2]
	if {"$link" == ""} {
		$w mark set insert $index1
		$w see $index1
	}
	switch [lindex $redo 0] {
		Delete {
			$w delete $index1 [lindex $redo 3]
		}
		Insert {
			$w insert $index1 [lindex $redo 1]
		}
	}
	lappend undobuffer $redo
	if {"$link"==""} {
		private $object linked
		foreach link $linked {
			$link redo link
		}
	}
}

#doc {Text command clearundo} cmd {
#pathname clearundo ?nolink?
#} descr {
#}
Classy::Text method clearundo {{link {}}} {
	private $object undobuffer redobuffer
	set undobuffer ""
	set redobuffer ""
	if {"$link"==""} {
		private $object linked
		foreach link $linked {
			$link clearundo link
		}
	}
}

#doc {Text command cut} cmd {
#pathname cut 
#} descr {
#}
Classy::Text method cut {} {
	if {[selection own -displayof $object] == "$object"} {   
		clipboard clear -displayof $object			  
		catch {									
			clipboard append -displayof $object [selection get -displayof $object]
			$object delete sel.first sel.last
		}
	}
}

#doc {Text command copy} cmd {
#pathname copy 
#} descr {
#}
Classy::Text method copy {} {
	if {[selection own -displayof $object] == "$object"} {   
		clipboard clear -displayof $object			  
		catch {									
			clipboard append -displayof $object [selection get -displayof $object]
		}										  
	}											  
}

#doc {Text command paste} cmd {
#pathname paste 
#} descr {
#}
Classy::Text method paste {} {
	catch {
		$object insert insert [selection get -displayof $object \
				-selection CLIPBOARD]
	}
}

#doc {Text command findsel} cmd {
#pathname findsel dir
#} descr {
#}
Classy::Text method findsel {dir} {
	if {"[$object tag ranges sel]" != ""} {
		if {"$dir" == "-forwards"} {set index sel.last} else {set index sel.first}
		set findwhat [$object get sel.first sel.last]
	}
	$object find $findwhat $dir -exact
}

#doc {Text command get} cmd {
#pathname get ?index1? ?index2?
#} descr {
#}
Classy::Text method get {args} {
	set len [llength $args]
	set w [Classy::window $object]
	if {$len == 0} {
		$w get 1.0 end
	} elseif {$len == 1} {
		$w get [lindex $args 0]
	} elseif {$len == 2} {
		$w get [lindex $args 0] [lindex $args 1]
	} else {
		return -code error "wrong # args: should be \"$object get ?index1? ?index2?\""
	}
}

#doc {Text command set} cmd {
#pathname set value
#} descr {
#}
Classy::Text method set {value} {
	set w [Classy::window $object]
	$object delete 1.0 end
	$object insert end $value
}

# REM Moving methods
#-------------------

#doc {Text command select} cmd {
#pathname select mode
#} descr {
#}
Classy::Text method select {mode} {
	set w [Classy::window $object]
	global tkPriv
	switch $mode {
		left {
			Classy::Text_KeySelect $object [$w index {insert - 1c}]
		}
		right {
			Classy::Text_KeySelect $object [$w index {insert + 1c}]
		}
		up {
			Classy::Text_KeySelect $object [Classy::Text_UpDownLine $object -1]
		}
		down {
			Classy::Text_KeySelect $object [Classy::Text_UpDownLine $object 1]
		}
		wordstart {
			Classy::Text_KeySelect $object [$w index {insert - 1c wordstart}]
		}
		wordend {
			Classy::Text_KeySelect $object [$w index {insert wordend}]
		}
		uppara {
			Classy::Text_KeySelect $object [Classy::Text_PrevPara $object insert]
		}
		downpara {
			Classy::Text_KeySelect $object [Classy::Text_NextPara $object insert]
		}
		pageup {
			Classy::Text_KeySelect $object [Classy::Text_ScrollPages $object -1]
		}
		pagedown {
			Classy::Text_KeySelect $object [Classy::Text_ScrollPages $object 1]
		}
		linestart {
			Classy::Text_KeySelect $object {insert linestart}
		}
		lineend {
			Classy::Text_KeySelect $object {insert lineend}
		}
		textstart {
			Classy::Text_KeySelect $object 1.0
		}
		textend {
			Classy::Text_KeySelect $object {end - 1 char}
		}
		start {
			 $object mark set anchor insert
		}
		end {
			set tkPriv(selectMode) char
			Classy::Text_KeyExtend $object insert
		}
		all {
			$w tag add sel 1.0 end
		}
		none {
			$w tag remove sel 1.0 end
		}
		word {
			$w mark set insert "insert wordstart"
			$w tag add sel insert "insert wordend"
		}
		line {
			$w mark set insert "insert linestart"
			$w tag add sel insert "insert lineend"
		}
	}
}

#doc {Text command move} cmd {
#pathname move mode
#} descr {
#}
Classy::Text method move {mode} {
	set w [Classy::window $object]
	global tkPriv
	switch $mode {
		left {
			Classy::Text_SetCursor $object [$w index {insert - 1c}]
		}
		right {
			Classy::Text_SetCursor $object [$w index {insert + 1c}]
		}
		up {
			Classy::Text_SetCursor $object [Classy::Text_UpDownLine $object -1]
		}
		down {
			Classy::Text_SetCursor $object [Classy::Text_UpDownLine $object 1]
		}
		wordstart {
			Classy::Text_SetCursor $object [$w index {insert - 1c wordstart}]
		}
		wordend {
			Classy::Text_SetCursor $object [$w index {insert wordend}]
		}
		uppara {
			Classy::Text_SetCursor $object [Classy::Text_PrevPara $object insert]
		}
		downpara {
			Classy::Text_SetCursor $object [Classy::Text_NextPara $object insert]
		}
		pageup {
			Classy::Text_SetCursor $object [Classy::Text_ScrollPages $object -1]
		}
		pagedown {
			Classy::Text_SetCursor $object [Classy::Text_ScrollPages $object 1]
		}
		linestart {
			Classy::Text_SetCursor $object {insert linestart}
		}
		lineend {
			Classy::Text_SetCursor $object {insert lineend}
		}
		textstart {
			Classy::Text_SetCursor $object 1.0
		}
		textend {
			Classy::Text_SetCursor $object {end - 1 char}
		}
		start {
			 $object mark set anchor insert
		}
	}
}

#doc {Text command backspace} cmd {
#pathname backspace 
#} descr {
#}
Classy::Text method backspace {} {
	set w [Classy::window $object]
	if {[$object tag nextrange sel 1.0 end] != ""} {
		$object delete sel.first sel.last
	} elseif [$w compare insert != 1.0] {
		$object delete insert-1c
		$object see insert
	}
}

#doc {Text command textdelete} cmd {
#pathname textdelete 
#} descr {
#}
Classy::Text method textdelete {} {
	if {[$object tag nextrange sel 1.0 end] != ""} {
	$object delete sel.first sel.last
	} else {
	$object delete insert
	$object see insert
	}
}

#doc {Text command position} cmd {
#pathname position index
#} descr {
#}
Classy::Text method position {index} {
	set w [Classy::window $object]
	global tkPriv

	regexp {(.*)\.(.*)} $index temp y x
	set tkPriv(selectMode) char
	set tkPriv(mouseMoved) 0
	set tkPriv(pressX) $x
	$w mark set insert $index
	$w mark set anchor insert
	if {[$w cget -state] == "normal"} {focus $object}
	$w tag remove sel 0.0 end
}

# The following procedures are mainly patches from the original tk sources
# ---------------------------------------------------------------------------
# Classy::Text_SetCursor
# Move the insertion cursor to a given position in a text.  Also
# clears the selection, if there is one in the text, and makes sure
# that the insertion cursor is visible.  Also, don't let the insertion
# cursor appear on the dummy last line of the text.
#
# Arguments:
# w -		The text window.
# pos -		The desired new position for the cursor in the window.

proc Classy::Text_SetCursor {w pos} {
	global tkPriv

	if [::class::Tk_$w compare $pos == end] {
	set pos {end - 1 chars}
	}
	::class::Tk_$w mark set insert $pos
	::class::Tk_$w tag remove sel 1.0 end
	::class::Tk_$w see insert
}

# Classy::Text_KeySelect
# This procedure is invoked when stroking out selections using the
# keyboard.  It moves the cursor to a new position, then extends
# the selection to that position.
#
# Arguments:
# w -		The text window.
# new -		A new position for the insertion cursor (the cursor hasn't
#		actually been moved to this position yet).

proc Classy::Text_KeySelect {w new} {
	global tkPriv

	if {[::class::Tk_$w tag nextrange sel 1.0 end] == ""} {
	if [::class::Tk_$w compare $new < insert] {
		::class::Tk_$w tag add sel $new insert
	} else {
		::class::Tk_$w tag add sel insert $new
	}
	::class::Tk_$w mark set anchor insert
	} else {
	if [::class::Tk_$w compare $new < anchor] {
		set first $new
		set last anchor
	} else {
		set first anchor
		set last $new
	}
	::class::Tk_$w tag remove sel 1.0 $first
	::class::Tk_$w tag add sel $first $last
	::class::Tk_$w tag remove sel $last end
	}
	::class::Tk_$w mark set insert $new
	::class::Tk_$w see insert
	update idletasks
}

# Classy::Text_UpDownLine --
# Returns the index of the character one line above or below the
# insertion cursor.  There are two tricky things here.  First,
# we want to maintain the original column across repeated operations,
# even though some lines that will get passed through don't have
# enough characters to cover the original column.  Second, don't
# try to scroll past the beginning or end of the text.
#
# Arguments:
# w -		The text window in which the cursor is to move.
# n -		The number of lines to move: -1 for up one line,
#		+1 for down one line.

proc Classy::Text_UpDownLine {w n} {
	global tkPriv

	set i [::class::Tk_$w index insert]
	scan $i "%d.%d" line char
	if {[string compare $tkPriv(prevPos) $i] != 0} {
	set tkPriv(char) $char
	}
	set new [::class::Tk_$w index [expr $line + $n].$tkPriv(char)]
	if {[::class::Tk_$w compare $new == end] || [::class::Tk_$w compare $new == "insert linestart"]} {
	set new $i
	}
	set tkPriv(prevPos) $new
	return $new
}

# Classy::Text_PrevPara --
# Returns the index of the beginning of the paragraph just before a given
# position in the text (the beginning of a paragraph is the first non-blank
# character after a blank line).
#
# Arguments:
# w -		The text window in which the cursor is to move.
# pos -		Position at which to start search.

proc Classy::Text_PrevPara {w pos} {
	set pos [$w index "$pos linestart"]
	while 1 {
	if {(([$w get "$pos - 1 line"] == "\n") && ([$w get $pos] != "\n"))
		|| ($pos == "1.0")} {
		if [regexp -indices {^[ 	]+(.)} [$w get $pos "$pos lineend"] \
			dummy index] {
		set pos [$w index "$pos + [lindex $index 0] chars"]
		}
		if {[$w compare $pos != insert] || ($pos == "1.0")} {
		return $pos
		}
	}
	set pos [$w index "$pos - 1 line"]
	}
}

# Classy::Text_NextPara --
# Returns the index of the beginning of the paragraph just after a given
# position in the text (the beginning of a paragraph is the first non-blank
# character after a blank line).
#
# Arguments:
# w -		The text window in which the cursor is to move.
# start -	Position at which to start search.

proc Classy::Text_NextPara {w start} {
	set pos [$w index "$start linestart + 1 line"]
	while {[$w get $pos] != "\n"} {
	if [$w compare $pos == end] {
		return [$w index "end - 1c"]
	}
	set pos [$w index "$pos + 1 line"]
	}
	while {[$w get $pos] == "\n"} {
	set pos [$w index "$pos + 1 line"]
	if [$w compare $pos == end] {
		return [$w index "end - 1c"]
	}
	}
	if [regexp -indices {^[ 	]+(.)} [$w get $pos "$pos lineend"] \
		dummy index] {
	return [$w index "$pos + [lindex $index 0] chars"]
	}
	return $pos
}

# Classy::Text_ScrollPages --
# This is a utility procedure used in bindings for moving up and down
# pages and possibly extending the selection along the way.  It scrolls
# the view in the widget by the number of pages, and it returns the
# index of the character that is at the same position in the new view
# as the insertion cursor used to be in the old view.
#
# Arguments:
# w -		The text window in which the cursor is to move.
# count -	Number of pages forward to scroll;  may be negative
#		to scroll backwards.

proc Classy::Text_ScrollPages {w count} {
	set bbox [$w bbox insert]
	$w yview scroll $count pages
	if {$bbox == ""} {
	return [$w index @[expr [winfo height $w]/2],0]
	}
	return [$w index @[lindex $bbox 0],[lindex $bbox 1]]
}

# Classy::Text_KeyExtend --
# This procedure handles extending the selection from the keyboard,
# where the point to extend to is really the boundary between two
# characters rather than a particular character.
#
# Arguments:
# w -		The text window.
# index -	The point to which the selection is to be extended.

proc Classy::Text_KeyExtend {w index} {
	global tkPriv

	set cur [::class::Tk_$w index $index]
	if [catch {::class::Tk_$w index anchor}] {
	::class::Tk_$w mark set anchor $cur
	}
	set anchor [::class::Tk_$w index anchor]
	if [::class::Tk_$w compare $cur < anchor] {
	set first $cur
	set last anchor
	} else {
	set first anchor
	set last $cur
	}
	::class::Tk_$w tag remove sel 0.0 $first
	::class::Tk_$w tag add sel $first $last
	::class::Tk_$w tag remove sel $last end
}

