#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Help
# ----------------------------------------------------------------------
#doc Help title {
#Help
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
#}
#doc {Help options} h2 {
#	Help specific options
#}
#doc {Help command} h2 {
#	Help specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Help {} {}
proc Help {} {}
}
catch {Classy::Help destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Help
Classy::export Help {}

Classy::Help classmethod init {args} {
	super toplevel
	set w $object
	Classy::HTML $w.html -yscrollcommand "$w.vbar set" \
		-state disabled -wrap word -cursor hand2 \
		-width 70 -height 28 -relief sunken
	scrollbar $w.vbar -orient vertical -command "$w.html yview"
	Classy::DynaMenu makemenu Classy::Help $w.menu $object.html Classy::Help
	bindtags $object "Classy::Help [bindtags $object]"
	pack $w.vbar -side right -fill y
	pack $w.html -expand yes -fill both
	private $object curfile history
	set curfile ""
	set history {}
	private $object contentstag
	set contentstag h2

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::Help chainoptions {$object.html}
Classy::Help chainoption -font {$object.html} -font
Classy::Help addoption -general {general General {}} {
	-general {
		$object.menu.general delete 1 end
		foreach {label file} $value {
			$object.menu.general addaction $label "$object gethelp $file"
		}
	}
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Help chainallmethods {$object.html} HTML

Classy::Help method historymenu {} {
	private $object history
	set w $object.history
	Classy::SelectDialog $w -title "Reopen list" \
		-command "$object load \[$w get\]" \
		-deletecommand "$object historyforget \[$w get\]"
	$w fill $history
}

Classy::Help method historyforget {item} {
	private $object history
	set history [lremove $history $item]
}

Classy::Help method contents {tag} {
	private $object contentstag
	set contentstag $tag
	if {"$tag"==""} {return}
	set current 1.0
	set w $object.html
	while 1 {
		set pos [$w tag nextrange $tag $current end]
		if {"$pos"==""} {break}
		set begin [lindex $pos 0]
		set end [lindex $pos 1]
		$object.menu.contents.menu add command -label "[$w get $begin $end]" \
			-command "$w yview [$w index $begin]"
		set current [$w index $end]
	}
}

Classy::Help method load {file args} {
	private $object curfile history

	set w $object.html
	# history
	if {("$args"=="")&&("$curfile"!="")} {
		set histfile $curfile#[lindex [$w yview] 0]
		if {"[lindex $history end]"!="$histfile"} {
			lappend history $histfile
			if {[llength $history]>40} {
				lpop history 0
			}
		}
	}

	if {[$object.menu.contents.menu index end]>1} {
		$object.menu.contents.menu delete 2 end
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
			foreach dir $::Classy::help_path {
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

Classy::Help method search {what} {
	set string [$object.menu.entry get]
	if {"$string"==""} {return}
	switch $what {
		file {$object load $string}
		word {
			set w $object.html
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
			set w $object.html
			set found ""
			set files ""
			foreach dir $::Classy::help_path {
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

Classy::Help method edit {} {
	private $object curfile
	edit $curfile
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

laddnew ::Classy::help_path [file join $class::dir help]

