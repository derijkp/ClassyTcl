#Functions

proc Classy::config args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .classy__.config
	}
	Classy::parseopt $args opt {-node {} {} -level {} {}}
	# Create windows
	Classy::Toplevel $window  \
		-resize {200 100}
	Classy::TreeWidget $window.browse \
		-width 160 \
		-height 50
	grid $window.browse -row 0 -column 0 -rowspan 2 -sticky nesw
	Classy::Paned $window.paned
	grid $window.paned -row 0 -column 1 -rowspan 2 -sticky nesw
	Classy::Selector $window.selector1 \
		-type color
	
	frame $window.frame  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $window.frame -row 1 -column 2 -columnspan 2 -sticky nesw
	Classy::Selector $window.frame.select \
		-type color
	grid $window.frame.select -row 2 -column 0 -sticky nesw
	Classy::Message $window.frame.descr \
		-highlightthickness 0 \
		-text message \
		-width 281
	grid $window.frame.descr -row 0 -column 0 -sticky nesw
	button $window.frame.button1 \
		-text button
	
	frame $window.frame.from  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $window.frame.from -row 1 -column 0 -sticky nesw
	Classy::Message $window.frame.from.msg \
		-highlightthickness 0 \
		-width 176
	grid $window.frame.from.msg -row 0 -column 0 -rowspan 2 -sticky nesw
	radiobutton $window.frame.from.radiobutton1 \
		-indicatoron 0 \
		-text Set \
		-value set \
		-variable Classy::Config_leveltype
	grid $window.frame.from.radiobutton1 -row 0 -column 1 -sticky nesw
	radiobutton $window.frame.from.radiobutton2 \
		-indicatoron 0 \
		-text Clear \
		-value clear \
		-variable Classy::Config_leveltype
	grid $window.frame.from.radiobutton2 -row 0 -column 2 -sticky nesw
	radiobutton $window.frame.from.radiobutton3 \
		-indicatoron 0 \
		-text {Dont Use} \
		-value comment \
		-variable Classy::Config_leveltype
	grid $window.frame.from.radiobutton3 -row 0 -column 3 -sticky nesw
	grid columnconfigure $window.frame.from 0 -weight 1
	grid rowconfigure $window.frame.from 1 -weight 1
	grid columnconfigure $window.frame 0 -weight 1
	grid rowconfigure $window.frame 2 -weight 1
	frame $window.level  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $window.level -row 0 -column 2 -columnspan 2 -sticky nesw
	button $window.level.button1 \
		-text button
	
	frame $window.level.pasted1  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $window.level.pasted1 -row 0 -column 0 -sticky nsw
	radiobutton $window.level.pasted1.pasted1 \
		-text Default \
		-value def \
		-variable Classy::config_level
	grid $window.level.pasted1.pasted1 -row 0 -column 3 -sticky nesw
	radiobutton $window.level.pasted1.pasted2 \
		-text User \
		-value user \
		-variable Classy::config_level
	grid $window.level.pasted1.pasted2 -row 0 -column 2 -sticky nesw
	radiobutton $window.level.pasted1.appdef1 \
		-text Application \
		-value appdef \
		-variable Classy::config_level
	grid $window.level.pasted1.appdef1 -row 0 -column 1 -sticky nesw
	radiobutton $window.level.pasted1.appuser1 \
		-text Final \
		-value appuser \
		-variable Classy::config_level
	grid $window.level.pasted1.appuser1 -row 0 -column 0 -sticky nesw
	Classy::DynaTool $window.level.dynatool1  \
		-type Classy::Config \
		-height 37
	grid $window.level.dynatool1 -row 1 -column 0 -sticky nesw
	grid columnconfigure $window.level 0 -weight 1
	grid columnconfigure $window 2 -weight 1
	grid rowconfigure $window 1 -weight 1

	# End windows
	# Parse this
	$window configure \
		-destroycommand 
	$window.browse configure \
		-endnodecommand [varsubst window {invoke node {Classy::config_open $window.browse $node}}] \
		-opencommand [varsubst window {invoke node {Classy::config_browse $window.browse $node}}] \
		-closecommand [varsubst window {invoke node {Classy::config_close $window.browse $node}}]
	$window.paned configure \
		-window [varsubst window {$window.browse}]
	$window.frame.select configure \
		-command [varsubst window {invoke {} {Classy::config_setleveltype $window set}}]
	$window.frame.from.radiobutton1 configure \
		-command [varsubst window {Classy::config_setleveltype $window set}]
	$window.frame.from.radiobutton2 configure \
		-command [varsubst window {Classy::config_setleveltype $window clear}]
	$window.frame.from.radiobutton3 configure \
		-command [varsubst window {Classy::config_setleveltype $window comment}]
	$window.level.pasted1.pasted1 configure \
		-command [varsubst window {Classy::config_selectlevel $window def}]
	$window.level.pasted1.pasted2 configure \
		-command [varsubst window {Classy::config_selectlevel $window user}]
	$window.level.pasted1.appdef1 configure \
		-command [varsubst window {Classy::config_selectlevel $window appdef}]
	$window.level.pasted1.appuser1 configure \
		-command [varsubst window {Classy::config_selectlevel $window appuser}]
	$window.level.dynatool1 configure \
		-cmdw [varsubst window {$window}]
