#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::Configurator
# ----------------------------------------------------------------------
#doc Configurator title {
#Configurator
#} descr {
# subclass of <a href="../basic/Class.html">Class</a><br>
# is used for the configuration of ClassyTcl applications.
# This class is not meant to be instanciated.
# The only use should be
# <pre>Classy::Configurator dialog</pre>
#}
#doc {Configurator command} h2 {
#	Configurator specific methods
#} descr {
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Configurator {} {}
proc Configurator {} {}
}
catch {Classy::Configurator destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Class subclass Classy::Configurator
Classy::export Configurator {}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------


#doc {Configurator command dialog} cmd {
#pathname dialog 
#} descr {
# pop up a dialog for the configuration of ClassyTcl applications
#}
Classy::Configurator method dialog {} {
	private $object w
	# REM Create object
	# -----------------
	Classy::Dialog .classy__config -title "Configuration Dialog" \
		-closecommand "if \[$object _checksaved\] {destroy .classy__config}"
	.classy__config persistent add close
	set w [.classy__config component options]

	Classy::NoteBook $w.book
	foreach {conftype confname} {
		key Keys
		mouse Mouse
		font Fonts
		color Colors
		menu Menus
		tool Toolbars
		misc Misc
	} {
		frame $w.$conftype
		$w.book manage $confname $w.$conftype -command [list $object _makeconf $conftype $confname]
	}
	frame $w.defaults
	$w.book manage Defaults $w.defaults -command [list $object _makedefaults]
	
	pack $w.book -fill both -expand yes
	$w.book select Keys
	Classy::canceltodo .classy__config place
	update idletasks
	$w.book propagate
	.classy__config place
}

Classy::Configurator method _parseconffile {level file} {
	private $object data
	set conftype $data(conftype)
	if [file readable $file] {
		set section ""
		set description ""
		set help ""
		foreach line [splitcomplete [readfile $file]] {
			switch -regexp -- $line {
				{^## ----} {
					set section [string trimright [string trimleft $line "# -\n"] " -\n"]
					laddnew data(sections) $section
					if ![info exists data(section__$section)] {
						set data(section__$section) ""
					}
				}
				{^## } {
					set description [lindex $line 1]
					set help [lindex $line 2]
					set entrytype [lindex $line 3]
					if {"$entrytype" == ""} {set entrytype line}
				}
				{^[ ]*$} {}
				default {
					if {"$description" == ""} {
						error "error in format of file \"$file\": no description for line $line"
					}
					if {("$conftype" == "key")||("$conftype" == "mouse")} {
						set key [lindex $line 1]
					} else {
						set key [lindex $line 2]
					}
					laddnew data(section__$section) $description
					set data(descr__$description) $key
					set data(help__$key) $help
					set data(entry__$key) $entrytype
					set data(${level}__$key) $line
					set description ""
					set help ""
				}
			}
		}
	}
}

Classy::Configurator method _parseconf {conftype confname} {
	private $object data notsaved
	if [info exists data] {unset data}
	set data(conftype) $conftype
	set data(confname) $confname
	set data(sections) ""
	set data(section__) ""
	foreach level {def user appdef appuser} {
		catch {unset notsaved($confname,$level)}
		set file [file join [set Classy::dir($level)] init $confname.tcl]
		$object _parseconffile $level $file
	}
}

Classy::Configurator method _makeconf {conftype file} {
	private $object data notsaved data$conftype
	if [info exists data] {
		set keep 0
		foreach {level} {def user appdef appuser} {
			if [info exists notsaved($data(conftype),$level)] {
				set keep 1
			}
		}
		if $keep {
			setprivate $object data$data(conftype) [array get data]
		} else {
			private $object data$data(conftype)
			catch {unset data$data(conftype)}
		}
	}
	if ![info exists data$conftype] {
		$object _parseconf $conftype $file
	} else {
		array set data [set data$conftype]
	}
	set conftype $data(conftype)
	set confname $data(confname)
	set w [getprivate $object w].$conftype
	eval destroy [winfo children $w]

	label $w.edittitle -text "Edit configuration"
	# Selection frame
	# ---------------
	frame $w.select
	Classy::OptionMenu $w.select.section -list $data(sections) -command [varsubst {w object} {
		eval $w.select.list delete 0 end
		eval $w.select.list insert end [getprivate $object data(section__[$w.select.section get])]

		focus $w.select.list
		$w.select.list activate 0
		$w.select.list selection set 0
		$object _configureitem [$w.select.list get 0]
	}]
	set section [lindex $data(sections) 0]
	$w.select.section set $section
	listbox $w.select.list -yscrollcommand [list $w.select.vbar set] -exportselection no
	eval $w.select.list insert end $data(section__$section)
	scrollbar $w.select.vbar -orient vertical -command [list $w.select.list yview]

	bind $w.select.list <Enter> "focus $w.select.list"
	bind $w.select.list <<Action>> "$object _configureitem \[$w.select.list get \[$w.select.list nearest %y\]\]"
	bind $w.select.list <KeyRelease> "$object _configureitem \[$w.select.list get active\]"

	grid $w.select.section -column 0 -row 0 -columnspan 2 -sticky nwse
	grid $w.select.list -column 0 -row 1 -sticky nwse
	grid $w.select.vbar -column 1 -row 1 -sticky nwse
	grid rowconfigure $w.select 1 -weight 1

	# manage frame
	# ------------
	frame $w.manage -relief groove -bd 2

	label $w.manage.title -text "Configuration management"

	Classy::OptionBox $w.manage.level -label "Select level" \
		-variable [privatevar $object selectlevel]
	foreach {level title} {
		def "ClassyTcl Default"
		user "ClassyTcl user"
		appdef "Application Default"
		appuser "Application user"
	} {
		$w.manage.level add $level $title
	}
	$w.manage.level set user

	button $w.manage.select -text "Select configuration" -command [list $object _selectconfdialog]
	button $w.manage.save -text "Save configuration" -command [varsubst {w object confname} {
		$object _saveconf [$w.manage.level get] [file join $::Classy::dir([$w.manage.level get]) init $confname.tcl]
	}]

	button $w.manage.saveas -text "Save configuration as" -command [list $object _saveasconfdialog]
	button $w.manage.clear -text "Clear configuration" -command [list $object _clearconf]

	grid $w.manage.title - - - -sticky swe
	grid $w.manage.level - - - -sticky nwse
	grid $w.manage.select $w.manage.save $w.manage.saveas $w.manage.clear -sticky nwse
	grid columnconfigure $w.manage 4 -weight 1

	# put everything together
	# -----------------------
	frame $w.edit -relief groove -bd 2
	grid $w.edittitle -in $w.edit -column 0 -row 0 -columnspan 2 -sticky swe
	grid $w.select -in $w.edit -column 0 -row 1 -sticky nwse
	grid rowconfigure $w.edit 1 -weight 1	
	grid columnconfigure $w.edit 1 -weight 1	
	raise $w.edittitle
	raise $w.select

	grid $w.edit -column 0 -row 0 -sticky nwse
	grid $w.manage -column 0 -row 1 -sticky swe
	grid rowconfigure $w 0 -weight 1
	grid columnconfigure $w 0 -weight 1

	focus $w.select.list
	$w.select.list activate 0
	$w.select.list selection set 0
	setprivate $object confw ""
	$object _configureitem [$w.select.list get 0]
	return 1
}

Classy::Configurator method _createconfw {entrytype} {
	private $object data
	set confname $data(confname)
	set args [lrange $entrytype 1 end]
	set entrytype [lindex $entrytype 0]
	set w [getprivate $object w].conf_$entrytype
	# Configuration frame
	# -------------------
	frame $w

	label $w.title -text "Settings"
	grid $w.title - - - -sticky nwse
	set pre [privatevar $object data]
	set row 1
	foreach {level title} {
		def "ClassyTcl Default"
		user "ClassyTcl user"
		appdef "Application Default"
		appuser "Application user"
	} {
		checkbutton $w.${level}_label -text $title -anchor w -variable [set pre]($level)
		if {"$level" == "def"} {
			$w.${level}_label configure -command [list set [set pre]($level) 1]
		} else {
			$w.${level}_label configure -command [varsubst {object w level pre} {
				if ![getprivate $object data($level)] {$object _clearfield $level}
			}]
		}
		checkbutton $w.${level}_rem -text "as remark" -anchor w \
			-variable [set pre](${level}__rem)
		switch [lindex $entrytype 0] {
			menu -
			tool {
				Classy::Text $w.$level -height 2 -width 20 -wrap none \
					-yscrollcommand [list $w.${level}_bar set]
				scrollbar $w.${level}_bar -orient vertical -command [list $w.$level yview]
				bind $w.$level <Key> "set [set pre]($level) 1"
				grid $w.$level -row [expr $row+1] -column 0 -columnspan 4 -sticky nwse
				grid $w.${level}_bar -row [expr $row+1] -column 5 -sticky nwse
				grid rowconfigure $w [expr $row+1] -weight 1
			}
			font {
				button $w.${level}_select -text Select -command [varsubst {object level} {
					set ::Classy::temp [Classy::getfont -font [$object _getfield $level]]
					if {"$::Classy::temp" != ""} {
						setprivate $object data($level) 1
						$object _setfield $level $::Classy::temp
						$object _activateconf
					}
				}]
				entry $w.$level
				bind $w.$level <Key> "set [set pre]($level) 1"
				bind $w.$level <Return> [list $object _activateconf]
				grid $w.${level}_select -row [expr $row+1] -column 0 -sticky nwse
				grid $w.$level -row [expr $row+1] -column 1 -columnspan 3 -sticky nwse
			}
			color {
				button $w.${level}_select -text Select -command [varsubst {object level} {
					set ::Classy::temp [Classy::getcolor -initialcolor [$object _getfield $level]]
					if {"$::Classy::temp" != ""} {
						setprivate $object data($level) 1
						$object _setfield $level $::Classy::temp
						$object _activateconf
					}
				}]
				entry $w.$level
				bind $w.$level <Key> "set [set pre]($level) 1"
				bind $w.$level <Return> [list $object _activateconf]
				grid $w.${level}_select -row [expr $row+1] -column 0 -sticky nwse
				grid $w.$level -row [expr $row+1] -column 1 -columnspan 3 -sticky nwse
			}
			select {
				Classy::OptionMenu $w.${level} -list [concat $args {{}}] \
					-command [list $object _activateconf]
				grid $w.$level -row [expr $row+1] -column 0 -columnspan 4 -sticky nwse
			}
			default {
				entry $w.$level
				bind $w.$level <Key> "set [set pre]($level) 1"
				bind $w.$level <Return> [list $object _activateconf]
				grid $w.$level -row [expr $row+1] -column 0 -columnspan 4 -sticky nwse
			}
		}
		grid $w.${level}_label - $w.${level}_rem -row $row -sticky nwse
		incr row 2
	}
	label $w.current -anchor w
	button $w.activate -text "OK" \
		-command [list $object _activateconf]
	grid $w.activate $w.current - - -sticky nwse
	Classy::Message $w.help -text "Help text" -anchor nw -justify left
	grid $w.help - - - -sticky nwse
	grid columnconfigure $w 3 -weight 1	
}

Classy::Configurator method _configureitem {descr} {
	private $object data confw
	if {"$descr" == ""} return
	set conftype $data(conftype)
	set w [getprivate $object w].$conftype
	set key $data(descr__$descr)
	set data(current) $key
	set entrytype [lindex $data(entry__$key) 0]
	set temp [getprivate $object w].conf_$entrytype
	if {"$temp" != "$confw"} {
		if ![winfo exists $temp] {
			$object _createconfw $entrytype
		}
		catch {grid forget $confw}
		set confw $temp
		if {("$entrytype"=="menu")||("$entrytype"=="tool")} {
			grid $confw -in $w.edit -column 1 -row 1 -sticky nswe
		} else {
			grid $confw -in $w.edit -column 1 -row 1 -sticky nwe
		}
	}
	raise $confw

	$confw.title configure -text "Settings for $descr"
	set current ""
	foreach level {def user appdef appuser} {
		set data($level) 0
		$object _clearfield $level
		if {"$entrytype" == "select"} {
			$confw.$level configure -list [concat [lrange $data(entry__$key) 1 end] {{}}]
		}
		if [info exists data(${level}__$key)] {
			set data($level) 1
			if {("$conftype" == "key")||("$conftype" == "mouse")} {
				set temp [lrange $data(${level}__$key) 2 end]
			} else {
				set temp [lindex $data(${level}__$key) 3]
			}
			if {"$temp" != ""} {set current $temp}
			$object _setfield $level $temp
			if [regexp ^# $data($level)__$key] {
				set data(${level}__rem) 1
			} else {
				set data(${level}__rem) 0
			}
		} else {
			set data(${level}__rem) 0
			set data($level) 0
		}
	}
	if {[string first "\n" $current] == -1} {
		$confw.current configure -text $current
	} else {
		$confw.current configure -text "... too long to display; look above ..."
	}
	$confw.help configure -text $data(help__$key)
}

Classy::Configurator method _clearfield {level} {
	set w [getprivate $object confw]
	regexp {_([^_]+)$} $w temp entrytype
	switch $entrytype {
		menu -
		tool {
			$w.$level delete 1.0 end
		}
		select {
			$w.$level set ""
		}
		default {
			$w.$level delete 0 end
		}
	}
}

Classy::Configurator method _setfield {level value} {
	set w [getprivate $object confw]
	regexp {_([^_]+)$} $w temp entrytype
	switch $entrytype {
		menu -
		tool {
			$w.$level delete 1.0 end
			$w.$level insert end $value
		}
		select {
			$w.$level set $value
		}
		default {
			$w.$level delete 0 end
			$w.$level insert end $value
		}
	}
}

Classy::Configurator method _getfield {level} {
	set w [getprivate $object confw]
	regexp {_([^_]+)$} $w temp entrytype
	switch $entrytype {
		menu -
		tool {
			return [$w.$level get 1.0 end]
		}
		select {
			return [$w.$level get]
		}
		default {
			return [$w.$level get]
		}
	}
}

Classy::Configurator method _activateconfall {} {
	private $object data
	set conftype $data(conftype)
	foreach section $data(sections) {
		foreach description $data(section__$section) {
			set key $data(descr__$description)
			if {"$conftype" == "key"} {setevent $key {}}
			if {"$conftype" == "mouse"} {setevent $key {}}
			foreach level {def user appdef appuser} {
				if [info exists data(${level}__$key)] {
					eval $data(${level}__$key)
				}
			}
		}
	}
	if {"$conftype" == "font"} {
		foreach name {
			DefaultFont DefaultBoldFont DefaultItalicFont
			DefaultBoldItalicFont DefaultNonpropFont
		} {
			catch {font delete $name}
			eval {font create $name} [font actual [option get . $name $name]]
		}
	}
}

Classy::Configurator method _activateconf {} {
	private $object data notsaved
	set conftype $data(conftype)
	set w [getprivate $object confw]
	set key $data(current)
	set current ""
	foreach level {def user appdef appuser} {
		set value [$w.$level get]
		if $data($level) {
			if {("$conftype" == "key")||("$conftype" == "mouse")} {
				if $data(${level}__rem) {
					set new "#setevent $key $value"
				} else {
					set new "setevent $key $value"
					set current $value
				}
			} else {
				if $data(${level}__rem) {
					set new "#option add $key [list $value] widgetDefault"
				} else {
					set new "option add $key [list $value] widgetDefault"
					set current $value
				}
			}
			if ![info exists data(${level}__$key)] {
				set notsaved($conftype,$level) 1
			} elseif {"$data(${level}__$key)" != "$new"} {
				set notsaved($conftype,$level) 1
			}
			set data(${level}__$key) $new
		} elseif {"$level" == "def"} {
			$object _configureitem $key
			error "cannot unset the ClassyTcl Default"
		} else {
			if [info exists data(${level}__$key)] {
				if [info exists data(${level}__$key)] {
					set notsaved($conftype,$level) 1
					unset data(${level}__$key)
				}
			}
		}
	}
	if {("$conftype" == "key")||("$conftype" == "mouse")} {
		eval setevent $key $current
	} elseif {"$conftype" == "font"} {
		option add $key $current widgetDefault
		foreach name {
			DefaultFont DefaultBoldFont DefaultItalicFont
			DefaultBoldItalicFont DefaultNonpropFont
		} {
			catch {font delete $name}
			eval {font create $name} [font actual [option get . $name $name]]
		}
	} else {
		option add $key [list $current] widgetDefault
	}
	$w.current configure -text $current
}


Classy::Configurator method _getnamedconfigs {{conf {}}} {
	private $object data
	set result ""
	set data(selectlist) ""
	foreach {level name} {
		def "ClassyTcl Default"
		user "ClassyTcl user"
		appdef "Application Default"
		appuser "Application user"
	} {
		foreach scheme [dirglob [file join $::Classy::dir($level) opt] *] {
			if {"$conf" == ""} {
				lappend result "$scheme $name"
			} elseif [file exists [file join $::Classy::dir($level) opt $scheme $conf.tcl]] {
				lappend result "$scheme $name"
				lappend data(selectlist) [file join $::Classy::dir($level) opt $scheme $conf.tcl]
			}
		}
	}
	return $result
}

Classy::Configurator method _selectconfdialog {} {
	private $object data
	set conftype $data(conftype)
	set confname $data(confname)
	if [winfo exists .classy__config.loadconfig] {.classy__config.loadconfig destroy}
	set w [getprivate $object w].$conftype
	set level [$w.manage.level get]
	set w .classy__config.loadconfig
	Classy::Dialog $w -title "Select $level configuration"
	set w [$w component options]
	listbox $w.list -yscrollcommand [list $w.vbar set] \
		-exportselection no -height 5
	scrollbar $w.vbar -orient vertical -command [list $w.list yview]

	grid $w.list -row 0 -column 0 -sticky nwse
	grid $w.vbar -row 0 -column 1 -sticky nwse
	grid columnconfigure $w 0 -weight 1
	grid rowconfigure $w 0 -weight 1

	bind $w.list <<MExecute>> [list .classy__config.loadconfig invoke go]
	.classy__config.loadconfig add go "Go" [list $object _selectconf $level] default
	eval $w.list insert end [$object _getnamedconfigs $confname]
}

Classy::Configurator method _selectconf {level} {
	private $object data notsaved
	set conftype $data(conftype)
	set w [.classy__config.loadconfig component options]
	set pos [$w.list curselection]
	if {"$pos" == ""} return
	set file [lindex $data(selectlist) $pos]
	$object _parseconffile $level $file

	set w [getprivate $object w].$conftype
	focus $w.select.list
	$object _configureitem [$w.select.list get [$w.select.list curselection]]
	$object _activateconfall
	set notsaved($conftype,$level) 1
}

Classy::Configurator method _saveconf {level file} {
	private $object data notsaved
	set conftype $data(conftype)
	set confname $data(confname)
	set w [getprivate $object w].$conftype
	set f [open $file w]
	foreach section $data(sections) {
		set result ""
		foreach description $data(section__$section) {
			set key $data(descr__$description)
			if [info exists data(${level}__$key)] {
				append result "[list ## $description $data(help__$key)]\n"
				append result "$data(${level}__$key)\n"
			}
		}
		if {"$result" != ""} {
			puts $f "## ---- $section ----"
			puts $f $result
		}
	}
	close $f
	catch {unset notsaved($conftype,$level)}
}

Classy::Configurator method _saveasconf {} {
	private $object data
	set conftype $data(conftype)
	set confname $data(confname)
	set w [getprivate $object w].$conftype
	set level [$w.manage.level get]

	set w [.classy__config.saveasconfig component options]
	set savelevel [$w.level get]
	set name [$w.entry get]
	set file [file join $::Classy::dir($savelevel) opt $name $confname.tcl]
	set dir [file dir $file]
	if ![file exists $dir] {file mkdir $dir}
	if [file exists $file] {
		if ![Classy::yorn "File $file exists: overwrite?"] return
	}
	$object _saveconf $level $file
}

Classy::Configurator method _saveasconfdialog {} {
	private $object data
	set conftype $data(conftype)
	if [winfo exists .classy__config.saveasconfig] {
		.classy__config.saveasconfig destroy
	}
	set w [getprivate $object w].$conftype
	set level [$w.manage.level get]
	set w .classy__config.saveasconfig
	Classy::Dialog $w -title "Save $level configuration as" -resize {1 0}
	$w add go "Save" [list $object _saveasconf] default
	set w [$w component options]
	Classy::OptionBox $w.level -label "Level" -orient vertical \
		-variable [privatevar $object saveaslevel]
	foreach {level title} {
		def "ClassyTcl Default"
		user "ClassyTcl user"
		appdef "Application Default"
		appuser "Application user"
	} {
		$w.level add $level $title
	}
	$w.level set user
	Classy::Entry $w.entry -label "Name" -orient vertical
	pack $w.level -fill x -expand yes
	pack $w.entry -fill x -expand yes
}

Classy::Configurator method _clearconf {} {
	private $object data
	set conftype $data(conftype)
	set w [getprivate $object w].$conftype
	set level [$w.manage.level get]
	if ![Classy::yorn "Are you sure you want to remove all definitions from $level"] return
	foreach item [array names data ${level}__*] {
		set notsaved($conftype,$level) 1
		unset data($item)
	}
	set w [getprivate $object w].$conftype
	focus $w.select.list
	$object _configureitem [$w.select.list get [$w.select.list curselection]]
	$object _activateconfall
}

Classy::Configurator method _checksaved {} {
	private $object notsaved
	set w [.classy__config component options]
	foreach {conftype confname} {
		key Keys
		mouse Mouse
		font Fonts
		color Colors
		menu Menus
		tool Toolbars
		misc Misc
	} {
		foreach {level title} {
			def "ClassyTcl Default"
			user "ClassyTcl user"
			appdef "Application Default"
			appuser "Application user"
		} {
			if [info exists notsaved($conftype,$level)] {
				if ![Classy::yorn "\"$title $confname\" not saved; continue anyway?"] {
					$w.book select $confname
					$w.$conftype.manage.level set $level
					return 0
				}
			}
		}
	}
	return 1
}

Classy::Configurator method _makedefaults {} {
	set w [getprivate $object w]
	if ![winfo exists $w.defaults.list] {
		Classy::OptionBox $w.defaults.type -label "Type" -orient vertical
		$w.defaults.type add app "Application defaults" \
			-command [list $object _filldefault]
		$w.defaults.type add geometry "Geometry defaults" \
			-command [list $object _filldefault]
		listbox $w.defaults.list -yscrollcommand [list $w.defaults.bar set] -exportselection no
		bind $w.defaults.list <<Action>> "$object _configuredefault \[$w.defaults.list get \[$w.defaults.list nearest %y\]\]"
		bind $w.defaults.list <KeyRelease> "$object _configuredefault \[$w.defaults.list get active\]"
		scrollbar $w.defaults.bar -command [list $w.defaults.list yview] -orient vertical
		Classy::Text $w.defaults.edit -width 10 -height 5
		frame $w.defaults.buttons
		button $w.defaults.change -text "Change" -command [list $object _changedefault]
		button $w.defaults.save -text "Save now" -command {Classy::Default save}
		pack $w.defaults.change $w.defaults.save -in $w.defaults.buttons -side left

		grid $w.defaults.type -row 0 -column 0 -columnspan 2 -sticky nswe
		grid $w.defaults.list -row 1 -column 0 -rowspan 2 -sticky nswe
		grid $w.defaults.bar -row 1 -column 1 -rowspan 2 -sticky nswe
		grid $w.defaults.edit -row 0 -column 2 -rowspan 2 -sticky nswe
		grid $w.defaults.buttons -row 2 -column 2 -sticky nswe
		grid columnconfigure $w.defaults 2 -weight 1
		grid rowconfigure $w.defaults 1 -weight 1
	}
	$w.defaults.type set app
	$object _filldefault
	$w.defaults.list activate 0
	$w.defaults.list selection set 0
	$object _configuredefault
}

Classy::Configurator method _changedefault {} {
	set w [getprivate $object w]
	set type [$w.defaults.type get]
	set name [$w.defaults.list get [$w.defaults.list curselection]]
	set value [lremove [split [$w.defaults.edit get 1.0 end] "\n"] {}]
	if {"$value" == ""} {
		catch {::Classy::Default unset $type $name}
	} else {
		::Classy::Default set $type $name $value
	}
}

Classy::Configurator method _filldefault {} {
	set w [getprivate $object w]
	$w.defaults.list delete 0 end
	$w.defaults.edit delete 1.0 end
	set type [$w.defaults.type get]
	eval $w.defaults.list insert end [::Classy::Default names $type]
}

Classy::Configurator method _configuredefault {{name {}}} {
	set w [getprivate $object w]
	update idletasks
	if {"$name" == ""} {
		set pos [$w.defaults.list curselection]
		if {"$pos" == ""} return
		set name [$w.defaults.list get $pos]
	}
	if {"$name" == ""} return
	set type [$w.defaults.type get]
	set list [::Classy::Default get $type $name]
	$w.defaults.edit delete 1.0 end
	foreach item $list {
		$w.defaults.edit insert end "$item\n"
	}
}
