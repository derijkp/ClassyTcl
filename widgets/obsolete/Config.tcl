#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Config
# ----------------------------------------------------------------------
#doc Config title {
#Config
#} index {
# Common tools
#} shortdescr {
# class used in the <a href="../classy_configure.html">configuration system</a>
#} descr {
# The <a href="../classy_configure.html">configuration system</a> is quite extensive, but 
# does not have extensive documentation (yet). This class provides some commands used here.
#}
#doc {Config command} h2 {
#	Config methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Config {} {}
proc Config {} {}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Config
Classy::export Config {}

Classy::Config classmethod init {args} {
	super init
	Classy::OptionMenu $object.select
	message $object.help
	grid columnconfigure $object 1 -weight 1
	grid rowconfigure $object 1 -weight 1
	# REM Initialise options and variables
	# ------------------------------------
	# REM Create bindings
	# --------------------
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	update idletasks
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::Config addoption -closecommand {closeCommand CloseCommand {}} {
}

# ------------------------------------------------------------------
#  destroy
# ------------------------------------------------------------------

Classy::Config method destroy {} {
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Config method loadinfile {file name} {
	set f [open $file]
	gets $f
	while 1 {
		if [eof $f] {return -code error "Could not find \"$name\" in file \"$file\""}
		set line [getcomplete $f]
		if [regexp {Classy::config} $line] {
			set cname [lindex $line 1]
			if {"$name" == ""} break
			if {"$cname" == "$name"} break
		}
	}
	close $f
	return $line
}

Classy::Config method saveinfile {file name code} {
	catch {file delete ${file}~}
	if ![file exists $file] {writefile $file ""}
	file copy $file ${file}~
	set f [open ${file}~]
	set o [open $file w]
	set done 0
	while {![eof $f]} {
		set line [getcomplete $f]
		if [regexp {Classy::config} $line] {
			set cname [lindex $line 1]
			if {"$cname" == "$name"} {
				puts $o $code
				set done 1
			} else {
				puts $o $line
			}
		} else {
			puts $o $line
		}
	}
	if !$done {
		puts $o $code
		puts $o "\n"
	}
	close $o
	close $f
}

Classy::Config method deleteinfile {file name} {
	catch {file delete ${file}~}
	if ![file exists $file] {writefile $file ""}
	file copy $file ${file}~
	set f [open ${file}~]
	set o [open $file w]
	while {![eof $f]} {
		set line [getcomplete $f]
		if [regexp {Classy::config} $line] {
			set cname [lindex $line 1]
			if {"$cname" != "$name"} {
				puts $o $line
			}
		} else {
			puts $o $line
		}
	}
	close $o
	close $f
}

Classy::Config method collect {level type} {
	set file [file join $::Classy::dir($level) init $type.tcl]
	if ![file exists $file] {return ""}
	set result ""
	set f [open $file]
	while {![eof $f]} {
		set line [getcomplete $f]
		if [regexp {^Classy::config([^ ]+) } $line temp type] {
			set func [lindex "$line" 1]
			lappend result $func
		}
	}
	close $f
	return $result
}

Classy::Config method collectall {level type} {
	array set temp {
		appuser {appuser appdef user def}
		appdef {appdef user def}
		user {user def}
		def def
	}
	set result ""
	foreach t $temp($level) {
		set result [lunion $result [$object collect $t $type]]
	}
	return $result
}

Classy::Config method browse {w name} {
	set len [llength $name]
	set list {Colors color Fonts font Keys key Mouse mouse Misc misc Toolbars tool Menus menu}
	switch $len {
		1 {
			foreach {text type} $list {
				$w addnode $name [list $name $text] -text $text -image [Classy::geticon config_$type]
			}
		}
		2 {
			foreach item [$object collectall [lindex $name 0] [lindex $name 1]] {
				$w addnode $name [eval list $name {$item}] \
					-type end -text $item -image [Classy::geticon config_[structlget $list [lindex $name 1]]]
			}
		}
	}
}

Classy::Config method _reconfigurefont {list} {
	foreach w $list {
		if ![catch {$w _reconfigure}] return
		set children [winfo children $w]
		if {"$children" != ""} {
			$object _reconfigurefont $children
		}
		catch {set list [$w configure -font]}
		catch {$w configure -font [option get $w [lindex $list 1] [lindex $list 2]]}
	}
}

Classy::Config method _reconfigurecolor {list} {
	foreach w $list {
		if ![catch {$w _reconfigure}] return
		set children [winfo children $w]
		if {"$children" != ""} {
			$object _reconfigurecolor $children
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

Classy::Config method load {type level name var} {
	upvar #0 $var data
	catch {set close $data(close)}
	catch {unset data}
	catch {set data(close) $close}
	set data(names) ""
	set data(changed) 0
	if {"$level" == ""} {set level appuser}
	set data(level) $level
	catch {set type [structlget {color Colors font Fonts misc Misc mouse Mouse key Keys menu Menus tool Toolbars} $type]}
	switch $level {
		appuser - appdef - user - def {
			array set temp {
				appuser {appuser appdef user def}
				appdef {appdef user def}
				user {user def}
				def def
			}
			set found 0
			foreach t $temp($level) {
				set file [file join $::Classy::dir($t) init $type.tcl]
				if ![catch {$object loadinfile $file $name} line] {
					set found 1
					break
				}
			}
			unset temp
			if !$found {error "\"$name\" not found at level \"$level\""}
		}
		default {
			set file $level
			set line [$object loadinfile $file $name]
		}
	}
	set data(file) $file
	set data(name) [lindex $line 1]
	regexp {Classy::config([a-z]+)} $line temp data(type)
	set data(ltype) [structlget {color Colors font Fonts misc Misc mouse Mouse key Keys menu Menus tool Toolbars} $data(type)]
	switch $data(type) {
		font - color - key - mouse {
			set data(c) [lindex $line 2]
			foreach {name option value descr} $data(c) {
				if {"[string index $name 0]" == "#"} {
					set name [string range $name 1 end]
					set data($name,#) 1
				} else {
					set data($name,#) 0
				}
				lappend data(names) $name
				set data($name,option) $option
				set data($name,value) $value
				set data($name,descr) $descr
				set data($name,type) $data(type)
			}
			set data(Colorlist,type) text
		}
		misc {
			set data(c) [lindex $line 2]
			foreach {name option value type descr} $data(c) {
				if {"[string index $name 0]" == "#"} {
					set name [string range $name 1 end]
					set data($name,#) 1
				} else {
					set data($name,#) 0
				}
				lappend data(names) $name
				set data($name,option) $option
				set data($name,value) $value
				set data($name,type) $type
				set data($name,descr) $descr
			}
		}
		default {
			set data(help) [lindex $line 2]
			set data(c) [lindex $line 3]
		}
	}
}

Classy::Config method reconfigure {var} {
	upvar #0 $var data
	switch $data(type) {
		font {
			catch {unset ::Classy::configfont}
			Classy::initconf Fonts
			$object _reconfigurefont [winfo children .]
		}
		color {
			catch {unset ::Classy::configcolor}
			Classy::initconf Colors
			$object _reconfigurecolor [winfo children .]
		}
		key {
			Classy::initconf Keys
		}
		mouse {
			Classy::initconf Mouse
		}
		misc {
			Classy::initconf Misc
		}
		tool {
			Classy::initconf Toolbars
		}
		menu {
			Classy::initconf Menus
		}
	}
}

Classy::Config method test {var} {
	upvar #0 $var data
	set body [$object getbody $var]
	uplevel #0 $body
	catch {Classy::doconfig$data(type)}
	switch $data(type) {
		font - color {
			$object _reconfigure$data(type) [winfo children .]
		}
	}
}

Classy::Config method getbody {var} {
	upvar #0 $var data
	set body ""
	set type $data(type)
	switch $type {
		font - color - key - mouse {
			set body "Classy::config$type [list $data(name)] \{\n"
			foreach name $data(names) {
				if $data($name,#) {
					set rname "#$name"
				} else {
					set rname $name
				}
				append body "\t[list $rname $data($name,option) $data($name,value) $data($name,descr)]\n"
			}
			append body "\}"
		}
		misc {
			set body "Classy::config$type [list $data(name)] \{\n"
			foreach name $data(names) {
				if $data($name,#) {
					set rname "#$name"
				} else {
					set rname $name
				}
				append body "\t[list $rname $data($name,option) $data($name,value) $data($name,type) $data($name,descr)]\n"
			}
			append body "\}"
		}
		tool - menu {
			set body "Classy::config$type [list $data(name) $data(help) [$data(window).value get]]"
		}
		default {
			set body "Classy::config$type [list $data(name) $data(help) $data(c)]"
		}
	}
	return $body
}

Classy::Config method save {var {level {}} {named {}}} {
	upvar #0 $var data
	set body ""
	set type $data(type)
	if {"$level" == ""} {
		set level $data(level)
	}
	set body [$object getbody $var]
	switch $level {
		appuser - appdef - user - def {
			catch {set type [structlget {color Colors font Fonts misc Misc mouse Mouse key Keys menu Menus tool Toolbars} $type]}
			if {"$named" == ""} {
				set file [file join $::Classy::dir($level) init $type.tcl]
			} else {
				set dir [file join $::Classy::dir($level) opt $named]
				if ![file exists $dir] {file mkdir $dir}
				set file [file join $::Classy::dir($level) opt $named $type.tcl]
			}
		}
		default {
			set file $level
		}
	}
	$object saveinfile $file $data(name) $body
	set data(changed) 0
	catch {$data(window).value textchanged 0}
}

Classy::Config method clear {var} {
	upvar #0 $var data
	set type $data(type)
	set level $data(level)
	if ![Classy::yorn "Delete $data(name) at level $data(level)"] return
	switch $level {
		appuser - appdef - user - def {
			catch {set type [structlget {color Colors font Fonts misc Misc mouse Mouse key Keys menu Menus tool Toolbars} $type]}
			set file [file join $::Classy::dir($level) init $type.tcl]
		}
		default {
			set file $level
		}
	}
	catch {$object deleteinfile $file $data(name)}
	::Classy::Config restore $var $var
}

Classy::Config method redraw {var window} {
	upvar #0 $var data
	switch $data(type) {
		font - color - misc - key - mouse {
			set current [lindex [$window.list get] 0]
			$window.list configure -content $data(names)
			if {"$current" != ""} {
				$window.list activate $current
				$window.list set $current
			}
		}
		tool - menu {
			$window.value set $data(c)
			set data(window) $window
		}
	}
	set data(changed) 0
}

Classy::Config method restore {var window} {
	upvar #0 $var data
	::Classy::Config load $data(type) $data(level) $data(name) $var
	$object redraw $var $window
}

Classy::Config method select {var window} {
	upvar #0 $var data
	set names ""
	set name $data(name)
	foreach {t n} {
		appuser {Application user} appdef {Application default} 
		user {ClassyTcl user} def {ClassyTcl default}
	} {
		set file [file join $::Classy::dir($t) init $data(ltype).tcl]
		if ![catch {$object loadinfile $file $name}] {
			set files($n) $file
			lappend names $n
		}
		set pattern [file join $::Classy::dir($t) opt * $data(ltype).tcl]
		if ![catch {glob $pattern} f] {
			foreach file $f {
				if ![catch {$object loadinfile $file $name}] {
					set split [file split $file]
					set len [llength $split]
					set pre [lindex $split [expr {$len-2}]]
					set "files($pre $n)" $file
					lappend names "$pre $n"
				}
			}
		}
	}
	set select [Classy::select "Select configuration" $names]
	if {"$select" == ""} return
	set keep $data(level)
	$object load $data(type) $files($select) $data(name) $var
	set data(level) $keep
	set data(window) $window
	$object redraw $var $window
	set data(changed) 0
}

Classy::Config method saveas {var args} {
	upvar #0 $var data
	if {"$args" == ""} {
		Classy::config_saveas -variable $var -level $data(level)
		return
	}
	puts $args
	$object save $var [lindex $args 0] [lindex $args 1]
}

Classy::Config method browselist {var window current} {
	upvar #0 $var data
	if {"$current" == ""} return
	if ![info exists data($current,type)] return
	$window.frame.select configure -type $data($current,type) \
		-variable "::${var}($current,value)" \
		-label $current -orient vertical
	$window.frame.comment configure -variable "::${var}($current,#)"
	$window.frame.name configure -text $current
	$window.frame.help configure -text [set ::${var}($current,descr)]
	focus $window.list
	catch {$window.frame.advanced.content.text nocmdset $current}
	catch {$window.frame.advanced.content.pattern configure -textvariable "::${var}($current,option)"}
	catch {$window.frame.advanced.content.descr configure -textvariable "::${var}($current,descr)"}
	catch {$window.frame.advanced.content.type configure -variable "::${var}($current,type)"}
}

Classy::Config method remove {var window} {
	upvar #0 $var data
	set data(changed) 1
	set current [$window.list get active]
	set data(names) [lremove $data(names) $current]
	$window.list configure -content $data(names)
	$window.list activate 0
	$window.list selection set 0
}

Classy::Config method rename {var window new} {
	upvar #0 $var data
	set data(changed) 1
	set current [$window.list get active]
	set pos [lsearch $data(names) $current]
	if {$pos == -1} return
#	set new [$window.frame.advanced.content.text get]
	set data(names) [lreplace $data(names) $pos $pos $new]
	foreach {item} {option value descr type} {
		catch {set data($new,$item) $data($current,$item)}
		catch {unset data($current,$item)}
	}
	$window.list configure -content $data(names)
	$window.list activate $pos
	$window.list selection set $pos
}

Classy::Config method change {var window} {
	upvar #0 $var data
	set data(changed) 1
	set current [lindex [$window.list get] 0]
	set name [$window.frame.advanced.content.text get]
	if {"$name" != "$current"} {
		if {[lsearch $data(names) $name] != -1} {
			error "option \"$name\" exists"
		}
	}
	set pos [lsearch $data(names) $current]
	set data(names) [lreplace $data(names) $pos $pos $name]
	set data($name,value) $data($current,value)
	foreach field {option value descr type value} {
		unset data($current,$field)
	}
	set data($name,option) [$window.frame.advanced.content.pattern get]
	set data($name,descr) [$window.frame.advanced.content.descr get]
	set data($name,type) [$window.frame.advanced.content.type get]
	$window.list configure -content $data(names)
	$window.list activate $pos
	$window.list selection set $pos
}

Classy::Config method add {var window} {
	upvar #0 $var data
	set data(changed) 1
	set name [$window.frame.advanced.content.text get]
	if {[lsearch $data(names) $name] != -1} {
		error "pattern \"$name\" exists"
	}
	lappend data(names) $name
	set data($name,option) [$window.frame.advanced.content.pattern get]
	set data($name,value) ""
	set data($name,descr) [$window.frame.advanced.content.descr get]
	set data($name,type) [$window.frame.advanced.content.type get]
	$window.list configure -content $data(names)
	$window.list activate end
	$window.list selection set end
}

Classy::Config method move {dir var window} {
	upvar #0 $var data
	set data(changed) 1
	set current [$window.list get active]
	set pos [lsearch $data(names) $current]
	if {$pos == -1} return
	set to $pos
	switch $dir {
		up {incr to -1}
		down {incr to}
	}
	if {$to == -1} return
	if {$to >= [llength $data(names)]} return
	set data(names) [lreplace $data(names) $pos $pos]
	if {$to == [llength $data(names)]} {
		lappend data(names) $current
	} else {
		set data(names) [lreplace $data(names) $to -1 $current]
	}
	$window.list configure -content $data(names)
	$window.list activate $to
	$window.list selection set $to
}

Classy::Config method changelevel {var window} {
	upvar #0 $var data
	switch $data(ltype) {
		Fonts - Colors - Misc - Keys - Mouse {
			set select [$window.list get]
			set level [$window.top.level get]
		}
		Toolbars - Menus {
			set level [$window.level get]
		}
	}		
	set oldlevel $data(level)
	switch $level {
		{Application user} {set slevel appuser}
		{Application default} {set slevel appdef}
		{ClassyTcl user} {set slevel user}
		{ClassyTcl default} {set slevel def}
		default {set slevel $level}
	}
	set type $data(type)
	set ltype $data(ltype)
	set name $data(name)
	if $data(changed) {
		if ![Classy::yorn "Unsaved changes, continue anyway?"] {
			catch {$window.top.level set $level}
			catch {$window.level set $level}
			return
		}
	}
	if [catch {::Classy::Config load $type $slevel $name $var} result] {
		::Classy::Config load $type $oldlevel $name $var
		switch $oldlevel {
			appuser {set level {Application user}}
			appdef {set level {Application default}}
			user {set level {ClassyTcl user}}
			def {set level {ClassyTcl default}}
		}
		catch {$window.top.level set $level}
		catch {$window.level set $level}
		error $result
	}
	switch $data(ltype) {
		Fonts - Colors - Misc - Keys - Mouse {
			$window.list configure -content $data(names)
			if {"[lindex $select 0]" != ""} {
				$window.list activate [lindex $select 0]
			}
		}
		Toolbars - Menus {
			$window.value set $data(c)
			$window.value textchanged 0
			set data(changed) 0
			set data(window) $window
		}
	}		
}

Classy::Config method open {w name} {
	$w selection set $name
	set level [lindex $name 0]
	set type [lindex $name 1]
	set name [lindex $name 2]
	switch $type {
		Fonts - Colors - Misc - Keys - Mouse {
			set win [winfo parent $w].frame.gen
			catch {destroy $win}
			Classy::config_frame $win -level $level -name $name -type $type
			[winfo parent $w].frame select gen
			set ::${win}(close) "destroy [winfo parent $w]"
		}
		Toolbars {
			set win [winfo parent $w].frame.gen
			catch {destroy $win}
			Classy::config_tool $win -level $level -name $name
			[winfo parent $w].frame select gen
			set ::${win}(close) "destroy [winfo parent $w]"
		}
		Menus {
			set win [winfo parent $w].frame.gen
			catch {destroy $win}
			Classy::config_menu $win -level $level -name $name
			[winfo parent $w].frame select gen
			set ::${win}(close) "destroy [winfo parent $w]"
		}
		default {
			private $object data
			set win [winfo parent $w].frame.gen
			catch {destroy $win}
			$object load $type $level $name [privatevar $object data]
			Classy::Selector $win -type text -label $data(help) \
				-variable [privatevar $object data(c)] \
				-command [list $object save [privatevar $object data]]
			[winfo parent $w].frame select gen
		}
	}
}

Classy::Config method newconfig {type level {name {}}} {
	if {"$name" == ""} {
		catch {destroy .classy__.temp}
		Classy::InputDialog .classy__.temp -title "New $type" -label "$type name" \
			-command "$object newconfig $type $level"
		return
	}
	catch {set ltype [structlget {color Colors font Fonts misc Misc mouse Mouse key Keys menu Menus tool Toolbars} $type]}
	set file [file join $Classy::dir($level) init $ltype.tcl]
	if ![catch {Classy::Builder infile get $file $name}] {
		error "$ltype \"$name\" already exists"
	}
	switch $ltype {
		Fonts - Colors - Misc - Keys - Mouse {
			set code "Classy::config$type $name \{\n\}"
		}
		Toolbars {
			set code "Classy::configtool $name {} \{\n"
			append code "\taction Builder/question {Dummy tool} {Classy::msg {Just a dummy toolbar}}"
			append code "\n\}"
		}
		Menus {
			set code "Classy::configmenu $name {} \{\n"
			append code "menu sel \"Menu\" \{\n"
			append code "\taction Test \"Test\" \{puts \"test %W\"\}"
			append code "\n\}"
			append code "\n\}"
		}
	}
	Classy::Builder infile set $file $name $code
	uplevel #0 $code
	return
}

#doc {Config command dialog} cmd {
#Config dialog
#} descr {
# display the general configuration dialog
#}
Classy::Config method dialog {} {
	Classy::config .classy__.configdialog
}

#doc {Config command config} cmd {
#Config config type name ?level?
#} descr {
# display a dialog to configure the specific configuration block (name) of the given 
# type (font,color,misc,key,mouse,tool or menu)
#}
Classy::Config method config {type name {level appuser}} {
	catch {destroy .classy__.config}
	Classy::Toplevel .classy__.config -title $name -keepgeometry all
	set win .classy__.config.frame
	catch {set type [structlget {color Colors font Fonts misc Misc mouse Mouse key Keys menu Menus tool Toolbars} $type]}
	switch $type {
		Fonts - Colors - Misc - Keys - Mouse {
			Classy::config_frame $win -level $level -name $name -type $type
		}
		Toolbars {
			Classy::config_tool $win -level $level -name $name
		}
		Menus {
			Classy::config_menu $win -level $level -name $name
		}
		default {
			private $object data
			$object load $type $level $name [privatevar $object data]
			Classy::Selector $win -type text -label $data(help) \
				-variable [privatevar $object data(c)] \
				-command [list $object save [privatevar $object data]]
		}
	}		
	pack $win -fill both -expand yes
	set ::${win}(close) {destroy .classy__.config}
}