# ClassyTcl Finalise
Classy::config_start $window
if [llength $opt(-node)] {
	Classy::config_open $window.browse $opt(-node)
}
if [llength $opt(-level)] {
	Classy::config_selectlevel $window $opt(-level)
}
	return $window
	return $window
	return $window
}

proc Classy::config_saveas window {
	set file [Classy::savefile]
	if ![string length $file] return
	set level $::Classy::config_level
	set data [Classy::config_get $level {}]
	writefile $file $data
}

proc Classy::config_start window {
	upvar #0 ::Classy::config conf
	if [info exists conf(tree)] {
		foreach node [structlfields $conf(tree)] {
			catch {$window.browse deletenode $node}
		}
	}
	catch {unset conf}
	set conf(tree) ""
	foreach level {def user appdef appuser} {
		set file [file join $::Classy::dir($level) init.conf]
		if [file readable $file] {
			Classy::config_loadfile $file $level
		}
	}
	set fields {Colors Fonts Keys Mouse Misc Toolbars Menus}
	foreach field [structlfields $conf(tree)] {
		laddnew fields $field
	}
	foreach field $fields {
		if [catch {Classy::geticon config_$field} icon] {
			set icon [Classy::geticon config_Unknown]
		}
		$window.browse addnode {} $field -text $field -image $icon
	}
	set w [winfo parent $window].frame
	set ::Classy::config_level appuser
}

proc Classy::config_browse {window node} {
upvar ::Classy::config conf
foreach field [structlfields $conf(tree) $node] {
	set type [lindex $node 0]
	if [catch {Classy::geticon config_$type} icon] {
		set icon [Classy::geticon config_Unknown]
	}
	set newnode $node
	lappend newnode $field
	set id [structlget $conf(tree) $newnode]
	if {[llength $id] != 1} {
		$window addnode $node $newnode -text $field -image $icon
	} else {
		$window addnode $node $newnode -type end -text $field -image $icon
	}
}
set conf(cnode) $node
set conf(cdescr) "Sub node"
set conf(ckey) ""
set conf(cvalue) ""
set conf(ctype) line
}

proc Classy::config_close {window node} {
	upvar ::Classy::config conf
	$window clearnode $node
	set conf(cnode) $node
	set conf(cdescr) "Sub node"
	set conf(ckey) ""
	set conf(ctype) line
}

