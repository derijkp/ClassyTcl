proc Classy::config_edit_new {} {
	return {
		Menus {
			Application {
				Main {_menu MainMenu {Application main menu}}
			}
		}
		Toolbars {
			Application {
				Main {_menu MainToolbar {Application main toolbar}}
			}
		}
	}
}

proc Classy::config_edit_pos {pos} {
	upvar #0 Classy::configedit configedit
	set w .classy__.configedit.options
	set tpos $pos
	set tail [list_pop tpos]
	set data [structlist_get $configedit(data) $tpos]
	$w.edit.name configure -state normal
	$w.edit.type configure -state normal
	$w.edit.key configure -state normal
	$w.edit.descr configure -state normal
	$w.edit.value configure -state normal
	if ![llength $data] {
		$w.list delete 0 end
		$w.edit.name nocmdset {}
		$w.edit.type nocmdset {}
		$w.edit.key nocmdset {}
		$w.edit.descr set {}
		$w.edit.value set {}
		$w.edit.name configure -state disabled
		$w.edit.type configure -state disabled
		$w.edit.key configure -state disabled
		$w.edit.descr configure -state disabled
		$w.edit.value configure -state disabled
	}
	if [regexp ^_ [lindex $data 0]] {
		list_pop pos
		set tpos $pos
		set tail [list_pop tpos]
		set data [structlist_get $configedit(data) $tpos]
	}	
	if [string length $tail] {
		set num [lsearch [structlist_fields $data] $tail]
		if {$num == -1} {error "Position \"$pos\" does not exist"}
	} else {
		set num 0
		set tail [lindex $data 0]
		set pos $tpos
		lappend pos $tail
	}
	set configedit(current) $pos
	set tdata [structlist_get $configedit(data) $pos]
	$w.label configure -text "Current Position: $tpos"
	set fields [structlist_fields $data]
	$w.list delete 0 end
	eval $w.list insert end $fields
	$w.list selection clear 0 end
	$w.list selection set $num
	if ![regexp ^_ [lindex $tdata 0]] {
		$w.edit.name nocmdset $tail
		$w.edit.type nocmdset submenu
		$w.edit.key nocmdset {}
		$w.edit.descr set {}
		$w.edit.value set {}
		$w.edit.type configure -state disabled
		$w.edit.key configure -state disabled
		$w.edit.descr configure -state disabled
		$w.edit.value configure -state disabled
	} else {
		foreach {type key descr def} $tdata break
		regsub ^_ $type {} type
		$w.edit.name nocmdset $tail
		$w.edit.type nocmdset $type
		$w.edit.key nocmdset $key
		$w.edit.descr set $descr
		switch $type {
			menu - toolbar {
				set type text
			}
		}
		$w.edit.value configure -type $type
		$w.edit.value set $def
	}
}

proc Classy::config_edit_item {args} {
puts config_edit_item
	upvar #0 Classy::configedit configedit
	set w .classy__.configedit.options
	set pos $configedit(current)
	lappend pos {}
	Classy::config_edit_pos $pos
}

proc Classy::config_edit_browse {args} {
puts config_edit_browse
	upvar #0 Classy::configedit configedit
	set w .classy__.configedit.options
	set tail [$w.list get active]
	set pos $configedit(current)
	set prev [list_pop pos]
	if [string_equal $prev $tail] {
		set pos $configedit(current)
		lappend pos {}
		Classy::config_edit_pos $pos
	} else {
		lappend pos $tail
		Classy::config_edit_pos $pos
	}
}

proc Classy::config_edit_parent {args} {
	upvar #0 Classy::configedit configedit
	set pos $configedit(current)
	set len [llength $pos]
	incr len -2
	Classy::config_edit_pos [lrange $pos 0 $len]
}

proc Classy::config_edit_add {name} {
	upvar #0 Classy::configedit configedit
	set pos $configedit(current)
	set tpos $pos
	set tail [list_pop tpos]
	set data [structlist_get $configedit(data) $tpos]
	if ![llength $data] {
		if [Classy::yorn "Add sublist? (value if no)"] {
			set sublist 1
		} else {
			set sublist 0
		}
	} elseif [regexp ^_ [lindex $data 1]] {
		set sublist 0
	} else {
		set sublist 1
	}
	set pfields [structlist_fields $data]
	set n [lsearch $pfields $tail]
	incr n
	set n [expr {$n * 2}]
	if $sublist {
		set data [linsert $data $n $name {}]
	} else {
		set data [linsert $data $n $name [list _text $name {description} {}]]
	}
	set configedit(data) [structlist_set $configedit(data) $tpos $data]
	lappend tpos $name
	Classy::config_edit_pos $tpos
}

