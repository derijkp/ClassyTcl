#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# tools
# ----------------------------------------------------------------------

proc ::Classy::todo {object args} {
	set exists [info exists ::Classy::__todolist__$object]
	laddnew ::Classy::__todolist__$object $args
	if !$exists {
		after idle ::Classy::handletodo $object
	}
}

proc ::Classy::canceltodo {object args} {
	if [info exists ::Classy::__todolist__$object] {
		set ::Classy::__todolist__$object [lremove [set ::Classy::__todolist__$object] $args]
	}
}

proc ::Classy::cleartodo {object} {
	if [info exists ::Classy::__todolist__$object] {
		unset ::Classy::__todolist__$object
		after cancel ::Classy::handletodo $object
	}
}

proc ::Classy::handletodo {object} {
	if [info exists ::Classy::__todolist__$object] {
		upvar ::Classy::__todolist__$object todolist
		if {"$todolist"!=""} {
			if {"[info commands $object]" == ""} {unset todolist;return}
			foreach todoitem $todolist {
				if [catch {eval $object $todoitem} result] {
					global errorInfo
					unset todolist
					return -code error -errorinfo $errorInfo $result
				}
			}
		}
		catch {unset todolist}
	}
}

# This function creates a conversion table used in the following function
foreach {key sym} "\
\[ bracketleft \] bracketright \( parenleft \) parenright \
, comma . period = equal < less > greater ? question \# numbersign" {
	lappend ::Classy::keytable(keys) $key
	lappend ::Classy::keytable(syms) $sym
}

proc Classy::shrink_accelerator {sym} {
	regsub -all {[<>]} $sym {} sym
	regsub -all {Key-} $sym {} sym
	set sym [lindex $sym 0]
	set pre ""
	set post $sym
	regexp {^(.*-)([^-]+)$} $sym temp pre post
	regsub {Control-} $pre {C-} pre
	regsub {Alt-} $pre {A-} pre

	if ![regexp {^[a-zA-Z0-9]$} $post] {
		set pos [lsearch -exact $::Classy::keytable(syms) $post]
		if {$pos!=-1} {
			set post [lindex $::Classy::keytable(keys) $pos]
		}
	}
	return "${pre}$post"
}

# Expands something like "C-A-g" to "Control-Alt-g"
proc Classy::expand_accelerator {sym} {
	if {"[string index $sym 1]" == "<"} return($sym)
	set pre ""
	set post $sym
	regexp {^(.*-)([^-]+)$} $sym temp pre post
	regsub {C-} $pre {Control-} pre
	regsub {A-} $pre {Alt-} pre

	if ![regexp {^[a-zA-Z0-9]$} $post] {
		set pos [lsearch -exact $::Classy::keytable(keys) $post]
		if {$pos!=-1} {
			set post [lindex $::Classy::keytable(syms) $pos]
		}
	}
	return "${pre}$post"
}

proc Classy::check {command} {
	if [catch {uplevel $command} result] {bgerror $result} else {return $result}
}

proc Classy::fullpath {file} {
	if {"[file pathtype $file]"=="absolute"} {
		return $file
	} else {
		return [file join [pwd] $file]
	}
}

#proc Classy::splitcomplete {data} {
#	set result ""
#	set current ""
#	foreach line [split $data "\n"] {
#		append current "\n" $line
#		if [info complete $current] {
#			lappend result $current
#			set current ""
#		}
#	}
#	return $result
#}

# Classy::parseopt arguments variable list ?remain?
# variable: name of array to set options in
# list: each element is of the form {options {possible values} default}
# remain: remaining options
proc Classy::parseopt {real variable possible {remain {}}} {
	upvar $variable var
	upvar $remain rem
	set rem ""
	catch {unset var}
	foreach {option options default} $possible {
		set pos [lsearch $real $option]
		if {$pos!=-1} {
			lpop real $pos
			set value [lpop real $pos]
			if {("$options"!="")&&([lsearch $options $value]==-1)} {
				error "Incorrect value \"$value\" for option $option\nmust be one of: $options"
			}
			set var($option) $value
		} else {
			set var($option) $default
		}
	}
	if {"$real"!=""} {
		if {"$remain"!=""} {
			set rem $real
		} else {
			set list ""
			foreach {option options default} $possible {lappend list $option} 
			error "Unkown option(s): \"$real\"\nmust be one of: $list"
		}
	}
}

proc ::Classy::window {object} {
	if {"[info commands ::class::Tk_$object]"!=""} {
		return ::class::Tk_$object
	} else {
		return $object
	}
}

proc ::Classy::object {window} {
	set c $window
	while 1 {
		if {"[info commands ::class::Tk_$c]"!=""} {
			return $c
		}
		set c [winfo parent $c]
		if {"$c" == "."} break
	}
	return -code error "\"$window\" is not part of a Widget"
}

proc Classy::cleargrid w {
	catch {eval grid forget [grid slaves $w]}
	while 1 {
		set col [grid size $w]
		set row [lpop col]
		if {($col == 0)&&($row == 0)} break
		if {$col != 0} {
			grid columnconfigure $w [expr {$col-1}] -weight 0
		}
		if {$row != 0} {
			grid rowconfigure $w [expr {$row-1}] -weight 0
		}
	}
}

