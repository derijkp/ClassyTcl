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
set Classy::dir(appuser) [file join $homedir .[tk appname]]
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

proc setevent {event args} {
	event delete $event
	if {[llength $args]&&("$args" != {{}})} {
		eval event add $event $args
	}
}

proc Classy::geticon {name} {
	foreach type {appuser appdef user def} {
		set file [file join $::Classy::dir($type) icons $name]
		if [file readable $file] {
			return $file
		}
	}
	return -code error "Icon \"$name\" not found"
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

proc Classy::loadFonts {args} {
	foreach dir [set ::Classy::dirs] {
		set file [file join $dir init Fonts.tcl]
		if [file readable $file] {
			source $file
		}
	} 
#	catch {font delete default}
#	catch {font delete default_bold}
#	catch {font delete default_italic}
#	catch {font delete default_bold_italic}
	foreach name {
		DefaultFont DefaultBoldFont DefaultItalicFont
		DefaultBoldItalicFont DefaultNonpropFont
	} {
		catch {font delete $name}
		eval {font create $name} [font actual [option get . $name $name]]
	}
	if {"$args" != ""} {
		eval $args Fonts
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
#		if {"[event info <<Shift-$name-Motion>>]" == ""} {
#			setevent <<Shift-$name-Motion>> <Shift-B$key-Motion>
#		}
#		if {"[event info <<Shift-$name-ButtonPress>>]" == ""} {
#			setevent <<Shift-$name-ButtonPress>> <Shift-B$key-ButtonPress>
#		}
#		if {"[event info <<Shift-$name-ButtonRelease>>]" == ""} {
#			setevent <<Shift-$name-ButtonRelease>> <Shift-B$key-ButtonRelease>
#		}
#		if {"[event info <<Control-$name-Motion>>]" == ""} {
#			setevent <<Control-$name-Motion>> <Control-B$key-Motion>
#		}
#		if {"[event info <<Control-$name-ButtonPress>>]" == ""} {
#			setevent <<Control-$name-ButtonPress>> <Control-B$key-ButtonPress>
#		}
#		if {"[event info <<Control-$name-ButtonRelease>>]" == ""} {
#			setevent <<Control-$name-ButtonRelease>> <Control-B$key-ButtonRelease>
#		}
#		if {"[event info <<Meta-$name-Motion>>]" == ""} {
#			setevent <<Meta-$name-Motion>> <Meta-B$key-Motion>
#		}
#		if {"[event info <<Meta-$name-ButtonPress>>]" == ""} {
#			setevent <<Meta-$name-ButtonPress>> <Meta-B$key-ButtonPress>
#		}
#		if {"[event info <<Meta-$name-ButtonRelease>>]" == ""} {
#			setevent <<Meta-$name-ButtonRelease>> <Meta-B$key-ButtonRelease>
#		}
	}
}

proc Classy::initconf {} {
	foreach event [event info] {
		event delete $event
	}
	::Classy::loadconf Misc
	::Classy::loadFonts
	::Classy::loadconf Colors
	::Classy::loadKeys
	::Classy::loadMouse
	::Classy::loadconf Menus
	::Classy::loadconf Toolbars
}