proc Classy::config_edit_delete {} {
	upvar #0 Classy::configedit configedit
	set pos $configedit(current)
	set tpos $pos
	set tail [list_pop tpos]
	set data [structlist_get $configedit(data) $tpos]
	set pfields [structlist_fields $data]
	set n [lsearch $pfields $tail]
	set nname [lindex $pfields [expr {$n+1}]]
	if ![string length $nname] {
		set nname [lindex $pfields [expr {$n-1}]]
	}
	set n [expr {$n * 2}]
	set n2 [expr {$n+1}]
	set data [lreplace $data $n $n2]
	set configedit(data) [structlist_set $configedit(data) $tpos $data]
	list_pop pos
	lappend pos $nname
	Classy::config_edit_pos $pos
}

proc Classy::config_edit_move {step} {
	upvar #0 Classy::configedit configedit
	set pos $configedit(current)
	set tpos $pos
	set tail [list_pop tpos]
	set data [structlist_get $configedit(data) $tpos]
	set pfields [structlist_fields $data]
	set n [lsearch $pfields $tail]
	set max [expr {[llength $pfields]-1}]
	if {($step < 0)&&($n == 0)} return
	if {($step > 0)&&($n == $max)} return
	incr max -1
	if {($step > 0)&&($n == $max)} {set lappend 1}
	set n [expr {$n * 2}]
	set n2 [expr {$n+1}]
	set pdata [lrange $data $n $n2]
	set data [lreplace $data $n $n2]
	if [info exists lappend] {
		eval lappend data $pdata
	} else {
		incr n [expr {$step*2}]
		set data [eval {lreplace $data $n -1} $pdata]
	}
	set configedit(data) [structlist_set $configedit(data) $tpos $data]
	Classy::config_edit_pos $pos
}

proc Classy::config_edit_rename {name} {
	upvar #0 Classy::configedit configedit
	set pos $configedit(current)
	set tpos $pos
	set tail [list_pop tpos]
	set pdata [structlist_get $configedit(data) $tpos]
	set pfields [structlist_fields $pdata]
	set pos [lsearch $pfields $tail]
	set n [expr {$pos * 2}]
	set pdata [lreplace $pdata $n $n $name]
	set configedit(data) [structlist_set $configedit(data) $tpos $pdata]
	lappend tpos $name
	Classy::config_edit_pos $tpos
}

proc Classy::config_edit_retype {value} {
	upvar #0 Classy::configedit configedit
	set pos $configedit(current)
	set data [structlist_get $configedit(data) $pos]
	set data [lreplace $data 0 0 _$value]
	set configedit(data) [structlist_set $configedit(data) $pos $data]
	Classy::config_edit_pos $pos
}

proc Classy::config_edit_rekey {value} {
	upvar #0 Classy::configedit configedit
	set pos $configedit(current)
	set data [structlist_get $configedit(data) $pos]
	set data [lreplace $data 1 1 $value]
	set configedit(data) [structlist_set $configedit(data) $pos $data]
	Classy::config_edit_pos $pos
}

proc Classy::config_edit_redescr {value} {
	upvar #0 Classy::configedit configedit
	set pos $configedit(current)
	set data [structlist_get $configedit(data) $pos]
	set data [lreplace $data 2 2 $value]
	set configedit(data) [structlist_set $configedit(data) $pos $data]
	Classy::config_edit_pos $pos
}

proc Classy::config_edit_redef {value} {
	upvar #0 Classy::configedit configedit
	set pos $configedit(current)
	set data [structlist_get $configedit(data) $pos]
	set data [lreplace $data 3 3 $value]
	set configedit(data) [structlist_set $configedit(data) $pos $data]
	Classy::config_edit_pos $pos
}

proc Classy::config_edit_save {} {
	upvar #0 Classy::configedit configedit
	set file $configedit(file)
	if [file exists $file] {
		if ![Classy::yorn "Overwrite file \"$file\"?"] return
	}
	set f [open $file w]
	foreach {key value} $configedit(data) {
		puts $f [list $key $value]
	}
	close $f
	if [string length $configedit(cmd)] {
		uplevel #0 $configedit(cmd)
	}
}

