#
# ####  #####  ####   #### 
# #   # #     #    # # 
# ####  ####  #    #  #### 
# #     #     #    #      # 
# #     #####  ####   ####  Peter De Rijk
#
# ClassyHelp
# ----------------------------------------------------------------------

Classyinherit ClassyHelp Classy::Dialog
Classy::DynaMenu define Help {
menu
	action Back "Back" {%W back}
	action Forward "Forward" {%W forth}
	action Reload "Reload" {%W reload}
	action History "History" "%W historymenu"
	action Edit "Edit" {%W edit}
	action Close "Close" {[winfo toplevel %W] invoke close}
	menu contents "Contents"
	menu general "General"
	menu search "Search"
menu contents
	action TopHelp "Top" "%W.options.text see 1.0"
menu search
	action HelpWord "in helptext" "%W search word"
	action HelpGrep "through all helpfiles" "%W search grep"
	action HelpFile "a named Helpfile" "%W search file"
menu general
	action HelpHelp "Help on Help" "%W load help"
}


#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Help
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Help {} {}
proc Help {} {}
}
catch {Classy::Help destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Help
Classy::export Help {}

Help classmethod init {args} {
	Classybuild $object ClassyHelp
	Classy::Dialog $object -resize {5 5}
	global Classydir
	set w $object.options
	ClassyText $w.text -yscrollcommand "$w.vbar set" \
		-state disabled -wrap word -cursor hand2 \
		-width 70 -height 28 -relief sunken
	scrollbar $w.vbar -orient vertical -command "$w.text yview"
	Classy::DynaMenu maketop Help $w.menu $object NotUsed
	pack $w.menu -side top -fill x
	pack $w.vbar -side right -fill y
	pack $w.text -expand yes -fill both
	ClassyHTMLActioncmd $w.text "$object load"
	Classy::Entry $w.menu.entry -textvariable help_entry -label "" \
		-command "$object search word" -default help_entry
	place $w.menu.entry -x 0 -y 0
#	$object add back "Back" "$object back"
#	$object add forth "Forth" "$object forth"
#	$object add edit "Edit" "$object edit"
#	$object add reload "Reload" "$object reload"
	Classycreateobject $object ClassyHelp

	# REM Initialise options and variables
	# ------------------------------------
	Classyaddoptions $object -general {}
	Classychainoption $object -font $object.options.text -font
	Classyoptionactions $object {
		-general {
			getoptions $class $object -general
			$object.options.menu.general delete 1 end
			foreach {label file} $general {
			$object.options.menu.general addaction $label "$object load $file"
			}
		}
	}

	private $object curfile history redo
	set curfile ""
	set history {}
	set redo {}
	private $object contentstag
	set contentstag h2

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Help chainallmethods {$object} widget

Help method back {} {
	private $object curfile history redo
	if {[llength $history]>0} {
		lappend redo $curfile#[lindex [$object.options.text yview] 0]
		$object load [lpop history] history
	}
}

Help method forth {} {
	private $object curfile history redo
	if {"$redo"!=""} {
		lappend history $curfile#[lindex [$object.options.text yview] 0]
		$object load [lpop redo] history
	}
}

Help method historymenu {} {
	private $object history
	set w $object.history
	Classy::SelectDialog $w -title "Reopen list" \
		-command "$object load \[$w get\]" \
		-deletecommand "$object historyforget \[$w get\]"
	$w fill $history
}

Help method historyforget {item} {
	private $object history
	set history [lremove $history $item]
}

Help method contents {tag} {
	private $object contentstag
	set contentstag $tag
	if {"$tag"==""} {return}
	set current 1.0
	set w $object.options.text
	while 1 {
		set pos [$w tag nextrange $tag $current end]
		if {"$pos"==""} {break}
		set begin [lindex $pos 0]
		set end [lindex $pos 1]
		$object.options.menu.contents.menu add command -label "[$w get $begin $end]" \
			-command "$w yview [$w index $begin]"
		set current [$w index $end]
	}
}

Help method load {file args} {
	global help_path
	private $object curfile history redo

	set w $object.options.text
	# history
	if {("$args"=="")&&("$curfile"!="")} {
		set histfile $curfile#[lindex [$w yview] 0]
		if {"[lindex $history end]"!="$histfile"} {
			lappend history $histfile
			if {[llength $history]>40} {
				lpop history 0
			}
		}
		set redo ""
	}

	if {[$object.options.menu.contents.menu index end]>1} {
		$object.options.menu.contents.menu delete 2 end
	}
	$w configure -state normal
	if [catch {set URL [ClassyHTMLload $w $file]}] {
		$w configure -state disabled
		if [regexp {^([^#]+)#(.+)$} $file temp file mark] {
			set mark $mark
		} else {
			set mark 0
		}
		if {"[file extension $file]"==""} {
			set file $file.html
		}
		if {"[file pathtype $file]"=="absolute"} {
			set load $file
		} else {
			foreach dir $help_path {
				set load [file join $dir $file]
				if [file exists $load] {
					break
				}
			}
		}
		if ![file exists $load] {error "Sorry, but there is no help for this subject yet. ($file)"}
	
		$w configure -state normal
		set URL [ClassyHTMLload $w $load#$mark]
		wm title $object $load
	}
	regexp {^([a-z]+)://([^/]+)(/?.*)} $URL temp service host curfile
	$w configure -state disabled

	private $object contentstag
	$object contents $contentstag
}

Help method search {what} {
	set string [$object.options.menu.entry get]
	if {"$string"==""} {return}
	switch $what {
		file {$object load $string}
		word {
			set w $object.options.text
			$w tag configure found -background red
			$w tag remove found 1.0 end
			set current 1.0
			while 1 {
				set pos [$w search -exact -nocase -count len $string $current end]
				if {"$pos"==""} {break}
				set current [$w index "$pos + $len c"]
				$w tag add found $pos $current
			}
		}
		grep {
			set w $object.options.text
			global help_path
			set found ""
			set files ""
			foreach dir $help_path {
				if [info exists list] {unset list}
				foreach temp [glob [file join $dir *]] {
					if ![file isdir $temp] {lappend list $temp}
				}
				set found [ffind -regexp -- $list $string]
				eval lappend files $found
			}
			if {"$files"==""} {tkerror "None found";return}
			set html "Help files containing \"$string\":<p>"
			foreach file $files {
				append html "<a href=\"[file tail $file]\">[file tail $file]</a><br>"
			}
			$w configure -state normal
			ClassyHTMLload $w "" $html
			$w configure -state disabled
		}
	}
}

Help method edit {} {
	private $object curfile
	edit $curfile
}

Help method reload {} {
	private $object curfile
	set w $object.options.text
	$w configure -state normal
	ClassyHTMLload $w $curfile force
	$w configure -state disabled
}

proc newhelp {{subject {help}}} {
	set w .peos__help
	set num 1
	while {[winfo exists $w$num] == 1} {incr num}
	set w $w$num
	ClassyHelp $w
	$w load $subject
}

proc help {{subject {help}}} {
	if ![winfo exists .peos__help] {
		ClassyHelp .peos__help -cache 1
	} else {
		.peos__help place
	}
	if ![winfo ismapped .peos__help] {wm deiconify .peos__help}
	raise .peos__help
	.peos__help place
	.peos__help load $subject
}

laddnew help_path [file join $Classydir help]

