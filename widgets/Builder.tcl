#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Builder
# ----------------------------------------------------------------------
#doc Builder title {
#Builder
#} index none shortdescr {
# widget used by the ClassyTcl Builder
#} descr {
# The builder is used to easily build ClassyTcl applications
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
	super init -keepgeometry all -resize {10 10}
	set w [Classy::window $object]
	private $object browse
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
		if ![info exists defdir] {
			set defdir $::Classy::appdir
		} else return
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
	if {"winfo children .]" == ".classy__"} {
		if ![Classy::yorn "Close application?"] return
		exit
	} else {
		$object.browse destroy
	}
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Builder method new {type {name {}}} {
	global auto_index
	private $object browse options defdir
	if {"$name" == ""} {
		catch {destroy $object.temp}
		Classy::InputDialog $object.temp -title "New $type" -label "Name" \
			-command "$object new $type"
		return
	}
	set browse(type) $type
	set file $browse(file)
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
	} else {
		if [info exists auto_index($name)] {
			set file [lindex $auto_index($name) 1]
			if ![Classy::yorn "function \"$name\" probably exists in file \"$file\"! continue anyway?"] return
		}
		if [file isdir $file] {return -code error "please select a file instead of a directory"}
	}
	switch $type {
		function {
			$object infile set $file $name "proc [list $name] \{\} \{\}"
		}
		dialog {
			set code "proc [list $name] args \{# ClassyTcl generated Dialog"
			append code "\n\tif \[regexp \{^\\.\} \$args] \{"
			append code "\n\t\tset window \[lshift args\]"
			append code "\n\t\} else \{"
			append code "\n\t\tset window .$name"
			append code "\n\t\}"
			append code "\n\tClassy::parseopt \$args opt {}"
			append code "\n\t# Create windows"
			append code "\n\tClassy::Dialog \$window \\"
			append code "\n\t\t-destroycommand \[list destroy \$window\]"
			append code "\n\t# End windows"
			append code "\n\}"
			$object infile set $file $name $code
		}
		toplevel {
			set code "proc [list $name] args \{# ClassyTcl generated Toplevel"
			append code "\n\tif \[regexp \{^\\.\} \$args] \{"
			append code "\n\t\tset window \[lshift args\]"
			append code "\n\t\} else \{"
			append code "\n\t\tset window .$name"
			append code "\n\t\}"
			append code "\n\tClassy::parseopt \$args opt {}"
			append code "\n\t# Create windows"
			append code "\n\tClassy::Toplevel \$window \\"
			append code "\n\t\t-destroycommand \[list destroy \$window\]"
			append code "\n\t# End windows"
			append code "\n\}"
			$object infile set $file $name $code
		}
		frame {
			set code "proc [list $name] args \{# ClassyTcl generated Frame"
			append code "\n\tif \[regexp \{^\\.\} \$args] \{"
			append code "\n\t\tset window \[lshift args\]"
			append code "\n\t\} else \{"
			append code "\n\t\tset window .$name"
			append code "\n\t\}"
			append code "\n\tClassy::parseopt \$args opt {}"
			append code "\n\t# Create windows"
			append code "\n\tframe \$window \\"
			append code "\n\t\t-class Classy::Topframe"
			append code "\n\t# End windows"
			append code "\n\}"
			$object infile set $file $name $code
		}
	}
	set base [list $file $name $type]
	set pnode [list $file {} file]
	$object.browse addnode $pnode $base -type end -text $name -image [Classy::geticon new$type]
	update idletasks
	$object.browse selection set $base
}

Classy::Builder method _creatededit {w} {
	if ![winfo exists $w] {
		Classy::WindowBuilder $w
		$w place
	} else {
		$w place
	}
}

