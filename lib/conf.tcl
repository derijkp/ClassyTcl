#
# ClassyTcl configuration 
# ----------------------- Peter De Rijk
#
# conf
# ----------------------------------------------------------------------

invoke {} {
	global env tcl_platform
	if [info exists env(CLASSYCONFIG)] {
		set configdir $env(CLASSYCONFIG)
	} elseif {"$tcl_platform(platform)" == "windows"} {
		set configdir [file join [set ::class::dir] userconf]
	} elseif [info exists env(HOME)] {
		set configdir $env(HOME)
	} else {
		set configdir [file join [set ::class::dir] userconf]
	}
	
	set ::Classy::dir(def) [file join [set ::class::dir] conf]
	set ::Classy::dir(user) [file join $configdir .classy]
	set ::Classy::dir(appdef) [file join [set ::Classy::appdir] conf]
	set ::Classy::appname [tk appname]
	regsub { #[0-9]+$} $::Classy::appname {} ::Classy::appname
	set ::Classy::dir(appuser) [file join $configdir .classy-apps $::Classy::appname]
	set ::Classy::dirs [list \
		$::Classy::dir(def) \
		$::Classy::dir(user) \
		$::Classy::dir(appdef) \
		$::Classy::dir(appuser)]
	
	foreach type {user appuser} {
		foreach dir {themes icons def} {
			set dir [file join $::Classy::dir($type) $dir]
			catch {file mkdir $dir}
		}
	}
}

proc Classy::realcolor {color} {
	if {[lsearch {Background darkBackground lightBackground Foreground activeBackground activeForeground disabledForeground selectBackground selectForeground selectColor highlightBackground highlightColor} $color] != -1} {
		set temp [option get . $color $color]
		if {"$temp" != ""} {
			set color $temp
		} else {
			switch $color {
				Background {set color [.classy__.dummyb cget -bg]}
				darkBackground  {set color [.classy__.dummyb cget -bg]}
				lightBackground  {set color [.classy__.dummy cget -bg]}
				Foreground  {set color [.classy__.dummyb cget -fg]}
				activeBackground  {set color [.classy__.dummyb cget -bg]}
				activeForeground  {set color [.classy__.dummyb cget -fg]}
				disabledForeground  {set color [.classy__.dummyb cget -fg]}
				selectBackground  {set color [.classy__.dummy cget -selectbackground]}
				selectForeground  {set color [.classy__.dummy cget -selectforeground]}
				selectColor  {set color [.classy__.dummy cget -bg]}
				highlightBackground  {set color [.classy__.dummy cget -highlightbackground]}
				highlightColor  {set color [.classy__.dummy cget -highlightcolor]}
			}
		}
	}
	if {"$color" == ""} {error "could not convert color"}
	return $color
}

proc Classy::realfont {font} {
	if [inlist {Font BoldFont ItalicFont BoldItalicFont NonPropFont} $font] {
		set temp [option get . $font $font]
		if {"$temp" != ""} {
			set font $temp
		} else {
			set temp [font actual [.classy__.dummy cget -font]]
			switch $font {
				Font {set font $temp}
				BoldFont {set font [structlist_set $temp -weight bold]}
				ItalicFont {set font [structlist_set $temp -slant italic]}
				BoldItalicFont {set font [structlist_set $temp -weight bold -slant italic]}
				NonPropFont {set font [structlist_set $temp -family courier]}
			}
		}
	}
	return $font
}

proc Classy::conf_buildcache {files} {
	foreach file $files {
		if [catch {set f [open $file]}] continue
		while {![eof $f]} {
			set line [gets $f]
			if ![string length $line] continue
			set pos [string trimleft $line "# "]
			set descr [string trimleft [gets $f] "# "]
			set line [gets $f]
			while {![eof $f]} {
				set l [gets $f]
				if ![string length $l] break
				append line \n$l
			}
			if [catch {foreach {type key value} $line {}}] {
				error "error in configuration file \"$file\" at \"$line\""
			}
			if {"[string index $type 0]" == "#"} continue
			set conf($type,$key) $line
		}
		close $f
	}
	set result ""
	foreach option {
		Background darkBackground lightBackground Foreground activeBackground activeForeground 
		disabledForeground selectBackground selectForeground selectColor highlightBackground highlightColor
	} {
		if [info exists conf(color,*$option)] {
			foreach {type key value} $conf(color,*$option) {}
			option add $key [Classy::realcolor $value] widgetDefault
			append result [list option add $key [Classy::realcolor $value] widgetDefault]\n
			unset conf(color,*$option)
		} else {
			option add $key [Classy::realcolor $option] widgetDefault
			append result [list option add $key [Classy::realcolor $option] widgetDefault]\n
		}
	}
	foreach option [lsort [array names conf color,*]] {
		foreach {type key value} $conf($option) {}
		option add $key [Classy::realcolor $value] widgetDefault
		append result [list option add $key [Classy::realcolor $value] widgetDefault]\n
		unset conf($option)
	}
	foreach option {Font BoldFont ItalicFont BoldItalicFont NonPropFont} {
		if [info exists conf(font,*$option)] {
			foreach {type key value} $conf(font,*$option) {}
			option add $key [Classy::realfont $value] widgetDefault
			append result [list option add $key [Classy::realfont $value] widgetDefault]\n
			unset conf(font,*$option)
		} else {
			option add $key [Classy::realfont $option] widgetDefault
			append result [list option add $key [Classy::realfont $option] widgetDefault]\n
		}
	}
	foreach option [lsort [array names conf font,*]] {
		foreach {type key value} $conf($option) {}
		option add $key [Classy::realfont $value] widgetDefault
		append result [list option add $key [Classy::realfont $value] widgetDefault]\n
		unset conf($option)
	}
	foreach option [lsort [array names conf key,*]] {
		foreach {type key value} $conf($option) {}
		eval {event add $key} $value
		append result [concat [list event add $key] $value]\n
		unset conf($option)
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
	foreach {name pre num} {Action {} 1 Adjust {} 2 Menu {} 3 MAdd Control- 1 MExtend Shift- 1} {
		if [info exists conf(mouse,<<$name>>)] {
			foreach {type key value} $conf(mouse,<<$name>>) {}
			regexp {^<(.*)([0-9]+)>$} $value temp pre num
			unset conf(mouse,<<$name>>)
		}
		event add <<$name>> <$pre$num>
		append result [list event add <<$name>> <$pre$num>]\n
		regsub {Button-} $pre {} pre
		foreach combo {
			ButtonRelease ButtonPress
		} {
			event add <<$name-$combo>> <${pre}$combo-$num>
			append result [list event add <<$name-$combo>> <${pre}$combo-$num>]\n
		}
		foreach combo {
			Motion Leave Enter
		} {
			event add <<$name-$combo>> <${pre}B$num-$combo>
			append result [list event add <<$name-$combo>> <${pre}B$num-$combo>]\n
		}
	}
	foreach option [lsort [array names conf mouse,*]] {
		foreach {type key value} $conf($option) {}
		eval {event add $key} $value
		append result [concat [list event add $key] $value]\n
		unset conf($option)
	}
	foreach option [lsort [array names conf menu,*]] {
		foreach {type key value} $conf($option) {}
		set ::Classy::configmenu($key) $value
		append result [list set ::Classy::configmenu($key) $value]\n
		unset conf($option)
	}
	foreach option [lsort [array names conf toolbar,*]] {
		foreach {type key value} $conf($option) {}
		set ::Classy::configtoolbar($key) $value
		append result [list set ::Classy::configtoolbar($key) $value]\n
		unset conf($option)
	}
	foreach option [lsort [array names conf]] {
		foreach {type key value} $conf($option) {}
		option add $key $value widgetDefault
		append result [list option add $key $value widgetDefault]\n
	}
	return $result
}

proc Classy::initconf {} {
	set cachefile [file join $::Classy::dir(appuser) config.cache]
	set files ""
	foreach dir [set ::Classy::dirs] {
		lappend files [file join $dir init.conf]
	}
	if ![file exists $cachefile] {
		set makecache 1
	} else {
		set makecache 0
		set mtime [file mtime $cachefile]
		foreach file $files {
			if [catch {file mtime $file} nmtime] continue
			if {$nmtime > $mtime} {
				set makecache 1
				break
			}
		}
	}
	if $makecache {
		if [catch {Classy::conf_buildcache $files} cache] {
			error "error while loading configuration files: $cache"
		}
		file_write $cachefile $cache
	} else {
		foreach event [event info] {
			event delete $event
		}
		uplevel 0 source $cachefile
	}
}

proc Classy::newconfig {type level {name {}} {descr {}}} {
	if {![string length $name]||![string length $descr]} {
		catch {destroy .classy__.temp}
		Classy::Dialog .classy__.temp -title "New $type"
		grid columnconfigure .classy__.temp.options 0 -weight 1
		grid rowconfigure .classy__.temp.options 1 -weight 1
		Classy::Entry .classy__.temp.options.name -label Name
		grid .classy__.temp.options.name -sticky we
		.classy__.temp.options.name set $name
		Classy::Entry .classy__.temp.options.descr -width 25 -label Description
		grid .classy__.temp.options.descr -sticky nswe
		.classy__.temp.options.descr set "description of $type"
		.classy__.temp add go "Go" "Classy::newconfig $type $level \[.classy__.temp.options.name get\] \[.classy__.temp.options.descr get\]" default
		return
	}
	if [inlist [Classy::DynaTool types] $name] {
		error "Toolbar \"$name\" already exists"
	}
	catch {set ltype [structlget {color Colors font Fonts misc Misc mouse Mouse key Keys menu Menus toolbar Toolbars} $type]}
	switch $type {
		toolbar {
			set file [file join $Classy::dir($level) init $ltype.conf]
			set f [open $file a]
			puts $f ""
			puts $f "# Toolbars $name"
			puts $f "# $descr"
			puts $f [list toolbar $name {action Builder/question {Dummy tool} {Classy::msg "Just a dummy toolbar"}}]
			close $f
			Classy::DynaTool define $name {action Builder/question {Dummy tool} {Classy::msg "Just a dummy toolbar"}}
			set node [list Toolbars $name]
			Classy::Config dialod -reload -node $node -level appdef
		}
		menu {
			set file [file join $Classy::dir($level) init $ltype.conf]
			set f [open $file a]
			puts $f ""
			puts $f "# Menus $name"
			puts $f "# $descr"
			puts $f [list menu $name {menu "Menu" {}}]
			close $f
			Classy::DynaMenu define $name {menu "Menu" {}}
			set node [list Menus $name]
			Classy::Config dialog -reload -node $node -level appdef
		}
		default {
			error "Unkown type: \"$type\""
		}
	}
	return $node
}

proc Classy::Config {option args} {
	set window .classy__.config
	switch $option {
		dialog {
			if ![winfo exists $window] {
				eval Classy_config $window
			}
			raise $window
			Classy::parseopt $args opt {
				-node {} {}
				-level {} {}
				-reload {0 1} 0
			}
			if [true $opt(-reload)] {
				Classy::config_start $window
			}
			if [llength $opt(-node)] {
				Classy::config_open $window.browse $opt(-node)
			}
			if [llength $opt(-level)] {
				Classy::config_selectlevel $window $opt(-level)
			}
		}
		config {
			if ![winfo exists $window] {
				eval Classy_config $window
			}
			set name [lindex $args 1]
			switch [lindex $args 0] {
				menu {set node [concat Menus $name]}
				tool {set node [concat Toolbars $name]}
			}
			set level [lindex $args 2]
			Classy::config_open $window.browse $node
			if [string length $level] {
				Classy::config_selectlevel $window $level
			}
		}
		new {
			return [eval Classy::newconfig $args]
		}
		find {
			catch {unset result}
			set pattern [lindex $args 0]
			foreach dir $::Classy::dirs {
				foreach file [glob -nocomplain [file join $dir $pattern]] {
					set result([file tail $file]) $file
				}
			}
			return [array get result]
		}
		default {
			error "Unknown option, should be one of dialog, config or new
		}
	}
}
