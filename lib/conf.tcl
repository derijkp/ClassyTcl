#
# ClassyTcl configuration 
# ----------------------- Peter De Rijk
#
# conf
# ----------------------------------------------------------------------

global env
if [info exists env(HOME)] {
	set homedir $env(HOME)
} else {
	set homedir [file join [set ::class::dir] userconf]
}

set Classy::dir(def) [file join [set ::class::dir] conf]
set Classy::dir(user) [file join $homedir .classy]
set Classy::dir(appdef) [file join [set ::Classy::appdir] conf]
set Classy::appname [tk appname]
regsub { #[0-9]+$} $Classy::appname {} Classy::appname
set Classy::dir(appuser) [file join $homedir .classy-apps $Classy::appname]
set Classy::dirs [list \
	$Classy::dir(def) \
	$Classy::dir(user) \
	$Classy::dir(appdef) \
	$Classy::dir(appuser)]

foreach type {user appuser} {
	foreach dir {init opt icons def} {
		set dir [file join $Classy::dir($type) $dir]
		catch {file mkdir $dir}
	}
}

proc Classy::configkey {name map} {
	foreach {name event keys descr} $map {
		if {"[string index $name 0]" == "#"} continue
		event delete $event
		eval event add $event $keys
	}
}

proc Classy::configmouse {name map} {
	foreach {name event keys descr} $map {
		if {"[string index $name 0]" == "#"} continue
		event delete $event
		eval event add $event $keys
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
	set list ""
	foreach {name num} {Action 1 Adjust 2 Menu 3} {
		regexp {[0-9]+} [event info <<$name>>] num
		lappend list $name $num
	}
	foreach {name key} $list {
		foreach combo {ButtonRelease ButtonPress} {
			if {"[event info <<$combo-$name>>]" == ""} {
				setevent <<$combo-$name>> <$combo-$key>
			}
		}
		
		foreach combo {
			Motion Leave Enter ButtonRelease ButtonPress
		} {
			if {"[event info <<$name-$combo>>]" == ""} {
				setevent <<$name-$combo>> <B$key-$combo>
			}
		}
	}
}

proc Classy::configcolor {name map} {
	foreach {name option value descr} $map {
		if {"[string index $name 0]" == "#"} continue
		if {"$value" != ""} {
			option add $option $value widgetDefault
		}
	}
}

proc Classy::configfont {name map} {
	foreach {name option value descr} $map {
		if {"[string index $name 0]" == "#"} continue
		if {"$value" == ""} {
		} elseif [regexp {^Font$|^BoldFont$|^ItalicFont$|^BoldItalicFont$|^NonPropFont$} $value] {
			option add $option [option get . $value $value] widgetDefault
		} else {
			option add $option $value widgetDefault
		}
	}
}

proc Classy::configmisc {name map} {
	foreach {name option value type descr} $map {
		if {"[string index $name 0]" == "#"} continue
		if {"$value" != ""} {
			option add $option $value widgetDefault
		}
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
		foreach type {{} .xpm .gif} {
			if [file readable $base$type] {
				set file $base$type
			}
		}
	}
	if {"$file" == ""} {
		return ""
	} else {
		if {"[file extension $file]"==".xbm"} {
			image create bitmap Classy::icon_$name -file $file
		} elseif {"[file extension $file]"==".xpm"} {
			global tcl_platform
			package require Img
			if {"$tcl_platform(platform)"=="windows"} {
				image create photo Classy::icon_$name -file $file
			} else {
				image create pixmap Classy::icon_$name -file $file
			}
		} else {
			image create photo Classy::icon_$name -file $file
		}
	}
	set ::Classy::icons($name) Classy::icon_$name
	return Classy::icon_$name
}

proc Classy::loadconf {conf args} {
	foreach dir [set ::Classy::dirs] {
		set file [file join $dir init ${conf}.tcl]
		if [file readable $file] {
			source $file
		}
	}
	if {"$args" != ""} {
		eval $args $conf
	}
}

proc Classy::setoption {key value} {
	if {"$value" != ""} {
		option add $key $value widgetDefault
	}
}

proc Classy::setfont {key value} {
	if {"$value" == ""} {
	} elseif [regexp {^Font$|^BoldFont$|^ItalicFont$|^BoldItalicFont$|^NonPropFont$} $value] {
		option add $key [option get . $value $value] widgetDefault
	} else {
		option add $key $value widgetDefault
	}
}

proc Classy::loadKeys {} {
	foreach dir [set ::Classy::dirs] {
		set file [file join $dir init Keys.tcl]
		if [file readable $file] {
			source $file
		}
	} 
}

proc Classy::loadMouse {} {
	foreach dir [set ::Classy::dirs] {
		set file [file join $dir init Mouse.tcl]
		if [file readable $file] {
			source $file
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
	set list ""
	foreach {name num} {Action 1 Adjust 2 Menu 3} {
		regexp {[0-9]+} [event info <<$name>>] num
		lappend list $name $num
	}
	foreach {name key} $list {
		foreach combo {ButtonRelease ButtonPress} {
			if {"[event info <<$combo-$name>>]" == ""} {
				setevent <<$combo-$name>> <$combo-$key>
			}
		}
		
		foreach combo {
			Motion Leave Enter ButtonRelease ButtonPress
		} {
			if {"[event info <<$name-$combo>>]" == ""} {
				setevent <<$name-$combo>> <B$key-$combo>
			}
		}
	}
}

proc Classy::initconf {} {
	foreach event [event info] {
		event delete $event
	}
	foreach dir [set ::Classy::dirs] {
		foreach file [glob -nocomplain [file join $dir init *.tcl]] {
			if [file readable $file] {
				if [catch {uplevel #0 source $file} error] {
					puts $error
					bgerror "error while sourcing init file \"$file\":\n$error"
				}
			}
		}
	}
#	::Classy::loadconf Misc
#	::Classy::loadconf Fonts
#	::Classy::loadconf Colors
#	::Classy::loadKeys
#	::Classy::loadMouse
#	::Classy::loadconf Menus
#	::Classy::loadconf Toolbars
}