proc Classy::config_open {window node} {
	upvar ::Classy::config conf
	set len [llength $node]
	if !$len return
	set w [winfo parent $window]
	if {$len > 1} {
		incr len -1
		for {set i 0} {$i < $len} {incr i} {
			catch {Classy::config_browse $window [lrange $node 0 $i]}
		}
	}
	$window selection clear
	$window selection add $node
	if [catch {structlget $conf(tree) $node} id] {
		error "Configuration node \"$node\" not found"
	}
	$w.frame.descr configure -text $conf($id,descr)
	set type $conf($id,type)
	set list {int line text color font key mouse anchor justify bool orient relief select sticky}
	if {[lsearch $list [lindex $type 0]] == -1} {
		set type text
	}
	$w.frame.select configure -type $type -label [lindex $node end]
	set conf(id) $id
	if ![info exists ::Classy::config_level] {set ::Classy::config_level appuser}
	Classy::config_selectlevel $w $::Classy::config_level
	set conf(node) $node
	set conf(cnode) $node
	set conf(ckey) $conf($id,key)
	set conf(cdescr) $conf($id,descr)
	set conf(ctype) $type
}

proc Classy::config_selectlevel {w level} {
	upvar #0 ::Classy::config conf
	set ::Classy::config_level $level
	if ![info exists conf(id)] return
	set conf(value) ""
	set conf(level) ""
	set from $w.frame.from.msg
	foreach clevel {def user appdef appuser} {
		if [info exists conf($conf(id),value,$clevel)] {
			set conf(value) $conf($conf(id),value,$clevel)
			set conf(clevel) $clevel
		}
		if {"$clevel" == "$level"} break
	}
	$w.frame.descr configure -bg [Classy::realcolor Background]
	$w.frame.select configure -bg [Classy::realcolor Background]
	$w.frame.from configure -bg [Classy::realcolor Background]
	$w.frame.from.msg configure -bg [Classy::realcolor Background]
	if {"$level" == "def"} {
		set state disabled
	} elseif {"$level" == "appdef"} {
		if ![info exists conf($conf(id),value,def)] {
			set state disabled
		} else {
			set state normal
		}
	} else {
		set state normal
	}
	$w.frame.from.radiobutton2 configure -state $state
	if [info exists conf($conf(id),value,$conf(clevel))] {
		if [info exists conf($conf(id),comment,$level)] {
			if {"$level" != "def"} {
				$from configure -text "defined but not used, value from earlier level will be used instead"
			} else {
				$from configure -text "defined but not used, Tcl default be used instead"
			}
			set conf_leveltype comment
			$w.frame.descr configure -bg [Classy::realcolor darkBackground]
			$w.frame.select configure -bg [Classy::realcolor darkBackground]
			$w.frame.from configure -bg [Classy::realcolor darkBackground]
			$w.frame.from.msg configure -bg [Classy::realcolor darkBackground]
		} else {
			$from configure -text "defined at this level"
			set conf_leveltype set
		}
	} else {
		if [info exists conf($conf(id),comment,$conf(clevel))] {
			$from configure -text "inherited from earlier level, but not used"
			set conf_leveltype clear
			$w.frame.descr configure -bg [Classy::realcolor darkBackground]
			$w.frame.select configure -bg [Classy::realcolor darkBackground]
			$w.frame.from configure -bg [Classy::realcolor darkBackground]
			$w.frame.from.msg configure -bg [Classy::realcolor darkBackground]
		} else {
			$from configure -text "inherited from earlier level"
			set conf_leveltype clear
		}
	}
	$w.frame.select set $conf(value)
}

proc Classy::config_setleveltype {window type} {
	upvar #0 ::Classy::config conf
	Classy::config_setoption $type $::Classy::config_level $conf(id) [$window.frame.select get]
	Classy::config_selectlevel $window $::Classy::config_level
}

proc Classy::config_reset window {
	upvar #0 ::Classy::config conf
	set node $conf($conf(id),pos)
	Classy::config_start $window
	Classy::config_open $window.browse $node
}

proc Classy::config_load window {
	set file [Classy::selectfile]
	if ![string length $file] return
	Classy::config_loadfile $file $::Classy::config_level reload
	Classy::config_redraw $window
}

proc Classy::config_save window {
putsvars window
	upvar #0 ::Classy::config conf
	foreach level {def user appdef appuser} {
		set conf(forsave) ""
		set data [Classy::config_get $level {}]
		set file [file join $::Classy::dir($level) init.conf]
		if [catch {writefile $file $data} result] {
			set msg "Could not save $type data at level "
			append msg [replace $level {def Default user User appdef Application appuser Final}]
			append msg ":\n$result\n\ncontinue saving?"
			if [Classy::yorn $msg] {
				continue
			} else {
				break
			}
		} else {
			foreach name $conf(forsave) {
				catch {unset conf($name)}
			}
		}
	}
	set file [file join $::Classy::dir(appuser) config.cache]
}

