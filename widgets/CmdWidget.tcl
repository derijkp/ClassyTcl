#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::CmdWidget
# ----------------------------------------------------------------------
#doc CmdWidget title {
#CmdWidget
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# CmdWidget creates a window in which Tcl commands can be typed.
# The command will be executed when the Enter key is pressed
# with the cursor positioned at the end of the command currently 
# being edited, and the command is complete Tcl command.
# The output of the commands will be redirected to the cmd widget.
# Previous commands can be gotten and edited before execution using
# Alt-Up (default keypress, can be changed).
#<p>
# <b>Classy::cmd</b><br>
# is a convience function that pops up a toplevel containing a 
# CmdWidget with a scroll bar.
#}
#doc {CmdWidget options} h2 {
#	CmdWidget specific options
#}
#doc {CmdWidget command} h2 {
#	CmdWidget specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::CmdWidget {} {}
proc CmdWidget {} {}
}
catch {Classy::CmdWidget destroy}

source [file join $::class::dir widgets CmdWidgetbnd.tcl]
auto_load varsubst
# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::CmdWidget
Classy::export CmdWidget {}

Classy::CmdWidget classmethod init {args} {
	setprivate $object w [super text $object -setgrid true]
	$object tag configure prompt -foreground blue
	bindtags $object [list $object Classy::CmdWidget . all]

	# REM Initialise options and variables
	# ------------------------------------
	private $object curfile reopenlist findwhat undobuffer redobuffer
	private $object cmdnum options
	set cmdnum 1
	set curfile {}
	set reopenlist {}
	set findwhat {}
	set undobuffer {}
	set redobuffer {}
	private $object marknr curmarker prevmarker
	set marknr 0
	set curmarker {}
	set prevmarker {}

	# REM Create bindings
	# -------------------
#	d&d__addreceiver $object files [varsubst object {
#		foreach file $files {
#			set f [open $file r]
#			$object insert current [read $f]
#			close $f
#		}
#	}]
#	d&d__addreceiver $object mem_indirect [varsubst object {
#		* {$object insert current [eval $getdata]}
#	}]

	# REM Configure initial arguments
	# -------------------------------
	$object connect [tk appname]
	if {"$args" != ""} {eval $object configure $args}
	$object insert end [subst $options(-prompt)] prompt
	$object mark set cmdstart "end-1c"
	$object mark gravity cmdstart left
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::CmdWidget chainoptions {$object}

#doc {CmdWidget options -prompt} option {-prompt prompt Prompt} descr {
# This is the prompt that wil be displayed. It is run through subst
# first, so you can use something like {[pwd] % } as prompt.
#}
Classy::CmdWidget addoption -prompt {prompt Prompt {[pwd] % }} {}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::CmdWidget chainallmethods {$object} text

#doc {CmdWidget command do} cmd {
#pathname do 
#} descr {
# execute the command currently being edited
#}
Classy::CmdWidget method do {} {
	private $object w options
	private $object connection cmdnum histnum
	set cmd [$object get cmdstart "end-1c"]
#	$w insert insert "\n"
	if {([$object compare insert >= "end-1c"]==1)&&([info complete $cmd]==1)} {
		$object mark set cmdstart$cmdnum cmdstart
		$object mark set cmdend$cmdnum "end-2c"
		catch [list send $connection $cmd] result
		if {"$result"!=""} {
			$w insert end $result
			$w insert end "\n"
		}
		$object insert end [subst $options(-prompt)] prompt
		incr cmdnum
		set histnum $cmdnum
		$object mark set cmdstart "end-1c"
		$object mark gravity cmdstart left
	}
	$w see insert
}

#doc {CmdWidget command display} cmd {
#pathname display args
#} descr {
# insert args into CmdWidget
#}
Classy::CmdWidget method display {args} {
	private $object w
	if {"$args"!=""} {
		foreach arg $args {
			$w insert end $arg
		}
		$w see insert
	}
}

#doc {CmdWidget command complete} cmd {
#pathname complete ?what?
#} descr {
# If what (default is file) is set to
#<dl>
#<dt>file<dd>try to complete the word at the cursor to a complete available file
#<dt>var<dd>try to complete the word at the cursor to a complete available variable
#<dt>cmd<dd>try to complete the word at the cursor to a complete available command
#</dl>
#}
Classy::CmdWidget method complete {{what file}} {
	private $object w connection
	set start [$object search -backwards -exact " " insert 1.0]
	set start [$object get "$start+1c" insert]
	if {"$what"=="var"} {
		set flist [send $connection info vars $start*]
	} elseif {"$what"=="cmd"} {
		set flist [send $connection info commands $start*]
	} else {
		set flist [glob $start*]
	}
	if {[llength $flist]==0} {
		return
	} elseif {[llength $flist]==1} {
#		set full $list
		set completion [string range $flist [string length $start] end]
		$w insert insert $completion
	} else {
		set list [lregsub "^$start" $flist {}]
		set completion ""
		while {"[lindex $list 0]"!=""} {
			set flet [lmanip remdup [lmanip extract $list {^(.)}]]
			if {[llength $flet]!=1} {
				break
			}
			append completion $flet
			set list [lregsub "^." $list {}]
		}
		if {"$completion"==""} {
			public $object prompt
			set command [$object get cmdstart "end-1c"]
			$w insert end "\n"
			$w insert end "$flist\n"
			eval $w insert end $prompt prompt
			$object mark set cmdstart "end-1c"
			$object mark gravity cmdstart left
			$w insert end $command
		} else {	
			$w insert insert $completion
		}
	}
	$object see insert
}


Classy::CmdWidget method textinsert {s} {
	private $object w
	if {($s == "") || ([$w cget -state] == "disabled")} {
	return
	}
#	catch {
#	if {[$w compare sel.first <= insert]
#		&& [$w compare sel.last >= insert]} {
#		$object delete sel.first sel.last
#	}
#	}
	$object insert insert $s
	$w see insert
}

#doc {CmdWidget command insert} cmd {
#pathname insert index chars ?tags?
#} descr {
#}
Classy::CmdWidget method insert {index chars args} {
	private $object w undobuffer redobuffer textchanged
	set redobuffer ""
	if {([$w cget -state] == "disabled") || ("$chars"=="")} return
	set ins [$w index insert]
	set index [$w index $index]
	$w mark set insert $index
	eval {$w insert insert $chars} $args
	lappend undobuffer [list Insert $chars $index [$w index insert]]
	$w mark set insert "$ins + [string length $chars] c"
	set chars [string trimright $chars " "]
	if {"[string index $chars [expr [string length $chars]-1]]"=="\n"} {
		$object do
	}
	$w see insert
}

#doc {CmdWidget command delete} cmd {
#pathname delete ?index? ?index?
#} descr {
#}
Classy::CmdWidget method delete {args} {
	private $object w undobuffer redobuffer
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
	lappend undobuffer [list Delete [$w get $index1 $index2] $index1 $index2]
	$w delete $index1 $index2
}

#doc {CmdWidget command undo} cmd {
#pathname undo 
#} descr {
#}
Classy::CmdWidget method undo {} {
	private $object w undobuffer redobuffer
	if {$undobuffer == ""} {
		error "Nothing to undo"
	}
	set undo [lpop undobuffer]
	set index1 [lindex $undo 2]
	$w mark set insert $index1
	$w see $index1
	switch [lindex $undo 0] {
		Insert {
			$w delete $index1 [lindex $undo 3]
		}
		Delete {
			$w insert $index1 [lindex $undo 1]
		}
	}
	lappend redobuffer $undo
}

#doc {CmdWidget command redo} cmd {
#pathname redo 
#} descr {
#}
Classy::CmdWidget method redo {} {
	private $object w undobuffer redobuffer
	if {$redobuffer == ""} {
		error "Nothing to redo"
	}
	set redo [lpop redobuffer]
	set index1 [lindex $redo 2]
	$w mark set insert $index1
	$w see $index1
	switch [lindex $redo 0] {
		Delete {
			$w delete $index1 [lindex $redo 3]
		}
		Insert {
			$w insert $index1 [lindex $redo 1]
		}
	}
	lappend undobuffer $redo
}

#doc {CmdWidget command clearundo} cmd {
#pathname clearundo 
#} descr {
#}
Classy::CmdWidget method clearundo {} {
	private $object undobuffer
	set undobuffer ""
}

#doc {CmdWidget command cut} cmd {
#pathname cut 
#} descr {
#}
Classy::CmdWidget method cut {} {
	clipboard clear -displayof $object			  
	catch {									
		clipboard append -displayof $object [$object get sel.first sel.last]
		$object delete sel.first sel.last
	}
}

#doc {CmdWidget command copy} cmd {
#pathname copy 
#} descr {
#}
Classy::CmdWidget method copy {} {
	clipboard clear -displayof $object			  
	catch {									
		clipboard append -displayof $object [$object get sel.first sel.last]
	}										  
}

#doc {CmdWidget command paste} cmd {
#pathname paste 
#} descr {
#}
Classy::CmdWidget method paste {} {
	catch {
		$object insert insert [selection get -displayof $object \
				-selection CLIPBOARD]
	}
}

#doc {CmdWidget command clear} cmd {
#pathname clear 
#} descr {
# remove command being edited
#}
Classy::CmdWidget method clear {} {
	$object delete cmdstart end
}

#doc {CmdWidget command historyup} cmd {
#pathname historyup 
#} descr {
#}
Classy::CmdWidget method historyup {} {
	private $object histnum
	if {$histnum == 1} {return}
	incr histnum -1
	$object delete cmdstart end
	$object insert end [$object get cmdstart$histnum cmdend$histnum]
}

#doc {CmdWidget command historydown} cmd {
#pathname historydown 
#} descr {
#}
Classy::CmdWidget method historydown {} {
	private $object cmdnum histnum
	$object delete cmdstart end
	if {$histnum < $cmdnum} {incr histnum}
	if {$histnum == $cmdnum} {return}
	$object insert end [$object get cmdstart$histnum cmdend$histnum]
}

#doc {CmdWidget command save} cmd {
#pathname save file
#} descr {
# save the contents of the CmdWidget to file
#}
Classy::CmdWidget method save {file} {
	set temp [$object get 1.0 end]
	set f [open $file w]
	puts -nonewline $f $temp
	close $f
}

#doc {CmdWidget command select} cmd {
#pathname select mode
#} descr {
#}
Classy::CmdWidget method select {mode} {
	private $object w
	global tkPriv
	switch $mode {
		left {
			Classy::CmdWidget_KeySelect $object [$w index {insert - 1c}]
		}
		right {
			Classy::CmdWidget_KeySelect $object [$w index {insert + 1c}]
		}
		up {
			Classy::CmdWidget_KeySelect $object [Classy::CmdWidget_UpDownLine $object -1]
		}
		down {
			Classy::CmdWidget_KeySelect $object [Classy::CmdWidget_UpDownLine $object 1]
		}
		wordstart {
			Classy::CmdWidget_KeySelect $object [$w index {insert - 1c wordstart}]
		}
		wordend {
			Classy::CmdWidget_KeySelect $object [$w index {insert wordend}]
		}
		uppara {
			Classy::CmdWidget_KeySelect $object [Classy::CmdWidget_PrevPara $object insert]
		}
		downpara {
			Classy::CmdWidget_KeySelect $object [Classy::CmdWidget_NextPara $object insert]
		}
		pageup {
			Classy::CmdWidget_KeySelect $object [Classy::CmdWidget_ScrollPages $object -1]
		}
		pagedown {
			Classy::CmdWidget_KeySelect $object [Classy::CmdWidget_ScrollPages $object 1]
		}
		linestart {
			if [$w compare {insert linestart} >= cmdstart] {
				Classy::CmdWidget_KeySelect $object {insert linestart}
			} else {
				Classy::CmdWidget_KeySelect $object cmdstart
			}
		}
		lineend {
			Classy::CmdWidget_KeySelect $object {insert lineend}
		}
		textstart {
			Classy::CmdWidget_KeySelect $object cmdstart
		}
		textend {
			Classy::CmdWidget_KeySelect $object {end - 1 char}
		}
		start {
			 $object mark set anchor insert
		}
		end {
			set tkPriv(selectMode) char
			Classy::CmdWidget_KeyExtend $object insert
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

#doc {CmdWidget command move} cmd {
#pathname move mode
#} descr {
#}
Classy::CmdWidget method move {mode} {
	private $object w
	global tkPriv
	switch $mode {
		left {
			Classy::CmdWidget_SetCursor $object [$w index {insert - 1c}]
		}
		right {
			Classy::CmdWidget_SetCursor $object [$w index {insert + 1c}]
		}
		up {
			Classy::CmdWidget_SetCursor $object [Classy::CmdWidget_UpDownLine $object -1]
		}
		down {
			Classy::CmdWidget_SetCursor $object [Classy::CmdWidget_UpDownLine $object 1]
		}
		wordstart {
			Classy::CmdWidget_SetCursor $object [$w index {insert - 1c wordstart}]
		}
		wordend {
			Classy::CmdWidget_SetCursor $object [$w index {insert wordend}]
		}
		uppara {
			Classy::CmdWidget_SetCursor $object [Classy::CmdWidget_PrevPara $object insert]
		}
		downpara {
			Classy::CmdWidget_SetCursor $object [Classy::CmdWidget_NextPara $object insert]
		}
		pageup {
			Classy::CmdWidget_SetCursor $object [Classy::CmdWidget_ScrollPages $object -1]
		}
		pagedown {
			Classy::CmdWidget_SetCursor $object [Classy::CmdWidget_ScrollPages $object 1]
		}
		linestart {
			if [$w compare {insert linestart} >= cmdstart] {
				Classy::CmdWidget_SetCursor $object {insert linestart}
			} else {
				Classy::CmdWidget_SetCursor $object cmdstart
			}
		}
		lineend {
			Classy::CmdWidget_SetCursor $object {insert lineend}
		}
		textstart {
			Classy::CmdWidget_SetCursor $object cmdstart
		}
		textend {
			Classy::CmdWidget_SetCursor $object {end - 1 char}
		}
		start {
			 $object mark set anchor insert
		}
	}
}

#doc {CmdWidget command backspace} cmd {
#pathname backspace 
#} descr {
#}
Classy::CmdWidget method backspace {} {
	private $object w
	if [$w compare insert == cmdstart] {
	return
	}
#	if {[$object tag nextrange sel 1.0 end] != ""} {
#		$object delete sel.first sel.last
#	} elseif [$w compare insert != 1.0] {
		$object delete insert-1c
		$object see insert
#	}
}

#doc {CmdWidget command textdelete} cmd {
#pathname textdelete 
#} descr {
#}
Classy::CmdWidget method textdelete {} {
	if {[$object tag nextrange sel cmdstart end] != ""} {
		$object delete sel.first sel.last
	} elseif {[$object tag nextrange sel 1.0 end] == ""} {
		$object delete insert
		$object see insert
	}
}

#doc {CmdWidget command position} cmd {
#pathname position index
#} descr {
#}
Classy::CmdWidget method position {index} {
	private $object w
	global tkPriv
	regexp {(.*)\.(.*)} $index temp y x
	set tkPriv(selectMode) char
	set tkPriv(mouseMoved) 0
	set tkPriv(pressX) $x
	if [$object compare $index > cmdstart] {
		$w mark set insert $index
	}
#	if [$object compare $index <= cmdstart] {
#		$w mark set insert cmdstart
#	}
	$w mark set anchor $index
	if {[$w cget -state] == "normal"} {focus $object}
}

# The following procedures are mainly patches from the original tk sources
# ---------------------------------------------------------------------------
# Classy::CmdWidget_SetCursor
# Move the insertion cursor to a given position in a text.  Also
# clears the selection, if there is one in the text, and makes sure
# that the insertion cursor is visible.  Also, don't let the insertion
# cursor appear on the dummy last line of the text.
#
# Arguments:
# w -		The text window.
# pos -		The desired new position for the cursor in the window.

proc Classy::CmdWidget_SetCursor {w pos} {
	global tkPriv

	set w ::class::Tk_$w
	if [$w compare $pos < cmdstart] {
	return
	}
	if [$w compare $pos == end] {
	set pos {end - 1 chars}
	}
	$w tag remove sel 1.0 end
	$w mark set insert $pos
	$w see insert
}

# Classy::CmdWidget_KeySelect
# This procedure is invoked when stroking out selections using the
# keyboard.  It moves the cursor to a new position, then extends
# the selection to that position.
#
# Arguments:
# w -		The text window.
# new -		A new position for the insertion cursor (the cursor hasn't
#		actually been moved to this position yet).

proc Classy::CmdWidget_KeySelect {w new} {
	global tkPriv

	set w ::class::Tk_$w
	if [$w compare $new < cmdstart] {
	return
	}
	if {[$w tag nextrange sel 1.0 end] == ""} {
	if [$w compare $new < insert] {
		$w tag add sel $new insert
	} else {
		$w tag add sel insert $new
	}
	$w mark set anchor insert
	} else {
	if [$w compare $new < anchor] {
		set first $new
		set last anchor
	} else {
		set first anchor
		set last $new
	}
	$w tag remove sel 1.0 $first
	$w tag add sel $first $last
	$w tag remove sel $last end
	}
	$w mark set insert $new
	$w see insert
	update idletasks
}

# Classy::CmdWidget_UpDownLine --
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

proc Classy::CmdWidget_UpDownLine {w n} {
	global tkPriv

	set w ::class::Tk_$w
	set i [$w index insert]
	scan $i "%d.%d" line char
	if {[string compare $tkPriv(prevPos) $i] != 0} {
	set tkPriv(char) $char
	}
	set new [$w index [expr $line + $n].$tkPriv(char)]
	if {[$w compare $new == end] || [$w compare $new == "insert linestart"]} {
	set new $i
	}
	set tkPriv(prevPos) $new
	return $new
}

# Classy::CmdWidget_PrevPara --
# Returns the index of the beginning of the paragraph just before a given
# position in the text (the beginning of a paragraph is the first non-blank
# character after a blank line).
#
# Arguments:
# w -		The text window in which the cursor is to move.
# pos -		Position at which to start search.

proc Classy::CmdWidget_PrevPara {w pos} {
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

# Classy::CmdWidget_NextPara --
# Returns the index of the beginning of the paragraph just after a given
# position in the text (the beginning of a paragraph is the first non-blank
# character after a blank line).
#
# Arguments:
# w -		The text window in which the cursor is to move.
# start -	Position at which to start search.

proc Classy::CmdWidget_NextPara {w start} {
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

# Classy::CmdWidget_ScrollPages --
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

proc Classy::CmdWidget_ScrollPages {w count} {
	set bbox [$w bbox insert]
	$w yview scroll $count pages
	if {$bbox == ""} {
	return [$w index @[expr [winfo height $w]/2],0]
	}
	return [$w index @[lindex $bbox 0],[lindex $bbox 1]]
}

# Classy::CmdWidget_KeyExtend --
# This procedure handles extending the selection from the keyboard,
# where the point to extend to is really the boundary between two
# characters rather than a particular character.
#
# Arguments:
# w -		The text window.
# index -	The point to which the selection is to be extended.

proc Classy::CmdWidget_KeyExtend {w index} {
	global tkPriv

	set w ::class::Tk_$w
	set cur [$w index $index]
	if [catch {$w index anchor}] {
	$w mark set anchor $cur
	}
	set anchor [$w index anchor]
	if [$w compare $cur < anchor] {
	set first $cur
	set last anchor
	} else {
	set first anchor
	set last $cur
	}
	$w tag remove sel 0.0 $first
	$w tag add sel $first $last
	$w tag remove sel $last end
}

#doc {CmdWidget command connect} cmd {
#pathname connect ?name?
#} descr {
# connect to a different Tk application with name name using send.
# if name is not given, returns the current connected application
#}
Classy::CmdWidget method connect {args} {
	private $object connection interactive
	global Classy__unknowntempf
	set arg [lindex $args 0]
	if {"$arg"==""} {
		return $connection
	}
	set list [winfo interps]
	if {"$list"!=""} {
		if {[lsearch -exact $list $arg]==-1} {
			error "Interpreter \"$arg\" not present"
		}
	}
	if [info exists connection] {
		catch {
			send $connection {
				if {"[info commands Classy__keepunknown]"!=""} {
					rename unknown {}
					rename Classy__keepunknown unknown
				}
			}
			send $connection {
				if {"[info commands Classy__keepputs]"!=""} {
					rename puts {}
					rename Classy__keepputs puts
				}
			}
			send $connection set tcl_interactive $interactive
		}
	}
	set connection $arg
	send $connection {catch {rename Classy__keepunknown {}}}
	send $connection rename unknown Classy__keepunknown
	send $connection [list proc unknown args [varsubst Classy__unknowntempf [info body Classy__unknown]]]
	set puts [info body Classy__puts]
	regsub {\$source} $puts [tk appname] puts
	regsub {\$cmdwidget} $puts $object puts
	send $connection {
		if {"[info commands Classy__keepputs]"==""} {
			rename puts Classy__keepputs
		}
	}
	send $connection [list proc puts args $puts]
	set interactive [send $connection set tcl_interactive]
	send $connection set tcl_interactive 1
}

if ![info exists Classy__unknowntempf] {
	set Classy__unknowntempf [tempfile]
}

proc Classy__unknown args {
	global auto_noexec auto_noload env unknown_pending tcl_interactive
	global errorCode errorInfo
	# Save the values of errorCode and errorInfo variables, since they
	# may get modified if caught errors occur below.  The variables will
	# be restored just before re-executing the missing command.

	set savedErrorCode $errorCode
	set savedErrorInfo $errorInfo
	set name [lindex $args 0]
	if ![info exists auto_noload] {
	#
	# Make sure we're not trying to load the same proc twice.
	#
	if [info exists unknown_pending($name)] {
		return -code error "self-referential recursion in \"unknown\" for command \"$name\"";
	}
	set unknown_pending($name) pending;
	set ret [catch {auto_load $name} msg]
	unset unknown_pending($name);
	if {$ret != 0} {
		return -code $ret -errorcode $errorCode \
		"error while autoloading \"$name\": $msg"
	}
	if ![array size unknown_pending] {
		unset unknown_pending
	}
	if $msg {
		set errorCode $savedErrorCode
		set errorInfo $savedErrorInfo
		set code [catch {uplevel $args} msg]
		if {$code ==  1} {
		#
		# Strip the last five lines off the error stack (they're
		# from the "uplevel" command).
		#

		set new [split $errorInfo \n]
		set new [join [lrange $new 0 [expr [llength $new] - 6]] \n]
		return -code error -errorcode $errorCode \
			-errorinfo $new $msg
		} else {
		return -code $code $msg
		}
	}
	}
	if {([info level] == 1) && ([info script] == "") \
		&& [info exists tcl_interactive] && $tcl_interactive} {
	if ![info exists auto_noexec] {
		set new [auto_execok $name]
		if {$new != ""} {
		set errorCode $savedErrorCode
		set errorInfo $savedErrorInfo
# patched
#		return [uplevel exec >&@stdout <@stdin $new [lrange $args 1 end]]
# patch start
		set res1 [uplevel exec >&$Classy__unknowntempf <@stdin $new [lrange $args 1 end]]
		set f [open $Classy__unknowntempf]
		set res [read $f]
		close $f
		return "$res$res1"
# patch end
		}
	}
	set errorCode $savedErrorCode
	set errorInfo $savedErrorInfo
	if {$name == "!!"} {
#		return [uplevel {history redo}]
		return -code error "!! is disabled until history is fixed in Tcl8.0"
	}
	if [regexp {^!(.+)$} $name dummy event] {
		return [uplevel [list history redo $event]]
	}
	if [regexp {^\^([^^]*)\^([^^]*)\^?$} $name dummy old new] {
		return [uplevel [list history substitute $old $new]]
	}
	set cmds [info commands $name*]
	if {[llength $cmds] == 1} {
		return [uplevel [lreplace $args 0 0 $cmds]]
	}
	if {[llength $cmds] != 0} {
		if {$name == ""} {
		return -code error "empty command name \"\""
		} else {
		return -code error \
			"ambiguous command name \"$name\": [lsort $cmds]"
		}
	}
	}
	return -code error "invalid command name \"$name\""
}

proc Classy__puts {args} {
	set string [lindex $args end]
	set len [llength $args]
	if {$len==3} {
		set temp [lindex $args 0]
		set ch [lindex $args 1]
		if {"$temp"=="-nonewline"} {
			set newl 1
		} else {
			if {"$string"=="nonewline"} {
				set newl 1
				set ch [lindex $args 0]
				set string [lindex $args 1]
			} else {
				error "Unknown option \"$temp\" (puts $args)"
			}
		}
	} elseif {$len==2} {
		set temp [lindex $args 0]
		if {"$temp"!="-nonewline"} {
			set ch $temp
		} else {
			set ch stdout
			set newl 1
		}
	} else {
		set ch stdout
	}

	if {"$ch"=="stdout"} {
		if ![info exists newl] {append string "\n"}
		send $source [list $cmdwidget display $string]
		return {}
	} else {
		return [eval Classy__keepputs $args]
	}
}

proc Classy::cmd {args} {
	set w .classy__cmd
	set num 1
	while {[winfo exists $w$num] == 1} {incr num}
	set w $w$num
	catch {destroy $w}
	toplevel $w -bd 0 -highlightthickness 0
	wm protocol $w WM_DELETE_WINDOW "destroy $w"
	frame $w.frame
	eval {Classy::CmdWidget $w.edit \
		-yscrollcommand [list $w.vbar set]} $args
	scrollbar $w.vbar -orient vertical -command "$w.edit yview"

	if {"[option get $w scrollSide ScrollSide]"=="left"} {
		grid $w.vbar $w.edit -sticky nswe
		grid columnconfigure $w 0 -weight 0
		grid columnconfigure $w 1 -weight 1
		grid rowconfigure $w 0 -weight 1
	} else {
		grid $w.edit $w.vbar -sticky nswe
		grid columnconfigure $w 0 -weight 1
		grid columnconfigure $w 1 -weight 0
		grid rowconfigure $w 0 -weight 1
	}
	wm geometry $w =80x25
	return $w
}
