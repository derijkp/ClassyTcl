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
	if [catch {uplevel $command} error] {bgerror $error}
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

proc ::Classy::widget {object} {
	return ::class::Tk_$object
}

# For debugging purposes only

proc ::Classy::msg {text} {
	if [winfo exists .classy__message] {destroy .classy__message}
	if {"$text"==""} {return}
	toplevel .classy__message
	wm positionfrom .classy__message user
	wm title .classy__message "Message"
	wm resizable .classy__message 0 0
	message .classy__message.message -aspect 250\
		-justify center -text $text
	pack .classy__message.message
	update idletasks
	set xpos [expr [winfo pointerx .classy__message]-[winfo width .classy__message]/2]
	if {$xpos<0} {set xpos 0}
	set ypos [expr [winfo pointery .classy__message]-[winfo height .classy__message]/2]
	if {$ypos<0} {set ypos 0}
	wm geometry .classy__message +$xpos+$ypos
	update
}

proc ::Classy::Message {window args} {
	eval message $window $args
	bind $window <Configure> [varsubst {window} {
		$window configure -width [expr [winfo width $window] - 2*[$window cget -bd]]
	}]
}
