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

Widget subclass Classy::Builder
Classy::export Builder {}

Classy::Builder classmethod init {args} {
	super toplevel
	set w [Classy::window $object]
	wm geometry $object +10000+10000

	private $object browse
	Classy::DynaMenu makemenu Classy::Builder .classy__.buildermenu $object Classy::BuilderMenu
	bindtags $object [list $object Classy::Builder all]
	Classy::DynaTool maketool Classy::Builder $object.tool $object
	grid $object.tool -row 0 -columnspan 3 -sticky ew
	grid rowconfigure $object 0 -weight 0
	grid rowconfigure $object 1 -weight 1

	frame $object.bframe
	Classy::OptionMenu $object.dirmenu
	canvas $object.browse -width 80 -height 10\
		-yscrollcommand [list $object.bvbar set] -xscrollcommand [list $object.bhbar set]
	scrollbar $object.bvbar -orient vertical -command [list $object.browse yview]
	scrollbar $object.bhbar -orient horizontal -command [list $object.browse xview]
	catch {$object.tree destroy}
	Classy::Tree $object.tree -canvas $object.browse
	grid $object.dirmenu -in $object.bframe -row 0 -column 0 -columnspan 2 -sticky nsew
	grid $object.browse -in $object.bframe -row 1 -column 0 -sticky nsew
	grid $object.bvbar -in $object.bframe -row 1 -column 1 -sticky ns
	grid $object.bhbar -in $object.bframe -row 2 -column 0 -sticky ew
	grid columnconfigure $object.bframe 0 -weight 1
	grid rowconfigure $object.bframe 1 -weight 1

	set w [winfo reqwidth $object]
	set h [expr {[winfo reqheight $object]+300}]
	set maxx [expr [winfo vrootwidth $object]-$w]
	set maxy [expr [winfo vrootheight $object]-$h]
	set x [expr [winfo pointerx .]-$w/2]
	set y [expr [winfo pointery .]-$h/2]
	if {$x>$maxx} {set x $maxx}
	if {$y>$maxy} {set y $maxy}
	if {$x<0} {set x 0}
	if {$y<0} {set y 0}
	wm geometry $object ${w}x${h}+$x+$y

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
	bind Classy::Builder_$object <<Action>> {}
	$object.tree destroy
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Builder method close {} {
	private $object open
	if ![info exists open(type)] {return 0}
	switch $open(type) {
		dialog - toplevel {
			$object _creatededit $object.dedit
			return [$object.dedit close]
		}
		file {}
		function {
			if [$object.fedit.edit textchanged] {
				if ![Classy::yorn "Are you sure you want to abort the current editing session"] {
					return 1
				}
				$object.fedit.edit textchanged 0
			}
			Classy::Default set geom $object.fedit [wm geometry $object.fedit]
			wm withdraw $object.fedit
		}
		default {
			return [$object.confedit.edit close]
		}
	}
	return 0
}

Classy::Builder method new {type {name {}}} {
	global auto_index
	private $object browse options
	if [$object close] return
	if {"$name" == ""} {
		catch {destroy $object.temp}
		Classy::InputBox $object.temp -title "New file" -label "Name" -command "$object new $type \[$object.temp get\]"
		return
	}
	if {"$type" == "file"} {
		if ![regexp {\.tcl$} $name] {append name .tcl}
		if [file isdir $browse(file)] {
			set file [file join $browse(file) $name]
		} else {
			set file [file join [file dir $browse(file)] $name]
		}
		if ![file exists $file] {
			set f [open $file w]
			puts $f "#Functions"
			close $f
		}
		set dir [file dir $file]
		if {"$options(-dir)" == ""} {
			set defdir [file join $::Classy::appdir lib]
		} else {
			set defdir $options(-dir)
		}
		set base [list $file {} file]
		if {"$dir" == "$defdir"} {
			$object.tree addnode {} $base -text [file tail $file] -image [Classy::geticon newfile]
		} else {
			$object.tree addnode $dir $base -text [file tail $file] -image [Classy::geticon newfile]
		}
		$object _drawselect $base
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
	set base [list $file $name file]
	$object.tree addnode [list $file {} file] $base -type end -text $name -image [Classy::geticon new$type]
	update idletasks
	$object _drawselect $base
	$object open $file $name $type
}

Classy::Builder method _creatededit {w} {
	if ![winfo exists $w] {
		Classy::WindowBuilder $w
	} else {
		wm withdraw $w
		wm geometry $w [Classy::Default get geom $w]
		wm deiconify $w
	}
}

Classy::Builder method open {file function type} {
#putsvars file function type
	global auto_index
	private $object browse open
	if [$object close] return
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
	if {"$browse(type)" == "file"} {
		set browse(clipbf) $file
		set browse(clipb) [readfile $file]
		clipboard clear
		clipboard append [readfile $file]
		file rename -force $file $file~
		$object.tree deletenode $file
		return $file
	} elseif {"$browse(type)" == "function"} {
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
		$object _drawselect {}
		$object.tree deletenode [list $file $function]
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
	$object browse $browse(file)
	$object browse $browse(file)
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

Classy::Builder method browse {root base} {
puts $base
	private $object browse
	if {"$base" == ""} return
	set browse(base) $base
	set browse(file) [lindex $base 0]
	set browse(name) [lindex $base 1]
	set browse(type) [lindex $base 2]
	switch [$object.tree type $root] {
		e {
			$object open $browse(file) $browse(name) $browse(type)
		}
		f {
			$object close
			$object.tree clearnode $base
			if ![file isdir $browse(file)] {
				catch {$object open $browse(file) $browse(name) $browse(type)}
			}
		}
		c {
			if [file isdir $browse(file)] {
				$object close
				set list ""
				set olist ""
				foreach file [glob -nocomplain [file join $browse(file) *]] {
					if [file isdir $file] {
						$object.tree addnode $root [list $file {} dir] -text [file tail $file]
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
					$object.tree addnode $root [list $file {} $type] -text [file tail $file] -image $image
				}
				foreach file [lsort $olist] {
					$object.tree addnode $root [list $file {} file] -text [file tail $file] -type end -image [Classy::geticon newfile]
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
							$object.tree addnode $root [list $browse(file) $func dialog] \
								-type end -text $func -image [Classy::geticon newdialog]
						} elseif [regexp {# ClassyTcl generated Toplevel} $line] {
							$object.tree addnode $root [list $browse(file) $func toplevel] \
								-type end -text $func -image [Classy::geticon newtoplevel]
						} else {
							$object.tree addnode $root [list $browse(file) $func function] -type end -text $func -image [Classy::geticon newfunction]
						}
					} elseif [regexp {^Classy::config([^ ]+) } $line temp type] {
						if [info complete $line] {
							set func [lindex "$line" 1]
						} else {
							set func [lindex "$line\}" 1]
						}
						set browse(type) $type
						$object.tree addnode $root [list $browse(file) $func $type] \
							-type end -text $func -image [Classy::geticon Builder/config_$type]
					}
				}
				close $f
				$object open $browse(file) $browse(name) $browse(type)
			}
		}
	}
	update idletasks
	catch {$object _drawselect $browse(base)}
	$object.browse configure -scrollregion [$object.browse bbox all]
}

Classy::Builder method _drawselect {base} {
	private $object browse
	$object.browse delete selection
	if {"$base" == ""} return
	eval $object.browse create rectangle [$object.browse bbox $base] \
		-tags selection \
		-fill [option get $object selectBackground SelectBackground] \
		-outline [option get $object selectBackground SelectBackground]
	$object.browse lower selection
}

Classy::Builder method _drawtree {} {
	private $object options browse dirs
	if [$object close] return
	$object.tree clearnode {}
	if {"$options(-dir)" == ""} {
		set dir [structlget $dirs [list [$object.dirmenu get]]]
	} else {
		set dir $options(-dir)
	}
	catch {auto_mkindex $dir *.tcl}
	catch {source [file join $dir tclIndex]}
	$object browse {} [list $dir {} dir]
	update idletasks
	set select [lindex [$object.tree children {}] 0]
	$object browse $select $select
	bind $object.browse <<Action>> "$object browse \[$object.tree node %x %y\] \[$object.tree node %x %y\]"
}

Classy::Builder method fedit {w file function type} {
	if ![winfo exists $w] {
		toplevel $w
		wm protocol $w WM_DELETE_WINDOW [list catch [list destroy $w]]
		Classy::Editor $w.edit -closecommand "Classy::Default set geom $w \[wm geometry $w\];wm withdraw $w"
		pack $w.edit -fill both -expand yes
	} else {
		wm withdraw $w
		wm geometry $w [Classy::Default get geom $w]
		wm deiconify $w
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
		toplevel $w
		wm protocol $w WM_DELETE_WINDOW [list catch [list destroy $w]]
		Classy::Config $w.edit -closecommand "Classy::Default set geom $w \[wm geometry $w\];wm withdraw $w"
		pack $w.edit -fill both -expand yes
	} else {
		wm withdraw $w
		wm geometry $w [Classy::Default get geom $w]
		wm deiconify $w
	}
	wm title $w $file
	$w.edit open $file $function $type
}