Classy::Builder method open {file function type} {
	global auto_index
	private $object browse open
#	if [$object closeedit] return
	set browse(base) [list $file $function $type]
	set browse(file) $file
	set browse(name) $function
	set browse(type) $type
	set open(type) $type
	if {"$function" == ""} {
		edit $file
		return
	}
	switch $type {
		toplevel -
		frame -
		dialog {
			$object _creatededit $object.dedit
			$object.dedit open $file $function
		}
		dir {}
		file {
			edit $file
		}
		function {
			$object fedit $object.fedit $file $function $type
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
				} else {
					puts $o $line
				}
			}
			if !$done {
				puts $o $code
			}
			close $o
			close $f
			if [string match "proc *" $code] {
				catch {auto_mkindex [file dirname $file] *.tcl}
				catch {rename $name {}}
				set ::auto_index($name) [list source $file]
			}
		}
		ls {
			set f [open $file]
			set result ""
			while {![eof $f]} {
				set line [getcomplete $f]
				if [string match "proc *" $line] {
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
					puts $o $line
				}
			}
			close $o
			close $f
			catch {auto_mkindex [file dirname $file] *.tcl}
			catch {rename $name {}}
			catch {unset ::auto_index($name)}
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
					catch {rename $name $newname}
					catch {auto_mkindex [file dirname $file] *.tcl}
					unset ::auto_index($name)
					set ::auto_index($newname) [list source $file]
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
			foreach line [splitcomplete [readfile $file]] {
				if [regexp {^proc } $line] {lappend funcs [lindex $line 1]}
			}
			if {[lsearch $funcs $func] != -1} {
				set num 1
				while {[lsearch $funcs $func#$num] != -1} {incr num}
				set code [lreplace $code 1 1 $func#$num]
				set func $func#$num
			}
			set f [open $file a]
			puts $f $code
			close $f
			if [string match "proc *" $code] {
				catch {auto_mkindex [file dirname $file] *.tcl}
				set ::auto_index($func) [list source $file]
			}
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
	$object copy
	$object delete
}

Classy::Builder method delete {} {
	global auto_index
	private $object options browse
	set file $browse(file)
	switch $browse(type) {
		file {
			file copy -force $file $file~
			file delete $file
			$object.browse deletenode $browse(base)
			catch {auto_mkindex [file dirname $file] *.tcl}
			return $file
		}
		dir - color - font - misc - key - mouse - menu - tool {
			set function $browse(name)
			$object infile delete $file $function
			$object.browse selection set [list $browse(file) {} file]
			$object.browse deletenode $browse(base)
			return $function
		}
		default {
			set function $browse(name)
			$object infile delete $file $function
			$object.browse deletenode $browse(base)
			$object.browse selection set [list $browse(file) {} file]
			return $function
		}
	}
}

Classy::Builder method copy {} {
	global auto_index
	private $object options browse
	set file $browse(file)
	set browse(cliptype) $browse(type)
	switch $browse(type) {
		file {
			set browse(clipbf) $file
			set browse(clipb) [readfile $file]
			clipboard clear
			clipboard append $browse(clipb)
			return $file
		}
		color - font - misc - key - mouse - menu - tool {
			if {"[lindex $browse(base) 1]" == ""} {
				set browse(clipbf) $file
				set browse(clipb) [readfile $file]
				clipboard clear
				clipboard append $browse(clipb)
				return $file
			} else {
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
			set base [file join $file clipboard]
			set ext .tcl
		} else {
			set ext [file extension $browse(clipbf)]
			set tail [file tail $browse(clipbf)]
			set base [file join $file [file root $tail]]
		}
		if [file exists $base$ext] {
			set num 1
			while {[file exists $base#$num$ext]} {incr num}
			set base $base#$num
		}
		set file $base$ext
		writefile $file $browse(clipb)
		$object.browse addnode $browse(base) [list $file {} file] -text [file tail $file] -image [Classy::geticon newfile]
#		$object closenode $browse(base)
#		$object opennode $browse(base)
	} elseif {"$browse(clipbf)" != ""} {
		error "Can only paste file in directory"
	} else {
		$object infile add $file $browse(clipb)
	}
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
	private $object browse defdir
	if {"$base" == ""} {
		set browse(base) $base
		set browse(file) $defdir
		set browse(name) {}
		set browse(type) dir
	} else {
		set browse(base) $base
		set browse(file) [lindex $base 0]
		set browse(name) [lindex $base 1]
		set browse(type) [lindex $base 2]
	}
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
			set type file
			set image [Classy::geticon newfile]
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
	$object.browse configure -roottext [file tail $defdir]
	catch {auto_mkindex $defdir *.tcl}
	catch {source [file join $defdir tclIndex]}
	$object opennode {} [list $defdir {} dir]
	$object.browse redraw
	update idletasks
	set select [lindex [$object.browse children {}] 0]
	$object opennode $select
}

Classy::Builder method fedit {w file function type} {
	set num 1
	while 1 {
		if ![winfo exists $object.fedit$num] break
		incr num
	}
	set w $object.fedit$num
	Classy::Toplevel $w -keepgeometry all -resize {2 2}
	Classy::Entry $w.args -label "$function arguments"
	Classy::Editor $w.edit -closecommand [list destroy $w]
	pack $w.args -side top -fill both
	pack $w.edit -side top -fill both -expand yes
	set code [$object infile get $file $function]
	$w.args set [lindex $code 2]
	$w.edit set [string trimright [string trimleft [lindex $code 3] "\n"] "\n"]
	$w configure -title $function
	$w.edit textchanged 0
	$w.edit configure -savecommand [list invoke code [varsubst {object file function w} {
		uplevel #0 "proc $function [list [$w.args get]] \{\n$code\n\}"
		$object infile set $file $function "proc $function [list [$w.args get]] \{\n$code\n\}"
		$w.edit textchanged 0
		$w configure -title $function
	}]]
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
			set dst [file join [file dir $src] $dst]
			file copy [lindex $src 0] $dst
			file delete [lindex $src 0]
			set parent [$object.browse parentnode $src]
			$object.browse deletenode $src
			$object.browse addnode $parent [lreplace $src 0 0 $dst] -text [file tail $dst] -image [Classy::geticon newfile]
		}
		dir {
		}
		default {
			set type [lindex $src 2]
			set parent [$object.browse parentnode $src]
			$object infile rename [lindex $src 0] [lindex $src 1] $dst
			$object.browse deletenode $src
			$object.browse addnode $parent [lreplace $src 1 1 $dst] -type end -text [file tail $dst] -image [Classy::geticon new$type]
		}
	}
}

