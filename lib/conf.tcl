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

proc Classy::getpapersize {descr} {
	if {[llength $descr] != 1} {return $descr}
	set portrait 0
	set orient -p
	set p $descr
	regexp {^(.+)(-l|-p)$} $descr temp p orient
	set c [structlist_get [Classy::optionget . paperSizes PaperSizes {
		User      "595p 842p"
		Letter    "612p 792p"
		Tabloid   "792p 1224p"
		Ledger    "1224p 792p"
		Legal     "612p 1008p"
		Statement "396p 612p"
		Executive "540p 720p"
		A0        "2380p 3368p"
		A1        "1684p 2380p"
		A2        "1190p 1684p"
		A3        "842p 1190p"
		A4        "595p 842p"
		A5        "420p 595p"
		B4        "729p 1032p"
		B5        "516p 729p"
		Folio     "612p 936p"
		Quarto    "610p 780p"
	}] $p]
	if {"$orient" == "-l"} {
		set c [list_reverse $c]
	}
	return $c
}

proc Classy::conf_buildcache {files} {
	foreach file $files {
		catch {array set conf [file_read $file]}
	}
	set result ""
	foreach option {
		Background darkBackground lightBackground Foreground activeBackground activeForeground 
		disabledForeground selectBackground selectForeground selectColor highlightBackground highlightColor
	} {
		set key *$option
		set option color,*$option
		if [info exists conf($option)] {
			set value $conf($option)
			option add $key [Classy::realcolor $value] widgetDefault
			append result [list option add $key [Classy::realcolor $value] widgetDefault]\n
			unset conf($option)
		} else {
			option add $key [Classy::realcolor $option] widgetDefault
			append result [list option add $key [Classy::realcolor $option] widgetDefault]\n
		}
	}
	foreach option [array names conf color,*] {
		if ![info exists conf($option)] continue
		foreach {type key} [split $option ,] break
		set value $conf($option)
		option add $key [Classy::realcolor $value] widgetDefault
		append result [list option add $key [Classy::realcolor $value] widgetDefault]\n
		unset conf($option)
	}
	foreach option {Font BoldFont ItalicFont BoldItalicFont NonPropFont} {
		set key *$option
		set option font,*$option
		if [info exists conf($option)] {
			set value $conf($option)
			option add $key [Classy::realfont $value] widgetDefault
			append result [list option add $key [Classy::realfont $value] widgetDefault]\n
			unset conf($option)
		} else {
			option add $key [Classy::realfont $option] widgetDefault
			append result [list option add $key [Classy::realfont $option] widgetDefault]\n
		}
	}
	foreach option [array names conf font,*] {
		if ![info exists conf($option)] continue
		foreach {type key} [split $option ,] break
		set value $conf($option)
		option add $key [Classy::realfont $value] widgetDefault
		append result [list option add $key [Classy::realfont $value] widgetDefault]\n
		unset conf($option)
	}
	foreach option [array names conf key,*] {
		if ![info exists conf($option)] continue
		foreach {type key} [split $option ,] break
		set value $conf($option)
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
			set option mouse,<<$name>>
			set key <<$name>>
			set value $conf($option)
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
	foreach option [array names conf mouse,*] {
		if ![info exists conf($option)] continue
		foreach {type key} [split $option ,] break
		set value $conf($option)
		eval {event add $key} $value
		append result [concat [list event add $key] $value]\n
		unset conf($option)
	}
	foreach conft [array names conf] {
		foreach {type key} [split $conft ,] break
		set value $conf($conft)
		option add $key $value widgetDefault
		append result [list option add $key $value widgetDefault]\n
	}
	return $result
}

proc Classy::initconf {} {
	set cachefile [file join $::Classy::dir(appuser) config.cache]
	set files ""
	foreach dir [set ::Classy::dirs] {
		lappend files [file join $dir conf]
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

proc Classy::getconf {file} {
	foreach dir [list_reverse [set ::Classy::dirs]] {
		set result [file join $dir $file]
		if [file exists $result] break
	}
	if ![file exists $result] {error "Configuration file \"$file\" not found"}
	return $result
}

proc Classy::newconfig {type level {pos {}} {key {}} {descr {}}} {
	if {![string length $pos]||![string length $key]||![string length $descr]} {
		catch {destroy .classy__.temp}
		Classy::Dialog .classy__.temp -title "New $type"
		grid columnconfigure .classy__.temp.options 0 -weight 1
		grid rowconfigure .classy__.temp.options 1 -weight 1
		Classy::Entry .classy__.temp.options.pos -label Position
		grid .classy__.temp.options.pos -sticky we
		.classy__.temp.options.pos set $pos
		Classy::Entry .classy__.temp.options.key -label Key
		grid .classy__.temp.options.key -sticky we
		.classy__.temp.options.key set $key
		Classy::Entry .classy__.temp.options.descr -width 25 -label Description
		grid .classy__.temp.options.descr -sticky nswe
		.classy__.temp.options.descr set "description of $type"
		.classy__.temp add go "Go" "Classy::newconfig $type $level \[.classy__.temp.options.pos get\] \[.classy__.temp.options.key get\] \[.classy__.temp.options.descr get\]" default
		return
	}
	catch {set ltype [structlist_get {color Colors font Fonts misc Misc mouse Mouse key Keys menu Menus toolbar Toolbars} $type]}
	lappend pos $key
	switch $type {
		toolbar {
			if [inlist [Classy::DynaTool types] $key] {
				error "Toolbar \"$key\" already exists"
			}
			set file [file join $Classy::dir($level) conf.descr]
			set c [file_read $file]
			set c [structlist_set $c $pos [list _menu $key $descr {}]]
			file_write $file $c
			Classy::Config dialog -node $pos -level appdef
		}
		menu {
			if [inlist [Classy::DynaMenu types] $key] {
				error "Toolbar \"$key\" already exists"
			}
			set file [file join $Classy::dir($level) conf.descr]
			set c [file_read $file]
			set c [structlist_set $c $pos [list _menu $key $descr {}]]
			file_write $file $c
			Classy::Config dialog -node $pos -level appdef
		}
		default {
			error "Unkown type: \"$type\""
		}
	}
	return $pos
}

proc Classy::Config {option args} {
	set window .classy__.config
	switch $option {
		dialog {
			if ![winfo exists $window] {
				Classy::config_dialog
			}
			raise $window
			Classy::parseopt $args opt {
				-key {} {}
				-node {} {}
				-level {} {}
				-reload {0 1} 0
			}
			if [true $opt(-reload)] {
				Classy::config_dialog
			}
			if [llength $opt(-node)] {
				Classy::config_gotoitem $opt(-node)
			}
			if [llength $opt(-key)] {
				Classy::config_gotokey $opt(-key)
			}
			if [llength $opt(-level)] {
				Classy::config_level $opt(-level)
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
			error "Unknown option, should be one of dialog, config or new"
		}
	}
}