proc Classy::config_test window {
upvar #0 ::Classy::config conf
foreach name [array names conf *,testchanged] {
	regsub {,testchanged$} $name {} id
	set type $conf($id,type)
	set key $conf($id,key)
	if [info exists conf($id,value)] {
		switch $type {
			color - font - mouse - menu - toolbar {
				set [set type]($key) $conf($id,value)
			}
			key {
				set keys($key) $conf($id,value)
			}
			default {set fconf($key) $conf($id,value)}
		}
	}
	unset conf($name)
}
if [info exists color] {
	set all 0
	foreach option {
		Background darkBackground lightBackground Foreground activeBackground activeForeground 
		disabledForeground selectBackground selectForeground selectColor highlightBackground highlightColor
	} {
		catch {unset conf(*$option,colors)}
		if [info exists color(*$option)] {
			foreach {type key value} $color(*$option) {}
			option add *$option [Classy::realcolor $color(*$option)] widgetDefault
			unset color(*$option)
			set all 1
		} else {
			option add *$option [Classy::realcolor $option] widgetDefault
		}
	}
	if {$all} {
		foreach name [array names conf *,colors] {
			regsub {,colors$} $name {} id
			set key $conf($id,key)
			if [info exists conf($id,value)] {
				option add $key [Classy::realcolor $conf($id,value)] widgetDefault
			}
		}
	} else {
		foreach key [array names color] {
			option add $key [Classy::realcolor $color($key)] widgetDefault
		}
	}
	Classy::config_reconfigurecolor .
}
if [info exists font] {
	set all 0
	foreach option {Font BoldFont ItalicFont BoldItalicFont NonPropFont} {
		catch {unset conf(*$option,fonts)}
		if [info exists font(*$option)] {
			option add *$option [Classy::realfont $font(*$option)] widgetDefault
			unset font(*$option)
			set all 1
		} else {
			option add *$option [Classy::realfont $option] widgetDefault
		}
	}
	if {$all} {
		foreach name [array names conf *,fonts] {
			regsub {,fonts$} $name {} id
			set key $conf($id,key)
			if [info exists conf($id,value)] {
				option add $key [Classy::realfont $conf($id,value)] widgetDefault
			}
		}
	} else {
		foreach key [array names font] {
			option add $key [Classy::realfont $font($key)] widgetDefault
		}
	}
	Classy::config_reconfigurefont .
}
if [info exists mouse] {
	foreach {name pre num} {Action {} 1 Adjust {} 2 Menu {} 3 MAdd Control- 1 MExtend Shift- 1} {
		if [info exists mouse(<<$name>>)] {
			foreach {type key value} $mouse(<<$name>>) {}
			regexp {^<(.*)([0-9]+)>$} $value temp pre num
			unset mouse(<<$name>>)
		}
		event delete <<$name>>
		event add <<$name>> <$pre$num>
		regsub {Button-} $pre {} pre
		foreach combo {
			ButtonRelease ButtonPress
		} {
			event delete <<$name-$combo>>
			event add <<$name-$combo>> <${pre}$combo-$num>
		}
		foreach combo {
			Motion Leave Enter
		} {
			event delete <<$name-$combo>>
			event add <<$name-$combo>> <${pre}B$num-$combo>
		}
	}
}
if [info exists key] {
	foreach key [array names keys] {
		event delete $key
		eval {event add $key} $keys($key)
	}
}
if [info exists menu] {
	foreach key [array names menu] {
		Classy::DynaMenu define $key $menu($key)
	}
}
if [info exists toolbar] {
	foreach key [array names toolbar] {
		Classy::DynaTool define $key $toolbar($key)
	}
}
foreach key [array names fconf] {
	option add $key $fconf($key) widgetDefault
}
}

