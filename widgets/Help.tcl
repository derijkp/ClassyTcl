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
# The help widget is a toplevel with a menu that displays HTML
# help files. It has all the options and methods of the 
# <a href="HTML.html">HTML widget</a>.
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

laddnew ::Classy::help_path [file join $class::dir help]

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Help
Classy::export Help {}

Classy::Help classmethod init {args} {
	set geom [Classy::Default get geometry $object]
	super toplevel
	if [regexp {^([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)} $geom temp w h prevx prevy] {
		set maxx [expr [winfo vrootwidth $object]-$w]
		set maxy [expr [winfo vrootheight $object]-$h]
		set x [expr [winfo pointerx .]-$w/2]
		set y [expr [winfo pointery .]-$h/2]
		if {$x>$maxx} {set x $maxx}
		if {$y>$maxy} {set y $maxy}
		if {$x<0} {set x 0}
		if {$y<0} {set y 0}
		set temp [expr [winfo pointerx .]-$prevx]
		if {($temp>0)&&($temp<$w)} {
			set temp [expr [winfo pointery .]-$prevy]
			if {($temp>0)&&($temp<$h)} {
				set keeppos 1
				set x $prevx
				set y $prevy
			}
		}
		wm geometry $object ${w}x${h}+$x+$y
	}
	set w $object
	wm protocol $w WM_DELETE_WINDOW "destroy $w"
	Classy::HTML $w.html -yscrollcommand "$w.vbar set" \
		-state disabled -wrap word -cursor hand2 \
		-width 70 -height 28 -relief sunken
	scrollbar $w.vbar -orient vertical -command "$w.html yview"
	Classy::DynaMenu makemenu Classy::Help $w.menu $object Classy::Help
	bindtags $object "Classy::Help [bindtags $object]"
	if {[option get $w showTool ShowTool]} {
		Classy::DynaTool maketool Classy::Help $w.tool $object
		pack $w.tool -side top -fill x
	}
	if {"[option get $w scrollSide ScrollSide]" == "right"} {
		pack $w.vbar -side right -fill y
	} else {
		pack $w.vbar -side left -fill y
	}
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
#doc {Help options -general} option {-general general General} descr {
#what is to be displayed in the General menu
#}
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

#doc {Help command gethelp} cmd {
#pathname gethelp name
#} descr {
# find a helpfile in the Classy::help_path and display it
#}
Classy::Help method gethelp {name} {
	foreach dir $::Classy::help_path {
		set file [file join $dir $name.html]
		if [file exists $file] {
			break
		}
	}
	if ![file exists $file] return
	$object.html geturl file:$file
}

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

Classy::Help method search {what string} {
#	set string [$object.menu.entry get]
	if {"$string"==""} {return}
	switch $what {
		file {$object gethelp $string}
		word {
			set w $object.html
			$w tag configure found -background red
			$w tag remove found 1.0 end
			set current 1.0
			while 1 {
				set pos [$w search -exact -nocase -count ::Classy::temp $string $current end]
				if {"$pos"==""} {break}
				set current [$w index "$pos + $::Classy::temp c"]
				$w tag add found $pos $current
			}
		}
		grep {
			set w $object.html
			set files ""
			foreach dir $::Classy::help_path {
				foreach file [glob [file join $dir *]] {
					if ![file isdir $file] {
						set c [readfile $file]
						if [regexp -- $string $c] {
							lappend files $file
						}
					}
				}
			}
			if {"$files"==""} {tkerror "None found";return}
			set html "Help files containing \"$string\":<p>"
			foreach file $files {
				append html "<a href=\"file:$file\">[file root [file tail $file]]</a><br>"
			}
			$object set $html
		}
	}
}

Classy::Help method edit {} {
	set url [$object.html cget -url]
	if [regexp {^file://localhost(.*)$} $url temp file] {
		edit $file
	}
}

Classy::Help method getcontents {} {
	set data "action TopHelp Top {%W see 1.0}\n"
	return $data
}


set ::Classy::helpfind word
proc Classy::findhelp {w} {
	Classy::Entry $w
	set p [winfo parent $w]
	$w configure -command [varsubst {w p} {
		[DynaTool cmdw $p] search $::Classy::helpfind [$w get]
	}]
}

proc Classy::newhelp {{subject {help}}} {
	set w .peos__help
	set num 1
	while {[winfo exists $w$num] == 1} {incr num}
	set w $w$num
	Classy::Help $w
	$w gethelp $subject
}

proc Classy::help {{subject {help}}} {
	if ![winfo exists .peos__help] {
		Classy::Help .peos__help
	}
	if ![winfo ismapped .peos__help] {wm deiconify .peos__help}
	raise .peos__help
	.peos__help gethelp $subject
}
Classy::export {help newhelp} {}

# ------------------------------------------------------------------
#  destructor
# ------------------------------------------------------------------

#doc {Help command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::Help method destroy {} {
	Classy::Default set geometry $object [winfo geometry $object]
}
