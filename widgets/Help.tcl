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
proc help {} {}
}

laddnew ::Classy::help_path [file join $class::dir help]
laddnew ::Classy::help_path [file join $Extral::dir docs]

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Toplevel subclass Classy::Help
Classy::export Help {}

Classy::Help classmethod init {args} {
	super
	Classy::HTML $object.html -yscrollcommand "$object.vbar set" \
		-state disabled -wrap word -cursor hand2 \
		-width 70 -height 28 -relief sunken \
		-errorcommand [list $object retry]
	$object.html bindlink <<Adjust>> {newhelp [%W linkat %x %y]}
	scrollbar $object.vbar -orient vertical -command "$object.html yview"
	Classy::DynaMenu attachmainmenu Classy::Help $object
	Classy::DynaTool $object.tool -type Classy::Help
	$object.tool cmdw $object
	pack $object.tool -side top -fill x
	if {"[option get $object scrollSide ScrollSide]" == "right"} {
		pack $object.vbar -side right -fill y
	} else {
		pack $object.vbar -side left -fill y
	}
	pack $object.html -expand yes -fill both
	private $object curfile history
	set curfile ""
	set history {}

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

Classy::Help private generalmenu {
	action HelpHelp "Help on Help" {%W gethelp classy_help}
	action HelpHelp "Tcl/Tk" {%W gethelp tcltk}
	action HelpHelp "ClassyTcl" {%W gethelp ClassyTcl}
	action HelpHelp "Extral" {%W gethelp Extral}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::Help chainoptions {$object.html}
Classy::Help chainoption -background {$object} -background {$object.html} -background
Classy::Help chainoption -highlightbackground {$object} -highlightbackground {$object.html} -highlightbackground
Classy::Help chainoption -highlightcolor {$object} -highlightcolor {$object.html} -highlightcolor

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
	if {"[file pathtype $name]" == "absolute"} {
		set url file:$name
	} elseif {[regexp {^http:/|^file:/|^ftp:/} $name]} {
		set url $name
	} else {
		set i [llength $::Classy::help_path]
		incr i -1
		while {$i > -1} {
			set dir [lindex $::Classy::help_path $i]
			incr i -1
			if {"[file extension $name]" == ""} {
				set name $name.html
			}
			set file [file join $dir $name]
			if [file exists $file] break
		}
		if ![file exists $file] return
		set url file:$file
	}
	$object.html geturl $url
}

#doc {Help command save} cmd {
#pathname save filename ?text?
#} descr {
# save the current content. You can save as a plain text file by 
# specifying text as a parameter
#}
Classy::Help method save {filename {how {}}} {
	private $object.html html
	if {"$how" == "text"} {
		writefile $filename [[Classy::window $object.html] get 1.0 end]
	} else {
		writefile $filename $html
	}
}

Classy::Help method historymenu {} {
	set w $object.history
	Classy::SelectDialog $w -title "Reopen list" \
		-command "$object gethelp"
	$w fill [$object.html history]
}

Classy::Help method search {what string} {
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

Classy::Help method getcontentsmenu {} {
	set current 1.0
	set w $object.html
	set contentsmenu ""
	set c [split [$w get 1.0 end] "\n"]
	set poss [lfind $c ""]
	foreach pos $poss {
		incr pos
		set line [lindex $c $pos]
		set len [llength $line]
		if {($len > 0)&&($len < 6)} {
			append contentsmenu "\t[list action None "$line" "$w yview [expr {$pos+1}].0"]\n"
		}
	}
	set data "action TopHelp Top {%W see 1.0}\n$contentsmenu"
	return [list $data Classy::Help_contents]
}

Classy::Help method retry {url query result} {
	$object gethelp [file tail $url]
}

Classy::Help method getgeneralmenu {} {
	private $object generalmenu
	if [info exists generalmenu] {
		if {"$generalmenu" != ""} {
			set result $generalmenu
		} else {
			set result [getprivate $class generalmenu]
		}
	} else {
		set result [getprivate $class generalmenu]
	}
	return [list $result Classy::Help_general]
}

set ::Classy::helpfind word
proc Classy::findhelp {w} {
	Classy::Entry $w
	set p [winfo parent $w]
	$w configure -command [varsubst {w p} {
		[$p cmdw] search $::Classy::helpfind
	}]
}

proc Classy::newhelp {{subject {help}}} {
	set w .classy__.help
	set num 1
	while {[winfo exists $w$num] == 1} {incr num}
	set w $w$num
	Classy::Help $w
	$w gethelp $subject
}

proc Classy::help {{subject {classy_help}}} {
	if ![winfo exists .classy__.help] {
		Classy::Help .classy__.help
	}
	if ![winfo ismapped .classy__.help] {wm deiconify .classy__.help}
	raise .classy__.help
	.classy__.help gethelp $subject
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
