#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Builder
# ----------------------------------------------------------------------
#doc Builder title {
#Builder
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
#}
#doc {Builder options} h2 {
#	Builder specific options
#}
#doc {Builder command} h2 {
#	Builder specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Builder {} {}
proc Builder {} {}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Toplevel subclass Classy::Builder
Classy::export Builder {}

Classy::Builder classmethod init {args} {
	super -keepgeometry all -resize {10 10}
	set w [Classy::window $object]
	private $object browse
	Classy::DynaMenu makemenu Classy::Builder .classy__.buildermenu $object Classy::BuilderMenu
	bindtags $object [list $object Classy::Builder all]
	Classy::DynaTool $object.tool -type Classy::Builder -cmdw $object
	frame $object.bframe
	Classy::TreeWidget $object.browse -width 80 -height 10 -takefocus 1 \
		-opencommand "$object opennode" \
		-closecommand "$object closenode" \
		-endnodecommand "$object selectnode" \
		-executecommand "$object openendnode"
	::class::rebind $object.browse $object
	::class::refocus $object $object.browse
	Classy::DynaMenu attachmainmenu Classy::Builder $object
	grid $object.tool -row 0 -columnspan 3 -sticky ew
	grid rowconfigure $object 0 -weight 0
	grid rowconfigure $object 1 -weight 1
	grid $object.browse -in $object.bframe -row 1 -column 0 -sticky nsew
	grid columnconfigure $object.bframe 0 -weight 1
	grid rowconfigure $object.bframe 1 -weight 1
	grid $object.bframe -sticky nsew
	grid columnconfigure $object 0 -weight 1	
	# REM Initialise options and variables
	# ------------------------------------
	setprivate $object defdir [file join $::Classy::appdir lib]
	# REM Create bindings
	# --------------------
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	Classy::todo $object _drawtree
	update idletasks
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::Builder addoption -dir {dir Directory code} {
	private $object defdir
	set value [string trimright $value /]
	if {"$value" == ""} {
		set defdir $::Classy::appdir
	} elseif {"$value" == "code"} {
		set defdir [file join $::Classy::appdir lib]
	} elseif {"$value" == "config"} {
		set defdir [file join $::Classy::appdir conf]
	} elseif {"$value" == "help"} {
		set defdir [file join $::Classy::appdir help]
	} else {
		if ![file isdir $value] {
			set value [file dirname $value]
		}
		set defdir $value
	}
	Classy::todo $object _drawtree
}

# ------------------------------------------------------------------
#  destroy
# ------------------------------------------------------------------

#doc {Builder command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::Builder method destroy {} {
	$object.browse destroy
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Builder method close {} {
	private $object open
	if ![info exists open(type)] {return 0}
	switch $open(type) {
		dialog - frame - toplevel {
			if ![winfo exists $object.dedit] {return 0}
			set code [catch {$object.dedit close} result]
			return $result
		}
		file {}
		function {
			catch {
				if [$object.fedit.edit textchanged] {
					if ![Classy::yorn "Are you sure you want to abort the current editing session"] {
						return 1
					}
					$object.fedit.edit textchanged 0
				}
				$object.fedit hide
			}
		}
		default {
			if ![winfo exists $object.confedit] {return 0}
			set code [catch {$object.confedit close} result]
			return $result
		}
	}
	return 0
}

Classy::Builder method new {type {name {}}} {
	global auto_index
	private $object browse options defdir
	if {[lsearch {color font misc key mouse menu tool} $browse(type)] != -1} {
		set type $browse(type)
	}
	if {"$name" == ""} {
		catch {destroy $object.temp}
		Classy::InputDialog $object.temp -title "New $type" -label "Name" \
			-command "$object new $type"
		return
	}
	set browse(type) $type
	if {"$type" == "file"} {
		if ![regexp {\.tcl$} $name] {append name .tcl}
		if [file isdir $browse(file)] {
			set file [file join $browse(file) $name]
		} else {
			set file [file join [file dir $browse(file)] $name]
		}
		set browse(file) $file
		if ![file exists $file] {
			set f [open $file w]
			puts $f "#Functions"
			close $f
		}
		set dir [file dir $file]
		set base [list $file {} file]
		if {"$dir" == "$defdir"} {
			$object.browse addnode {} $base -text [file tail $file] -image [Classy::geticon newfile]
		} else {
			$object.browse addnode [list $dir {} dir] $base -text [file tail $file] -image [Classy::geticon newfile]
		}
		$object.browse selection set $base
		return
	}
	if [info exists auto_index($name)] {
		set file [lindex $auto_index($name) 1]
		if ![Classy::yorn "function \"$name\" probably exists in file \"$file\"! continue anyway?"] return
	}
	set file $browse(file)
	if [file isdir $file] {return -code error "please select a file instead of a directory"}
	switch $type {
		function {
			set f [open $file a]
			puts $f "\nproc [list $name] \{\} \{"
			puts $f "\}"
			close $f
		}
		dialog {
			$object _creatededit $object.dedit
			$object.dedit new dialog $name $file
		}
		toplevel {
			$object _creatededit $object.dedit
			$object.dedit new toplevel $name $file
		}
		frame {
			$object _creatededit $object.dedit
			$object.dedit new frame $name $file
		}
		color - font - misc - key - mouse - menu - tool {
			set f [open $file a]
			puts $f "\nClassy::config$type [list $name] \{"
			puts $f "\}"
			close $f
		}
	}
	set base [list $file $name $type]
	switch $type {
		color - font - misc - key - mouse - menu - tool {
			set pnode [list $file {} [lindex $browse(base) 2]]
			$object.browse addnode $pnode $base -type end -text $name -image [Classy::geticon config_$type]
		}
		default {
			set pnode [list $file {} file]
			$object.browse addnode $pnode $base -type end -text $name -image [Classy::geticon new$type]
		}
	}
	update idletasks
	$object.browse selection set $base
}

Classy::Builder method _creatededit {w} {
	if ![winfo exists $w] {
		Classy::WindowBuilder $w
	} else {
		$w place
	}
}

Classy::Builder method open {file function type} {
putsvars file function type
	global auto_index
	private $object browse open
	if [$object close] return
	set browse(base) [list $file $function $type]
	set browse(file) $file
	set browse(name) $function
	set browse(type) $type
	set open(type) $type
	switch $type {
		toplevel -
		frame -
		dialog {
			$object _creatededit $object.dedit
			$object.dedit open $file $function
		}
		dir {}
		file {
			$object fedit $object.fedit $file {} {}
		}
		function {
			$object fedit $object.fedit $file $function $type
		}
		default {
			set name $function
			set level $file
			catch {set type [structlget {color Colors font Fonts misc Misc mouse Mouse key Keys menu Menus tool Toolbars} $type]}
			Classy::Config config $type $name $level
		}
	}
}

Classy::Builder method infile {cmd file args} {
	private $object browse
	switch $cmd {
		get {
			set name [lindex $args 0]
			set f [open $file]
			while {![eof $f]} {
				set line [getcomplete $f]
				if [string match "proc $name *" $line] {
					close $f
					return $line
				} elseif [regexp "^Classy::config\[a-z\]+ [list $name]" $line] {
					close $f
					return $line
				}
			}
			close $f
			error "proc \"$name\" not found in file \"$file\""
		}
		set {
			set name [lindex $args 0]
			set code [lindex $args 1]
			file copy -force $file $file~
			set done 0
			set f [open $file~]
			set o [open $file w]
			while {![eof $f]} {
				set line [getcomplete $f]
				if [string match "proc $name *" $line] {
					puts $o $code
					set done 1
				} elseif [regexp "^Classy::config\[a-z\]+ [list $name]" $line] {
					puts $o $code
					set done 1
				} else {
					puts $o $line
				}
			}
			if !$done {
				puts $o $code
			}
			close $o
			close $f
		}
		ls {
			set f [open $file]
			set result ""
			while {![eof $f]} {
				set line [getcomplete $f]
				if [string match "proc *" $line] {
					lappend result [lindex $line 1]
				} elseif [regexp "^Classy::config\[a-z\]+ " $line] {
					lappend result [lindex $line 1]
				}
			}
			close $f
			return $result
		}
		delete {
			set name [lindex $args 0]
			file copy -force $file $file~
			set done 0
			set f [open $file~]
			set o [open $file w]
			while {![eof $f]} {
				set line [getcomplete $f]
				if ![string match "proc $name *" $line] {
					if ![regexp "^Classy::config\[a-z\]+ [list $name]" $line] {
						puts $o $line
					}
				}
			}
			close $o
			close $f
		}
		rename {
			set name [lindex $args 0]
			set newname [lindex $args 1]
			set ls [$object infile ls $file]
			if {[lsearch $ls $newname] != -1} {
				error "proc \"$newname\" already exists  in file \"$file\""
			}
			file copy -force $file $file~
			set done 0
			set f [open $file~]
			set o [open $file w]
			while {![eof $f]} {
				set line [getcomplete $f]
				if [string match "proc $name *" $line] {
					regsub "^proc [list $name]" $line "proc [list $newname]" line
					puts $o $line
				} elseif [regexp "^Classy::config\[a-z\]+ [list $name]" $line] {
					regsub "^(Classy::config\[a-z\]+) [list $name]" $line "\\1 [list $newname]" line
					puts $o $line
				} else {
					puts $o $line
				}
			}
			close $o
			close $f
		}
		add {
			set code [lindex $args 0]
			set func [lindex $code 1]
			set funcs ""
			foreach line [Extral::splitcomplete [readfile $file]] {
				if [regexp {^proc } $line] {lappend funcs [lindex $line 1]}
				if [regexp "^Classy::config\[a-z\]+ " $line] {lappend funcs [lindex $line 1]}
			}
			if {[lsearch $funcs $func] != -1} {
				set num 1
				while {[lsearch $funcs $func#$num] != -1} {incr num}
				set code [lreplace $code 1 1 $func#$num]
			}
			set f [open $file a]
			puts $f $code
			close $f
			switch $browse(type) {
				color - font - misc - key - mouse - menu - tool {
					set pnode [list $file {} $browse(type)]
				}
				default {
					set pnode [list $file {} file]
				}
			}
			$object closenode $pnode
			$object opennode $pnode
		}
	}
}

Classy::Builder method cut {} {
	global auto_index
	private $object options browse
	set file $browse(file)
	switch $browse(type) {
		file {
			set browse(clipbf) $file
			set browse(clipb) [readfile $file]
			clipboard clear
			clipboard append [readfile $file]
			file rename -force $file $file~
			$object.browse deletenode $browse(base)
			return $file
		}
		dir - color - font - misc - key - mouse - menu - tool {
		}
		default {
			set function $browse(name)
			set work [$object infile get $file $function]
			set browse(clipbf) {}
			set browse(clipb) $work
			clipboard clear
			clipboard append $work
			$object infile delete $file $function
			catch {auto_mkindex [file dirname $file] *.tcl}
			catch {unset auto_index($function)}
			$object.browse selection set {}
			$object.browse deletenode $browse(base)
			return $function
		}
	}
}

Classy::Builder method copy {} {
	global auto_index
	private $object options browse
	set file $browse(file)
	switch $browse(type) {
		file {
			set browse(clipbf) $file
			set browse(clipb) [readfile $file]
			clipboard clear
			clipboard append $browse(clipb)
			return $file
		}
		color - font - misc - key - mouse - menu - tool {
			set browse(clipbf) $file
			set browse(clipb) [readfile $file]
			clipboard clear
			clipboard append $browse(clipb)
			return $file
		}
		dir {
			error "Cannot copy dir to clipboard"
		}
		default {
			set browse(clipb) {}
			set function $browse(name)
			set work [$object infile get $file $function]
			set browse(clipbf) {}
			set browse(clipb) $work
			clipboard clear
			clipboard append $work
			return $work
		}
	}
}

Classy::Builder method paste {{file {}}} {
	global auto_index
	private $object options browse
	if {"$file" == ""} {
		set file $browse(file)
	}
	if [file isdir $file] {
		if {"$browse(clipbf)" == ""} {
			set file [file join $file clipboard.tcl]
		} else {
			set file [file join $file [file tail $browse(clipbf)]]
		}
	}
	$object infile add $file $browse(clipb)
}

Classy::Builder method save {} {
	global auto_index
	private $object browse
	set file $browse(file)
	switch $browse(type) {
		dialog - frame - toplevel {
			set result [$object.dedit save]
		}
		function {	
			file copy -force $file $file~
			$object.fedit.edit save
			uplevel #0 source {$browse(file)}
			catch {auto_mkindex [file dirname $file] *.tcl}
			set result $file
		}
	}
	return $result
}

Classy::Builder method openendnode {base} {
	private $object browse
	if {"$base" == ""} return
	set browse(base) $base
	set browse(file) [lindex $base 0]
	set browse(name) [lindex $base 1]
	set browse(type) [lindex $base 2]
	$object open $browse(file) $browse(name) $browse(type)
	$object.browse selection set $base
}

Classy::Builder method selectnode {base} {
	private $object browse
	if {"$base" == ""} return
	set browse(base) $base
	set browse(file) [lindex $base 0]
	set browse(name) [lindex $base 1]
	set browse(type) [lindex $base 2]
	$object.browse selection set $base
}

Classy::Builder method closenode {base} {
	private $object browse
	if {"$base" == ""} return
	set browse(base) $base
	set browse(file) [lindex $base 0]
	set browse(name) [lindex $base 1]
	set browse(type) [lindex $base 2]
	$object.browse clearnode $base
#	if ![file isdir $browse(file)] {
#		catch {$object open $browse(file) $browse(name) $browse(type)}
#	}
	$object.browse selection set $base
}

Classy::Builder method opennode {args} {
putsvars args
	private $object browse
	if {[llength $args] == 1} {
		set base [lindex $args 0]
		set root $base
	} else {
		set root [lindex $args 0]
		set base [lindex $args 1]
	}
	if {"$base" == ""} return
	set browse(base) $base
	set browse(file) [lindex $base 0]
	set browse(name) [lindex $base 1]
	set browse(type) [lindex $base 2]
	if [file isdir $browse(file)] {
		set list ""
		set olist ""
		foreach file [glob -nocomplain [file join $browse(file) *]] {
			if [file isdir $file] {
				$object.browse addnode $root [list $file {} dir] -text [file tail $file]
			} elseif {"[file extension $file]" == ".tcl"} {
				lappend list $file
			} elseif [regexp {~$} $file]  {
			} elseif {"[file tail $file]" == "tclIndex"}  {
			} else {
				lappend olist $file
			}
		}
		foreach file [lsort $list] {
			switch -- [file tail $file] {
				Colors.tcl - Keys.tcl - Misc.tcl - Toolbars.tcl - 
				Fonts.tcl - Menus.tcl - Mouse.tcl {
					set f [open $file]
					set line [gets $f]
					close $f
					if [regexp {^#[^ ]+ ([^ ]+) configuration file} $line temp type] {
						set image [Classy::geticon config_$type]
					} else {
						set image [Classy::geticon newfile]
					}
				}
				default {
					set type file
					set image [Classy::geticon newfile]
				}
			}
			$object.browse addnode $root [list $file {} $type] -text [file tail $file] -image $image
		}
		foreach file [lsort $olist] {
			$object.browse addnode $root [list $file {} file] -text [file tail $file] -type end -image [Classy::geticon newfile]
		}
	} else {
		set f [open $browse(file)]
		while {![eof $f]} {
			set line [gets $f]
			if [regexp ^proc $line] {
				if [info complete $line] {
					set func [lindex "$line" 1]
				} else {
					set func [lindex "$line\}" 1]
				}
				if [regexp {# ClassyTcl generated Dialog} $line] {
					$object.browse addnode $root [list $browse(file) $func dialog] \
						-type end -text $func -image [Classy::geticon newdialog]
				} elseif [regexp {# ClassyTcl generated Toplevel} $line] {
					$object.browse addnode $root [list $browse(file) $func toplevel] \
						-type end -text $func -image [Classy::geticon newtoplevel]
				} elseif [regexp {# ClassyTcl generated Frame} $line] {
					$object.browse addnode $root [list $browse(file) $func frame] \
						-type end -text $func -image [Classy::geticon newframe]
				} else {
					$object.browse addnode $root [list $browse(file) $func function] -type end -text $func -image [Classy::geticon newfunction]
				}
			} elseif [regexp {^Classy::config([^ ]+) } $line temp type] {
				if [info complete $line] {
					set func [lindex "$line" 1]
				} else {
					set func [lindex "$line\}" 1]
				}
				set browse(type) $type
				$object.browse addnode $root [list $browse(file) $func $type] \
					-type end -text $func -image [Classy::geticon config_$type]
			}
		}
		close $f
#		$object open $browse(file) $browse(name) $browse(type)
	}
	$object.browse selection set $base
}

Classy::Builder method _drawtree {} {
	private $object options browse defdir
	$object.browse clearnode {}
	catch {auto_mkindex $defdir *.tcl}
	catch {source [file join $defdir tclIndex]}
	$object opennode {} [list $defdir {} dir]
	$object.browse redraw
	update idletasks
	set select [lindex [$object.browse children {}] 0]
	$object opennode $select
}

Classy::Builder method fedit {w file function type} {
	if ![winfo exists $w] {
		Classy::Toplevel $w -keepgeometry all -resize {2 2}
		Classy::Editor $w.edit -closecommand "$w hide"
		pack $w.edit -fill both -expand yes
	} else {
		$w place
	}
	wm title $w $file
	$w.edit load $file
	if {"$function" != ""} {
		switch $type {
			function {set pattern "proc $function "}
			default {set pattern "Classy::config$type [list $function] "}
		}
		set line 1
		set pos [lindex [split [$w.edit.edit search $pattern 1.0] "."] 0]
		if {"$pos" == ""} {set pos 1}
		set base [lindex [split [$w.edit index @0,0] "."] 0]
		$w.edit yview scroll [expr {$pos-$base}] units
	}
}

Classy::Builder method confedit {w file function type} {
	if ![winfo exists $w] {
		Classy::Toplevel $w -keepgeometry all
		Classy::Config $w.edit -closecommand "$w hide"
		pack $w.edit -fill both -expand yes
	} else {
		$w place
	}
	wm title $w $file
	$w.edit open $file $function $type
}

Classy::Builder method rename {args} {
	if {"$args" == ""} {
		$object.browse edit [lindex [$object.browse selection] 0] "$object rename [$object.browse selection]"
		return
	}
	set src [lindex $args 0]
	set dst [lindex $args 1]
	switch [lindex $src 2] {
		file {
			file rename [lindex $src 0] $dst
			set parent [$object.browse parentnode $src]
			$object.browse deletenode $src
			$object.browse addnode $parent [lreplace $src 0 $dst] -text [file tail $dst] -image [Classy::geticon newfile]
		}
		dir {
		}
		default {
			set type [lindex $src 2]
			set parent [$object.browse parentnode $src]
			$object infile rename [lindex $src 0] [lindex $src 1] $dst
			$object.browse deletenode $src
			switch $type {
				color - font - misc - key - mouse - menu - tool {
					$object.browse addnode $parent [lreplace $src 1 1 $dst] -type end -text [file tail $dst] -image [Classy::geticon config_$type]
				}
				default {
					$object.browse addnode $parent [lreplace $src 1 1 $dst] -type end -text [file tail $dst] -image [Classy::geticon new$type]
				}
			}
		}
	}
}