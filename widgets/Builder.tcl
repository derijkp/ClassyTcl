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
# Next is to get the attention of auto_mkindex \
# These will be added to tclIndex by Classy::auto_mkindex
#auto_index Builder

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Toplevel subclass Classy::Builder
Classy::export Builder {}

Classy::Builder method init {args} {
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
	::Classy::rebind $object.browse $object
	::Classy::refocus $object $object.browse
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
		set c [splitcomplete [readfile $file]]
		if {[lsearch -glob $c [list proc $name *]] != -1} {
		} elseif {[lsearch -glob $c [list Classy::Toplevel subclass $name]] != -1} {
			error "Toplevel \"$name\" exists in file \"$file\"!"
		} elseif {[lsearch -glob $c [list Classy::Dialog subclass $name]] != -1} {
			error "Dialog \"$name\" exists in file \"$file\"!"
		} elseif {[lsearch -glob $c [list Classy::Topframe subclass $name]] != -1} {
			error "Frame \"$name\" exists in file \"$file\"!"
		}
		if [info exists auto_index($name)] {
			set file [lindex $auto_index($name) 1]
			if ![Classy::yorn "function \"$name\" probably exists in file \"$file\"! continue anyway?"] return
		}
		if [file isdir $file] {return -code error "please select a file instead of a directory"}
	}
	switch $type {
		function {
			set f [open $file a]
			puts $f "\nproc [list $name] \{\} \{\}"
			close $f
		}
		dialog {set cmd Dialog}
		toplevel {set cmd Toplevel}
		frame {set cmd Topframe}
		default {error "unkown type: \"$type\"}
	}
	if {"$type" != "function"} {
		set create \n[list Classy::$cmd subclass [list $name]]
		set code "\n[list $name] method init {args} \{"
		append code \n\t[list super init]
		append code "\n\tset window \$object"
		append code \n\t[list if {"$args" == "___Classy::Builder__create"} {return $window}]
		append code \n\t[list # Configure initial "\[$object cmdw\]"]
		append code \n\t[list if {"$args" != ""} {eval $window configure $args}]
		append code "\n\treturn \$window"
		append code \n\}
		set f [open $file a]
		puts $f \n$create
		puts $f $code
		close $f
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
			set function [lindex $args 0]
			set c [splitcomplete [readfile $file]]
			set pos [lsearch -glob $c [list proc $function *]]
			if {$pos != -1} {
				return [lindex $c $pos]\n
			} else {
				set pos [lsearch -glob $c [list * subclass $function]]
				if {$pos == -1} {
					error "\"$function\" not found in file \"$file\""
				}
				set result [lindex $c $pos]\n
				set pos [lsearch -glob $c [list $function method init *]]
				append result [lindex $c $pos]\n
				set poss [lfind -glob $c [list $function addoption *]]
				foreach pos $poss {
					append result [lindex $c $pos]\n
				}
				set poss [lfind -glob $c [list $function method *]]
				foreach pos $poss {
					append result [lindex $c $pos]\n
				}
				return $result
			}
		}
		set {
			set function [lindex $args 0]
			set code [lindex $args 1]
			set done 0
			set c [splitcomplete [readfile $file]]
			if [string match "proc *" $code] {
				uplevel #0 $code
				set pos [lsearch -glob $c [list proc $function *]]
				if {$pos == -1} {
					lappend c {} $code
				} else {
					set c [lreplace $c $pos $pos $code]
				}
			} else {
				set pos1 [lsearch -glob $c [list * subclass $function]]
				if {$pos1 == -1} {
					uplevel #0 $code
					lappend c {} $code
				} else {
					regsub "^\[^\n\]+subclass $function\n" $code {} temp
					uplevel #0 $temp
					set pos [lsearch -glob $c [list $function method init *]]
					set c [lreplace $c $pos $pos]
					set poss [lfind -glob $c [list $function addoption *]]
					set c [lsub $c -exclude $poss]
					set poss [lfind -glob $c [list $function method *]]
					set c [lsub $c -exclude $poss]
					set c [lreplace $c $pos1 $pos1 $code]
				}
			}
			$object infile _save $file $function $c
			if [string match "proc *" $code] {
				catch {rename $function {}}
			}
		}
		_save {
			catch {file copy -force $file $file~}
			set function [lindex $args 0]
			set c [lindex $args 1]
			set f [open $file w]
			set space 0
			foreach line $c {
				if ![string length $line] {
					if $space continue
					set space 1
				} else {
					set space 0
				}
				puts $f $line
			}
			close $f
			catch {Classy::auto_mkindex [file dirname $file] *.tcl}
			set ::auto_index($function) [list source $file]
		}
		ls {
			set c [splitcomplete [readfile $file]]
			foreach line $c {
				if {"[lindex $line 0]" == "proc"} {
					lappend result [lindex $line 1]
				} elseif {"[lindex $line 1]" == "subclass"} {
					lappend result [lindex $line 2]
				}
			}
			return $result
		}
		delete {
			set function [lindex $args 0]
			set c [splitcomplete [readfile $file]]
			set pos [lsearch -glob $c [list proc $function *]]
			if {$pos != -1} {
				set c [lreplace $c $pos $pos]
			} else {
				set pos [lsearch -glob $c [list * subclass $function]]
				if {$pos == -1} {
					error "\"$function\" not found in file \"$file\""
				}
				set c [lreplace $c $pos $pos]
				set pos [lsearch -glob $c [list $function method init *]]
				set c [lreplace $c $pos $pos]
				set poss [lfind -glob $c [list $function addoption *]]
				set c [lsub $c -exclude $poss]
				set poss [lfind -glob $c [list $function method *]]
				set c [lsub $c -exclude $poss]
			}
			$object infile _save $file $function $c
			catch {rename $function {}}
			catch {unset ::auto_index($function)}
		}
		rename {
			set function [lindex $args 0]
			set newfunction [lindex $args 1]
			set ls [$object infile ls $file]
			if {[lsearch $ls $newfunction] != -1} {
				error "proc \"$newfunction\" already exists  in file \"$file\""
			}
			if [string length [info commands $newfunction]] {
				error "command \"$newfunction\" already exists"
			}
			set c [splitcomplete [readfile $file]]
			set pos [lsearch -glob $c [list proc $function *]]
			if {$pos != -1} {
				regsub "^proc $function" [lindex $c $pos] "proc $newfunction" line
				set c [lreplace $c $pos $pos $line]
				uplevel #0 $line
			} else {
				set pos [lsearch -glob $c [list * subclass $function]]
				if {$pos == -1} {
					error "\"$function\" not found in file \"$file\""
				}
				regsub "subclass $function\$" [lindex $c $pos] "subclass $newfunction" line
				set c [lreplace $c $pos $pos $line]
				uplevel #0 $line
				set pos [lsearch -glob $c [list $function method init *]]
				regsub "^$function " [lindex $c $pos] "$newfunction " line
				set c [lreplace $c $pos $pos $line]
				uplevel #0 $line
				set poss [lfind -glob $c [list $function addoption *]]
				set poss [concat $poss [lfind -glob $c [list $function method *]]]
				foreach pos $poss {
					regsub "^$function " [lindex $c $pos] "$newfunction " line
					set c [lreplace $c $pos $pos $line]
					uplevel #0 $line
				}
			}
			$object infile _save $file $function $c
			catch {rename $function {}}
			catch {unset ::auto_index($function)}
		}
		add {
			set code [lindex $args 0]
			if [string match "proc *" $code] {
				set function [lindex $code 1]
			} else {
				set split [splitcomplete $code]
				set function [lindex [lindex $split 0] 2]
			}
			set funcs [$object infile ls $file]
			if {[lsearch $funcs $function] != -1} {
				set num 1
				while {[lsearch $funcs $function#$num] != -1} {incr num}
				set newfunction $function#$num
				if [string match "proc *" $code] {
					regsub "^proc $function" $code "proc $newfunction"
				} else {
					set newcode ""
					foreach line $split {
						regsub "subclass $function\$" $line "subclass $newfunction" line
						regsub "^$function " $line "$newfunction " line
						append newcode $line\n
					}
					set code $newcode
				}
				set function $newfunction
			}
			uplevel #0 $code
			$object infile set $file $function $code
			set pnode [list $file {} file]
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
			catch {Classy::auto_mkindex [file dirname $file] *.tcl}
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
			if [regexp {^Classy::Toplevel subclass (.+)$} $line temp func] {
				$object.browse addnode $root [list $browse(file) $func toplevel] \
					-type end -text $func -image [Classy::geticon newtoplevel]
			} elseif [regexp {^Classy::Dialog subclass (.+)$} $line temp func] {
				$object.browse addnode $root [list $browse(file) $func dialog] \
					-type end -text $func -image [Classy::geticon newdialog]
			} elseif [regexp {^Classy::Topframe subclass (.+)$} $line temp func] {
				$object.browse addnode $root [list $browse(file) $func frame] \
					-type end -text $func -image [Classy::geticon newframe]
			} elseif [regexp ^proc $line] {
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
	catch {Classy::auto_mkindex $defdir *.tcl}
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
	$w.edit configure -savecommand [list $object savefunction $w $file $function]
}

Classy::Builder method savefunction {w file function code} {
putsvars object w file function code
	set def "proc $function [list [$w.args get]] \{\n$code\n\}"
	uplevel #0 $def
	$object infile set $file $function $def
	$w.edit textchanged 0
	$w configure -title $function
}

Classy::Builder method rename {args} {
	if {"$args" == ""} {
		Classy::InputDialog $object.input -label "Rename \"[lindex [lindex [$object.browse selection] 0] 1]\" to" \
			-command "$object rename [$object.browse selection]"
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