proc Classy::config_edit_getdef {dir pos} {
	upvar #0 Classy::configedit configedit
	set result {}
	set data [structlist_get $configedit(data) $pos]
	foreach {field value} $data {
		if [regexp ^_ [lindex $value 0]] {
			foreach {type key descr def} $value break
			regsub ^_ $type {} type
			switch $type {
				menu {
					file_write [file join $dir menu $key] $def
				}
				toolbar {
					file_write [file join $dir toolbar $key] $def
				}
				default {
					lappend result $type,$key $def
				}
			}
		} else {
			set tpos $pos
			lappend tpos $field
			eval lappend result [Classy::config_edit_getdef $dir $tpos]
		}
	}
	return $result
}

proc Classy::config_edit_create {} {
	upvar #0 Classy::configedit configedit
	set dir [file dir $configedit(file)]
	catch {file mkdir [file join $dir menu]}
	catch {file mkdir [file join $dir toolbar]}
	set file [file join $dir conf.values]
	if [file exists $file] {
		if ![Classy::yorn "Overwrite file \"$file\"?"] return
	}
	set result [Classy::config_edit_getdef $dir {}]
	set f [open $file w]
	foreach {key value} $result {
		puts $f [list $key $value]
	}
	close $f
}

proc Classy::config_edit {{file {}} {cmd {}}} {
	upvar #0 Classy::configedit configedit
	if ![string length $file] {
		set file [file join $::Classy::dir(appdef) conf.descr]
	}
	set configedit(cmd) $cmd
	set configedit(file) $file
	set w .classy__.configedit
	catch {destroy $w}
	Classy::Dialog $w -title $file -help classy_configedit
	$w configure -closecommand {}
	$w add save Save [list Classy::config_edit_save]
	$w add create Create [list Classy::config_edit_create]
	set w .classy__.configedit.options
	label $w.label -text "Current Position:" -anchor w -justify left
	frame $w.buttons
	button $w.buttons.parent -text Parent -command [list Classy::config_edit_parent]
	button $w.buttons.sublist -text Sublist -command [list Classy::config_edit_item]
	button $w.buttons.moveup -text Up -command [list Classy::config_edit_move -1]
	button $w.buttons.movedown -text Down -command [list Classy::config_edit_move 1]
	button $w.buttons.delete -text Delete -command [list Classy::config_edit_delete]
	Classy::Entry $w.buttons.add -label Add -command [list Classy::config_edit_add]
	pack $w.buttons.parent $w.buttons.sublist $w.buttons.moveup $w.buttons.movedown $w.buttons.delete -side left
	pack $w.buttons.add -side left -fill x -expand yes
	Classy::ListBox $w.list -exportselection no
	frame $w.edit -bd 2 -relief groove
	grid $w.label -column 0 -row 0 -columnspan 2 -sticky we
	grid $w.buttons -column 0 -row 1 -columnspan 2 -sticky we
	grid $w.list -column 0 -row 2 -sticky ns
	grid $w.edit -column 1 -row 2 -sticky nswe
	grid columnconfigure $w 1 -weight 1
	grid rowconfigure $w 2 -weight 1
	$w.list configure \
		-browsecommand [list Classy::config_edit_browse]
	Classy::Entry $w.edit.name -labelwidth 5 -label "Name" \
		-command [list Classy::config_edit_rename]
	Classy::Entry $w.edit.type -labelwidth 5 -label "Type" -combo 10 \
		-combopreset {echo {menu toolbar bool int text select key mouse color font}} \
		-command [list Classy::config_edit_retype]
	Classy::Entry $w.edit.key -labelwidth 5 -label "Key" \
		-command [list Classy::config_edit_rekey]
	Classy::Selector $w.edit.descr -label "Description" -type text \
		-command [list Classy::config_edit_redescr]
	Classy::Selector $w.edit.value -label "Default value" -type text \
		-command [list Classy::config_edit_redef]
	pack $w.edit.name -fill x
	pack $w.edit.type -fill x
	pack $w.edit.key -fill x
	pack $w.edit.descr -fill x
	pack $w.edit.value -fill both -expand yes
	# Data
	if [file exists $file] {
		set data [file_read $file]
	} else {
		set data {
			Menus {
				Application {
					Main {_menu MainMenu {Application main menu}}
				}
			}
			Toolbars {
				Application {
					Main {_menu MainToolbar {Application main toolbar}}
				}
			}
		}
	}
	set configedit(data) $data
	Classy::config_edit_pos {{}}
}
