#
# ClassyTcl configuration helpers functions
# ----------------------------------------- Peter De Rijk
#
# confextra
# ----------------------------------------------------------------------

proc Classy::optionget {w name class {def {}}} {
	set result [::option get $w $name $class]
	if {"$result" == ""} {
		if [catch {lindex [$w configure -[string tolower $name]] 3} result] {
			if [catch {lindex [$w configure	-[string tolower $class]] 3} result] {
				set result $def
			}
		}
		if {"$result" == ""} {
			set result $def
		}
	}
	return $result
}

proc Classy::getbitmap {name {reload {}}} {
	if [info exists ::Classy::bitmaps($name)] {
		if {"$reload" == ""} {
			return $::Classy::bitmaps($name)
		} else {
			unset ::Classy::bitmaps($name)
		}
	}
	set file ""
	foreach type {appuser appdef user def} {
		set base [file join $::Classy::dir($type) icons $name]
		foreach type {{} .xbm} {
			if [file readable $base$type] {
				set file $base$type
			}
		}
	}
	if {"$file" == ""} {
		error "Could not find bitmap \"$name\""
	}
	set ::Classy::bitmaps($name) "@$file"
	return "@$file"
}

proc Classy::geticon {name {reload {}}} {
	if [info exists ::Classy::icons($name)] {
		if {"$reload" == ""} {
			return $::Classy::icons($name)
		} else {
			image delete $::Classy::icons($name)
			unset ::Classy::icons($name)
		}
	}
	set file ""
	foreach type {appuser appdef user def} {
		set base [file join $::Classy::dir($type) icons $name]
		foreach type {{} .gif .xbm} {
			if [file readable $base$type] {
				set file $base$type
			}
		}
	}
	if {"$file" == ""} {
		error "Could not find icon \"$name\""
	} else {
		if {"[file extension $file]"==".xbm"} {
			image create bitmap ::Classy::icon_$name -file $file
		} else {
			image create photo ::Classy::icon_$name -file $file
		}
	}
	set ::Classy::icons($name) ::Classy::icon_$name
	return ::Classy::icon_$name
}

if 0 {

proc Classy::configkey {name map} {
	foreach {name event keys descr} $map {
		if {"[string index $name 0]" == "#"} continue
		set ::Classy::configkey($event) $keys
	}
}

proc Classy::doconfigkey {} {
	foreach {event keys} [array get ::Classy::configkey] {
		event delete $event
		catch {eval event add $event $keys}
	}
}

proc Classy::configcolor {name map} {
	foreach {name option value descr} $map {
		if {"[string index $name 0]" == "#"} continue
		set ::Classy::configcolor($option) $value
		list_addnew ::Classy::configcolor() $option
	}
}

proc Classy::doconfigcolor {} {
	set list [set ::Classy::configcolor()]
	set common [list_common {Background darkBackground lightBackground Foreground activeBackground activeForeground disabledForeground selectBackground selectForeground selectColor highlightBackground highlightColor} $list]
	foreach option $common {
		set value [set ::Classy::configcolor($option)]
		option add $option [Classy::realcolor $value] widgetDefault
	}
	foreach option [list_remove $list $common] {
		set value [set ::Classy::configcolor($option)]
		option add $option [Classy::realcolor $value] widgetDefault
	}
}

proc Classy::configfont {name map} {
	foreach {name option value descr} $map {
		if {"[string index $name 0]" == "#"} continue
		if {"$value" == ""} continue
		set ::Classy::configfont($option) $value
		list_addnew ::Classy::configfont() $option
	}
}

proc Classy::doconfigfont {} {
	set list [set ::Classy::configfont()]
	set common [list_common {Font BoldFont ItalicFont BoldItalicFont NonPropFont} $list]
	foreach option $common {
		set value [set ::Classy::configfont($option)]
		set font [Classy::realfont $value]
		if ![catch {font actual $font}] {
			option add $option $font widgetDefault
		}
	}
	foreach option [list_lremove $list $common] {
		set value [set ::Classy::configfont($option)]
		set font [Classy::realfont $value]
		if {"$font" != ""} {
			option add $option $font widgetDefault
		}
	}
}

proc Classy::configmisc {name map} {
	foreach {name option value type descr} $map {
		if {"[string index $name 0]" == "#"} continue
		if {"$value" == ""} continue
		set ::Classy::configmisc($option) $value
		list_addnew ::Classy::configmisc() $option
	}
}

proc Classy::doconfigmisc {} {
	foreach option [set ::Classy::configmisc()] {
		option add $option [set ::Classy::configmisc($option)] widgetDefault
	}
}

proc Classy::configmenu {name help menu} {
	Classy::DynaMenu define $name $menu
}

proc Classy::configtool {name help tool} {
	Classy::DynaTool define $name $tool
}

proc setevent {event args} {
	event delete $event
	if {[llength $args]&&("$args" != {{}})} {
		eval event add $event $args
	}
}

proc Classy::setoption {key value} {
	if {"$value" != ""} {
		option add $key $value widgetDefault
	}
}

# Mouse button bindings
# Which mousebutton does what?
# Action = select, invoke button, ...
# Menu = popup associated popup menu
# Adjust = Alternative action, depends on the widget
#          e.g. when you click on a dialog button with Action,
#          it will execute the action, and close the dialog.
#          Often you can use the adjust button to execute
#          the action without closing the dialog.
#          In entries or texts under X, it works as the copy button 
# -----------------------------------------------------------------
proc Classy::configmouse {name map} {
	foreach {name event keys descr} $map {
		if {"[string index $name 0]" == "#"} continue
		set ::Classy::configmouse($event) $keys
	}
}

proc Classy::doconfigmouse {} {
	foreach {event keys} [array get ::Classy::configmouse] {
		event delete $event
		catch {eval event add $event $keys}
	}
	set list ""
	foreach {name pre num} {Action {} 1 Adjust {} 2 Menu {} 3 MAdd Control- 1 MExtend Shift- 1} {
		regexp {^<(.*)([0-9]+)>$} [event info <<$name>>] temp pre num
		regsub {Button-} $pre {} pre
		foreach combo {
			ButtonRelease ButtonPress
		} {
			setevent <<$name-$combo>> <${pre}$combo-$num>
		}
		foreach combo {
			Motion Leave Enter
		} {
			setevent <<$name-$combo>> <${pre}B$num-$combo>
		}
	}
}

}