proc Classy::config_loadfile {file level {reload {}}} {
	upvar #0 ::Classy::config conf
	if ![info exists conf(lastid)] {
		set conf(lastid) 0
	}
	set f [open $file]
	while {![eof $f]} {
		set line [gets $f]
		if ![string length $line] continue
		set pos [string trimleft $line "# "]
		if [catch {structlget $conf(tree) $pos} id] {
			incr conf(lastid)
			set id $conf(lastid)
			set conf(tree) [structlset $conf(tree) $pos $id]
		}
		set descr [string trimleft [gets $f] "# "]
		set line [gets $f]
		while {![eof $f]} {
			set l [gets $f]
			if ![string length $l] break
			append line \n$l
		}
		if {"[string index $line 0]" == "#"} {
			set line [string range $line 1 end]
			set action comment
		} else {
			set action set
		}
		if [catch {foreach {type key value} $line {}}] {
			error "error in configuration file \"$file\" at \"$line\""
		}
		set conf($id,pos) $pos
		set conf($id,key) $key
		if [string length $reload] {
			Classy::config_setoption $action $level $id $value
		} else {
			if {"$action" == "comment"} {
				set conf($id,comment,$level) 1
			} else {
				catch {unset conf($id,comment,$level)}
				set conf($id,value) $value
			}
			set conf($id,type) $type
			switch $type {
				color {set conf($id,colors) 1}
				font {set conf($id,fonts) 1}
			}
			set conf($id,descr) $descr
			set conf($id,value,$level) $value
		}
	}
	close $f
}

proc Classy::config_redraw window {
upvar ::Classy::config conf
set selection [lindex [$window.browse selection] 0]
foreach node [$window.browse children {}] {
	$window.browse deletenode $node
}
set fields {Colors Fonts Keys Mouse Misc Toolbars Menus}
foreach field [structlfields $conf(tree)] {
	laddnew fields $field
}
foreach field $fields {
	if [catch {Classy::geticon config_$field} icon] {
		set icon [Classy::geticon config_Unknown]
	}
	$window.browse addnode {} $field -text $field -image $icon
}

set end [lpop selection]
catch {
	set current ""
	foreach node $selection {
		lappend current $node
		Classy::config_browse $window.browse $current
	}
	$window.browse selection clear
	lappend current $end
	Classy::config_open $window.browse $current
}

}

proc Classy::config_clear {window levels} {
upvar ::Classy::config conf
if ![Classy::yorn "Are you sure you want to clear all values at this level?"] return
foreach level $levels {
	foreach name [array names conf *,$level] {
		if [regsub ,value,$level\$ $name {} id] {
			Classy::config_setoption clear $level $id
		}
		catch {unset conf($name)}
	}
}
Classy::config_selectlevel $window $::Classy::config_level
}

proc Classy::config_reconfigurefont list {
	foreach w $list {
		if ![catch {$w _reconfigure}] return
		set children [winfo children $w]
		if {"$children" != ""} {
			Classy::config_reconfigurefont $children
		}
		catch {set list [$w configure -font]}
		catch {$w configure -font [option get $w [lindex $list 1] [lindex $list 2]]}
	}
}

proc Classy::config_reconfigurecolor list {
	foreach w $list {
		if ![catch {$w _reconfigure}] return
		set children [winfo children $w]
		if {"$children" != ""} {
			Classy::config_reconfigurecolor $children
		}
		foreach option {
				-activebackground -activeforeground -background -disabledforeground -forground
				-highlightbackground -highlightcolor -insertbackground -selectbackground
				-selectforeground -troughcolor 
		} {
			catch {
				set list [$w configure $option]
				$w configure $option [option get $w [lindex $list 1] [lindex $list 2]]
			}
		}
	}
}