proc Classy::loadfunction {file function {pattern {}}} {
	if {"$pattern" == ""} {
		set pattern "^\[ \t\]*proc [list $function] "
	}
	set f [open $file]
	set c ""
	while {![eof $f]} {
		set line [gets $f]
		if [regexp $pattern $line] {
			append c $line
			append c "\n"
			while {![eof $f]} {
				set line [gets $f]
				append c $line
				append c "\n"
				if [info complete $c] break
			}
			break
		}
	}
	close $f
	return $c
}

proc Classy::place {w {keepgeometry 1}} {
	wm positionfrom $w program
	wm withdraw $e
	wm group $w .
	wm protocol $object WM_DELETE_WINDOW [list catch [list destroy $w]]
	after idle "Classy::doplace $w $keepgeometry"
}

proc Classy::doplace {w {keepgeometry 1}} {
	set keeppos 0
	set w [winfo reqwidth $w]
	set h [winfo reqheight $w]
	set x [lindex $resize 0]
	set y [lindex $resize 1]
	if {$x>=1} {set rx 1} else {set rx 0}
	if {$y>=1} {set ry 1} else {set ry 0}
	if {$x<=1} {set x $w}
	if {$y<=1} {set y $h}
	wm minsize $w $x $y
	set keepgeometry [getprivate $object options(-keepgeometry)]
	if [true $keepgeometry] {
		set geom [Classy::Default get geometry $object]
		if [regexp {^([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)} $geom temp xs ys prevx prevy] {
			if {$xs>$w} {set w $xs}
			if {$ys>$h} {set h $ys}
			set temp [expr [winfo pointerx .]-$prevx]
			if {($temp>0)&&($temp<$w)} {
				set temp [expr [winfo pointery .]-$prevy]
				if {($temp>0)&&($temp<$h)} {
					set keeppos 1
					set x $prevx
					set y $prevy
				}
			}
		}
	}
	wm resizable $object $rx $ry

	# position
	if !$keeppos {
		set maxx [expr [winfo vrootwidth $object]-$w]
		set maxy [expr [winfo vrootheight $object]-$h]
		set x [expr [winfo pointerx .]-$w/2]
		set y [expr [winfo pointery .]-$h/2]
		if {$x>$maxx} {set x $maxx}
		if {$y>$maxy} {set y $maxy}
		if {$x<0} {set x 0}
		if {$y<0} {set y 0}
	}
	wm geometry $object +1000000+1000000
	wm deiconify $object
	raise $object
	if [true $keepgeometry] {
		wm geometry $object ${w}x${h}+$x+$y
	} else {
		wm geometry $object +$x+$y
	}
}

# For debugging purposes only

proc ::Classy::msg {text} {
	if [winfo exists .classy__.message] {destroy .classy__.message}
	if {"$text"==""} {return}
	toplevel .classy__.message
	wm positionfrom .classy__.message user
	wm title .classy__.message "Message"
	wm resizable .classy__.message 0 0
	message .classy__.message.message -aspect 250\
		-justify center -text $text
	pack .classy__.message.message
	update idletasks
	set xpos [expr [winfo pointerx .classy__.message]-[winfo width .classy__.message]/2]
	if {$xpos<0} {set xpos 0}
	set ypos [expr [winfo pointery .classy__.message]-[winfo height .classy__.message]/2]
	if {$ypos<0} {set ypos 0}
	wm geometry .classy__.message +$xpos+$ypos
	update
}

#proc ::Classy::Message {window args} {
#	eval message $window $args
#	::Tk::bind $window <Configure> [varsubst {window} {
#		$window configure -width [expr [winfo width $window] - 2*[$window cget -bd]]
#	}]
#}

proc ::Classy::overwriteyn {file {append 1}} {
	if [file exists $file] {
		Classy::Dialog .classy__.overwr -title "Dialog box" -closecommand {set ::Classy::temp 0}
		.classy__.overwr add overwr Overwrite "set ::Classy::temp 1 ; [list file delete $file]"
		if {$append==1} {.classy__.overwr add append "Append" {set ::Classy::temp 2}}
		.classy__.overwr.actions.close configure -text "Cancel"
		.classy__.overwr persistent remove -all

		#top part -->message
		#-------------------
		message .classy__.overwr.options.msg -justify center -aspect 250  -text "File \"$file\" exists!"
		pack .classy__.overwr.options.msg -side top -expand yes -padx 3 -pady 3

		bind .classy__.overwr <o> {.classy__.overwr invoke overwr}
		if {$append==1} {bind .classy__.overwr <a> {.classy__.overwr invoke append}}
		bind .classy__.overwr <c> {.classy__.overwr invoke close}
		focus .classy__.overwr
		update idletasks
		grab .classy__.overwr
		tkwait window .classy__.overwr
		return $::Classy::temp
	}
	return 1
}

set Classy::bgid 0
proc Classy::bgstart {} {
	incr ::Classy::bgid
	set ::Classy::bg($::Classy::bgid) 1
	return $::Classy::bgid
}

proc Classy::bgcheck {id} {
	update
	if ![info exists ::Classy::bg($id)] {
		return -code return {}
	}
}

proc Classy::bgstop {id} {
	catch {unset ::Classy::bg($id)}
}

proc Classy::orient {value} {
	switch -glob $value {
		v* {return vertical}
		h* {return horizontal}
		s* {return stacked}
		default {return -code error "Unknown orientation \"$value\""}
	}
}
