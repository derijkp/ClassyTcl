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
	Classy::DynaTool maketool Classy::Builder $object.tool $object
	grid $object.tool -row 0 -columnspan 3 -sticky ew
	grid rowconfigure $object 0 -weight 0
	grid rowconfigure $object 1 -weight 1

	frame $object.bframe
	Classy::OptionMenu $object.dirmenu
	Classy::TreeWidget $object.browse -width 80 -height 10 \
		-opencommand "$object opennode" \
		-closecommand "$object closenode" \
		-endnodecommand "$object openendnode"
	grid $object.dirmenu -in $object.bframe -row 0 -column 0 -columnspan 2 -sticky nsew
	grid $object.browse -in $object.bframe -row 1 -column 0 -sticky nsew
	grid columnconfigure $object.bframe 0 -weight 1
	grid rowconfigure $object.bframe 1 -weight 1

	grid $object.bframe -sticky nsew
	grid columnconfigure $object 0 -weight 1	

	# REM Initialise options and variables
	# ------------------------------------
	if {[lsearch $args -dirs] == -1} {lappend args -dirs {}}

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
Classy::Builder addoption -dir {dir Directory {}} {
	if {"$value" == ""} {
		grid $object.dirmenu -in $object.bframe -row 0 -column 0 -columnspan 2 -sticky nsew
	} else {
		grid forget $object.dirmenu
	}
	Classy::todo $object _drawtree
}

Classy::Builder addoption -dirs {dirs Directories {}} {
	private $object dirs
	if {"$value" == ""} {
		set dirs ""
		lappend dirs "Application" $::Classy::appdir
		lappend dirs "User" $::Classy::dir(appuser)
		lappend dirs "ClassyTcl User" $::Classy::dir(user)
		lappend dirs "ClassyTcl config" $::Classy::dir(def)
	} else {
		set dirs $value
	}
	set list ""
	foreach {name dir} $dirs {
		lappend list $name
	}
	$object.dirmenu configure -list $list
	$object.dirmenu configure -command "Classy::todo $object _drawtree"
	$object.dirmenu set [lindex $list 0]
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
		dialog - toplevel {
			return [catch {$object.dedit close}]
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
			return [$object.confedit.edit close]
		}
	}
	return 0
}

Classy::Builder method new {type {name {}}} {
	global auto_index
	private $object browse options dirs
	if [$object close] return
	if {"$name" == ""} {
		catch {destroy $object.temp}
		Classy::InputBox $object.temp -title "New file" -label "Name" \
			-command "$object new $type \[$object.temp get\]"
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
		if {"$options(-dir)" == ""} {
			set defdir [structlget $dirs [list [$object.dirmenu get]]]
		} else {
			set defdir $options(-dir)
		}
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
			puts $f "\nproc $name \{\} \{"
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
	}
	set base [list $file $name $type]
	$object.browse addnode [list $file {} file] $base -type end -text $name -image [Classy::geticon new$type]
	update idletasks
	$object.browse selection set $base
	$object open $file $name $type
}

Classy::Builder method _creatededit {w} {
	if ![winfo exists $w] {
		Classy::WindowBuilder $w
	} else {
		$w place
	}
}

Classy::Builder method open {file function type} {
#putsvars file function type
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
		dialog {
			$object _creatededit $object.dedit
			$object.dedit open $file $function
		}
		dir {}
		file {}
		function {
			$object fedit $object.fedit $file $function $type
		}
		default {
			$object confedit $object.confedit $file $function $type
		}
	}
}

Classy::Builder method cut {} {
	global auto_index
	private $object options browse
	set file $browse(file)
	$object close
	if {"$browse(type)" == "file"} {
		set browse(clipbf) $file
		set browse(clipb) [readfile $file]
		clipboard clear
		clipboard append [readfile $file]
		file rename -force $file $file~
		$object.browse deletenode $browse(base)
		return $file
	} elseif {"$browse(type)" == "dir"} {
	} else {
		set result ""
		set work ""
		set function $browse(name)
		foreach line [split [readfile $file] "\n"] {
			append work "$line\n"
			if [info complete $work] {
				if ![string match "proc $function *" $work] {
					append result $work
				} else {
					set browse(clipbf) {}
					set browse(clipb) $work
					clipboard clear
					clipboard append $work
				}
				set work ""
			}
		}
		file copy -force $file $file~
		writefile $file $result
		catch {auto_mkindex [file dirname $file] *.tcl}
		catch {unset auto_index($function)}
		$object.browse selection set {}
		$object.browse deletenode $browse(base)
		return $function
	}
}

Classy::Builder method copy {} {
	global auto_index
	private $object options browse
	set file $browse(file)
	if {"$browse(type)" == "file"} {
		set browse(clipbf) $file
		set browse(clipb) [readfile $file]
		clipboard clear
		clipboard append $browse(clipb)
		return $file
	} elseif {"$browse(type)" == "function"} {
		set browse(clipb) {}
		set result ""
		set work ""
		set function $browse(name)
		foreach line [split [readfile $file] "\n"] {
			append work "$line\n"
			if [info complete $work] {
				if ![string match "proc $function *" $work] {
					append result $work
				} else {
					set browse(clipbf) {}
					set browse(clipb) $work
					clipboard clear
					clipboard append $work
				}
				set work ""
			}
		}
		return $function
	}
}

Classy::Builder method paste {} {
	global auto_index
	private $object options browse
	set file $browse(file)
	if [file isdir $file] {
		if {"$browse(clipbf)" == ""} {
			set file [file join $file clipboard.tcl]
		} else {
			set file [file join $file [file tail $browse(clipbf)]]
		}
	}
	set f [open $file a]
	puts $f $browse(clipb)
	close $f
	$object closenode [list $browse(file) {} file]
	$object opennode [list $browse(file) {} file]
}

Classy::Builder method save {} {
	global auto_index
	private $object browse
	set file $browse(file)
	switch $browse(type) {
		dialog - toplevel {
			set result [$object.dedit save]
		}
		function {	
			file copy -force $file $file~
			$object.fedit.edit save
			uplevel #0 source $browse(file)
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

Classy::Builder method closenode {base} {
	private $object browse
	if {"$base" == ""} return
	set browse(base) $base
	set browse(file) [lindex $base 0]
	set browse(name) [lindex $base 1]
	set browse(type) [lindex $base 2]
	$object close
	$object.browse clearnode $base
	if ![file isdir $browse(file)] {
		catch {$object open $browse(file) $browse(name) $browse(type)}
	}
}

Classy::Builder method opennode {args} {
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
		$object close
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
					if [regexp {^#ClassyTcl ([^ ]+) configuration file} $line temp type] {
						set image [Classy::geticon Builder/config_$type]
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
		set browse(type) file
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
					-type end -text $func -image [Classy::geticon Builder/config_$type]
			}
		}
		close $f
		$object open $browse(file) $browse(name) $browse(type)
	}
	$object.browse selection set $base
}

Classy::Builder method _drawtree {} {
	private $object options browse dirs
	if [$object close] return
	$object.browse clearnode {}
	if {"$options(-dir)" == ""} {
		set dir [structlget $dirs [list [$object.dirmenu get]]]
	} else {
		set dir $options(-dir)
	}
	catch {auto_mkindex $dir *.tcl}
	catch {source [file join $dir tclIndex]}
	$object opennode {} [list $dir {} dir]
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