proc Classy::config_setoption {type level id {value {}}} {
	upvar #0 ::Classy::config conf
	set conf($id,$level,changed) 1
	set conf($id,testchanged) 1
	switch $type {
		set {
			set conf($id,value,$level) $value
			catch {unset conf($id,comment,$level)}
		}
		clear {
			catch {unset conf($id,value,$level)}
		}
		comment {
			set conf($id,value,$level) $value
			set conf($id,comment,$level) 1
		}
	}
	catch {unset conf($id,value)}
	foreach level {def user appdef appuser} {
		if [info exists conf($id,value,$level)] {
			if ![info exists conf($id,comment,$level)] {
				set conf($id,value) $conf($id,value,$level)
			}
		}
	}
}

proc Classy::config_get {level root} {
	upvar #0 ::Classy::config conf
	set result ""
	foreach sub [structlfields $conf(tree) $root] {
		set ssub [concat $root [list $sub]]
		if [catch {structlfields $conf(tree) $ssub}] {
			set id [structlget $conf(tree) $ssub]
			if [info exists conf($id,$level,changed)] {
				lappend conf(forsave) $id,$level,changed
			}
			if [info exists conf($id,value,$level)] {
				set key $conf($id,key)
				append result "# $conf($id,pos)\n"
				append result "# $conf($id,descr)\n"
				if [info exists conf($id,comment,$level)] {
					append result "#"
				}
				append result [list $conf($id,type) $key $conf($id,value,$level)]
				append result "\n\n"
			}
		} else {
			append result [Classy::config_get $level $ssub]
		}
	}
	return $result
}

proc Classy::configedit args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .classy__.configedit
	}
	Classy::parseopt $args opt {-configwindow {} .classy__.config}
	# Create windows
	Classy::Toplevel $window  \
		-title {Edit configuration}
	Classy::Entry $window.entry1 \
		-labelwidth 10 \
		-label Node \
		-textvariable Classy::config(cnode) \
		-width 20
	grid $window.entry1 -row 0 -column 0 -columnspan 3 -sticky nesw
	Classy::Entry $window.entry2 \
		-labelwidth 10 \
		-label Key \
		-textvariable Classy::config(ckey) \
		-width 4
	grid $window.entry2 -row 2 -column 0 -columnspan 3 -sticky nesw
	Classy::Entry $window.entry3 \
		-labelwidth 10 \
		-label Description \
		-textvariable Classy::config(cdescr) \
		-width 4
	grid $window.entry3 -row 1 -column 0 -columnspan 3 -sticky nesw
	button $window.button1 \
		-text Add
	grid $window.button1 -row 4 -column 0
	button $window.button2 \
		-text Delete
	grid $window.button2 -row 4 -column 1
	Classy::Selector $window.selector1 \
		-label Type \
		-orient vertical \
		-type {select line text bool int color font key mouse relief orient justify select} \
		-variable Classy::config(ctype)
	grid $window.selector1 -row 3 -column 0 -columnspan 3 -sticky nesw
	button $window.button3 \
		-text Close
	grid $window.button3 -row 4 -column 2
	grid columnconfigure $window 0 -weight 1
	grid columnconfigure $window 1 -weight 1
	grid columnconfigure $window 2 -weight 1

	# End windows
	# Parse this
	$window configure \
		-destroycommand
	$window.entry1 configure \
		-command [list Classy::config_movenode $opt(-configwindow)]
	$window.entry2 configure \
		-command [list Classy::config_changenode $opt(-configwindow) key]
	$window.entry3 configure \
		-command [list Classy::config_changenode $opt(-configwindow) descr]
	$window.button1 configure \
		-command [list Classy::config_addnode $opt(-configwindow)]
	$window.button2 configure \
		-command [list Classy::config_deletenode $opt(-configwindow)]
	$window.selector1 configure \
		-command [list Classy::config_changenode $opt(-configwindow) type]
	$window.button3 configure \
		-command [varsubst window {destroy $window}]
	return $window
}

proc Classy::config_movenode {window tonode} {
upvar #0 ::Classy::config conf
set node $::Classy::config(node)
#set tonode $::Classy::config(cnode)
if [catch {structlget $conf(tree) $node} id] {
	error "Node \"$node\" does not exist"
}
if {[llength $id] != 1} {
	error "Node \"$node\" is not an endnode"
}
if ![catch {structlget $conf(tree) $tonode}] {
	error "Node \"$tonode\" already exist"
}

if ![Classy::yorn "Are you sure you want to move node \n\"$node\"\nto\n\"$tonode\""] return
set conf($id,pos) $tonode
set conf(tree) [structlunset $conf(tree) $node]
set conf(tree) [structlset $conf(tree) $tonode $id]
Classy::config_redraw $window
set selection $tonode
set end [lpop selection]
catch {
	set current ""
	foreach node $selection {
		lappend current $node
		catch {Classy::config_browse $window.browse $current}
	}
	$window.browse selection clear
	lappend current $end
	Classy::config_open $window.browse $current
}

}

proc Classy::config_addnode window {
upvar #0 ::Classy::config conf
set level $::Classy::config_level
set node $conf(cnode)
set descr $conf(cdescr)
set key $conf(ckey)
set value $conf(cvalue)
set type $conf(ctype)
set id $conf(lastid)
incr conf(lastid)
if ![catch {structlget $conf(tree) $node}] {
	error "Cannot create node \"$node\": already exists"
}
set parent $node
lpop parent
if ![llength $parent] {
	error "root can only contain subnodes"
}
#if ![catch {set temp [structlfields $conf(tree) $parent]}] {
#	if ![catch {structlfields $conf(tree) [concat $parent [list [lindex $temp 0]]]}] {
#		error "node \"$parent\" already contains subnodes, so you cannot add a value to it"
#	}
#}
set conf(tree) [structlset $conf(tree) $node $id]
set conf($id,pos) $node
set conf($id,value) $value
set conf($id,type) $type
switch $type {
	color {set conf($id,colors) 1}
	font {set conf($id,fonts) 1}
}
set conf($id,descr) $descr
set conf($id,value,$level) $value
Classy::config_redraw $window
set selection $node
set end [lpop selection]
catch {
	set current ""
	foreach node $selection {
		lappend current $node
		catch {Classy::config_browse $window.browse $current}
	}
	$window.browse selection clear
	lappend current $end
	Classy::config_open $window.browse $current
}
}

proc Classy::config_deletenode {window {node {}}} {
upvar #0 ::Classy::config conf
if ![llength $node] {
	set node $::Classy::config(cnode)
}
if [catch {structlget $conf(tree) $node} id] {
	error "Node \"$node\" does not exist"
}
if {[llength $id] != 1} {
	set fields [structlfields $id {}]
	foreach field $fields {
		Classy::config_deletenode $window [concat $node [list $field]]
	}
	if ![llength [structlget $conf(tree) $node]] {
		set conf(tree) [structlunset $conf(tree) $node]
	}
}
if ![Classy::yorn "Are you sure you want to delete node \"$node\""] return
catch {unset conf($id,pos)}
catch {unset conf($id,value)}
catch {unset conf($id,type)}
catch {unset conf($id,descr)}
foreach level {def user appdef appuser} {
	if ![catch {unset conf($id,value,$level)}] {
		set conf([lindex $node 0],$level,deleted) 1
	}
	catch {unset conf($id,comment,$level)}
}
set conf(tree) [structlunset $conf(tree) $node]
Classy::config_redraw $window
}

proc Classy::config_changenode {window what value} {
upvar #0 ::Classy::config conf
set id $conf(id)
switch $what {
	descr - type {
		set conf($id,$what) $value
	}
	key {
		foreach item {pos value type descr} {
			set conf($value,$item) $conf($id,$item)
			unset conf($id,$item)
		}
		set node $conf($value,pos)
		set conf(tree) [structlset $conf(tree) $node $value]
		foreach level {def user appdef appuser} {
			catch {
				set conf($value,value,$level) $conf($id,value,$level)
				unset conf($id,value,$level)
			}
			catch {
				set conf($value,comment,$level) $conf($id,comment,$level)
				unset conf($id,comment,$level)
			}
		}
	}
}
Classy::config_redraw $window
}

proc Classy::config_destroy window {
upvar #0 ::Classy::config conf
if [llength [array names conf *,changed]] {
	if ![Classy::yorn "Some changes have not been saved, close anyway ?"] return
}
destroy $window
}


