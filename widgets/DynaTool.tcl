#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::DynaTool
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::DynaTool {} {}
proc DynaTool {} {}
}
catch {Classy::DynaTool destroy}

option add *Classy::Tool.Button.padY 0 widgetDefault
option add *Classy::Tool.Checkbutton.padY 1 widgetDefault
option add *Classy::Tool.Menubutton.padY 1 widgetDefault

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Class subclass Classy::DynaTool
Classy::export DynaTool {}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::DynaTool method define {tooltype data} {
	private $object tooldata keep
	if [info exists tooldata($tooltype)] {set keep $tooldata($tooltype)}
	set tooldata($tooltype) $data
	$object redraw $tooltype
}

Classy::DynaTool method names {} {
	private $object tooldata
	return [array names tooldata]
}

#Classy::DynaTool method add {tooltype data} {
#	private $object tooldata keep
#	set data [split $data "\n"]
#	set data [lremove $data {}]
#	
#	if ![info exists tooldata($tooltype)] {
#		$object define $tooltype $data
#		return
#	}
#	set mdata $tooldata($tooltype)
#
#	set pos end
#	foreach line $data {
#		if [regexp {^tool} $line] {
#			set tools [lsub $mdata [lfind -regexp $mdata {^tool}]]
#			set search [lsearch -exact $tools $line]
#			if {$search==-1} {
#				lappend mdata $line
#				set pos end
#			} else {
#				set len [llength [lfind -regexp $mdata {^tool}]]
#				incr search
#				if {$search==$len} {
#					set pos end
#				} else {
#					set pos [lindex [lfind -regexp $mdata {^tool}] $search]
#				}
#			}
#		} else {
#			set item [lindex $line 1]
#			set temp [lsearch -regexp $mdata "\[ \t\]*\[a-z\]* $item "]
#			if {$temp==-1} {
#				set mdata [linsert $mdata $pos $line]
#			} else {
#				set mdata [lreplace $mdata $temp $temp $line]
#			}
#		}
#	}
#
#	set keep $tooldata($tooltype)
#	set tooldata($tooltype) $mdata
#	after cancel "$object redraw $tooltype"
#	after idle "$object redraw $tooltype"
#}

Classy::DynaTool method redraw {tooltype} {
	private $object keep
	if [catch {$object _refresh $tooltype} result] {
		global errorInfo
		set error $errorInfo
		if [info exists keep] {
			set tooldata($tooltype) $keep
			$object _refresh $tooltype
			append result "\nRestored old tool"
		}
		error $result $error
	}
}

Classy::DynaTool method get {tooltype} {
	private $object tooldata
	return [join $tooldata($tooltype) "\n"]
}

Classy::DynaTool method deletetool {tool} {
	private $object tooldata tooltypes cmdws checks slaves
	if ![info exists tooltypes($tool)] {
		error "Couldn't delete $tool; it is not a tool managed by $object."
	}
	if [winfo exists $tool] {destroy $tool}
	unset slaves($tool)
	unset tooltypes($tool)
	unset cmdws($tool)
	unset checks($tool)
}

Classy::DynaTool method delete {tooltype} {
	private $object tooldata tooltypes cmdws checks
	if ![info exists tooldata($tooltype)] {
		error "Couldn't delete $tooltype; it is not a tooltype managed by $object."
	}
	unset tooldata($tooltype)
	foreach image [info commands Classy::Tool__img_$tooltype_*] {
		image delete $image
	}
	if [info exists tooltypes] {
		set toollist [array get tooltypes]
		set poss [lfind -exact $toollist $tooltype]
		foreach pos $poss {
			set tool [lindex $toollist [expr $pos-1]]
			if [winfo exists $tool] {destroy $tool}
			unset tooltypes($tool)
			unset cmdws($tool)
			unset checks($tool)
		}
	}
}

Classy::DynaTool method _refresh {tooltype} {
	private $object tooltypes cmdws checks
	if [info exists tooltypes] {
		set toollist [array get tooltypes]
		set poss [lfind -exact $toollist $tooltype]
		foreach pos $poss {
			set tool [lindex $toollist [expr $pos-1]]
			if ![winfo exists $tool] {
				$object deletetool $tool
			} else {
				eval destroy [winfo children $tool]
				$object maketool $tooltype $tool $cmdws($tool)
			}
		}
	}
}

Classy::DynaTool method maketool {tooltype tool cmdw} {
	private $object cmdws tooldata tooltypes checks slaves
	if [info exists slaves($tool)] {
		unset slaves($tool)
	}
	set tooltypes($tool) $tooltype
	set cmdws($tool) $cmdw
	set checks($tool) ""
	set sepnum 0
	if [winfo exists $tool] {
		if {"[$tool cget -class]"!="Classy::Tool"} {
			error "$tool already exists"
		}
	} else {
		frame $tool -class Classy::Tool -bd 0
	}
	set num 0
	foreach current [splitcomplete $tooldata($tooltype)] {
		set type [lshift current]
		incr num
		set key b$num
		set id [lshift current]
		set help [lshift current]
		if {"$type"=="action"} {
			set command [lshift current]
			regsub -all {%W} $command "\[$object cmdw $tool\]" command
			regsub -all {%%} $command % command
			set image [$object image $tool $id]
			if {"$image"!=""} {
				button $tool.$key -image $image -highlightthickness 0 -command [list Classy::check $command]
			} else {
				button $tool.$key -text $id -highlightthickness 0 -command [list Classy::check $command]
			}
			lappend slaves($tool) $tool.$key
		} elseif {"$type"=="check"} {
			set command [lshift current]
			regsub -all {%W} $command $cmdw tempcmd
			regsub -all {%%} $tempcmd % tempcmd
			set image [$object image $tool $id]
			if {"$image"!=""} {
				eval {checkbutton $tool.$key -image $image -indicatoron 0 -highlightthickness 0} $tempcmd
			} else {
				eval {checkbutton $tool.$key -text $id -highlightthickness 0} $tempcmd
			}
			append checks($tool) "$tool.$key configure $command\n"
			lappend slaves($tool) $tool.$key
		} elseif {"$type"=="radio"} {
			set command [lshift current]
			regsub -all {%W} $command $cmdw tempcmd
			regsub -all {%%} $tempcmd % tempcmd
			set image [$object image $tool $id]
			if {"$image"!=""} {
				eval {radiobutton $tool.$key -image $image -indicatoron 0 -highlightthickness 0} $tempcmd
			} else {
				eval {radiobutton $tool.$key -text $id -highlightthickness 0} $tempcmd
			}
			append checks($tool) "$tool.$key configure $command\n"
			lappend slaves($tool) $tool.$key
		} elseif {"$type"=="widget"} {
			lappend slaves($tool) [lshift current]
		} elseif {"$type"=="createwidget"} {
			$id $tool.$key
			update idletasks
			lappend slaves($tool) $tool.$key
		} elseif {"$type"=="separator"} {
			lappend slaves($tool) separator
		} elseif [regexp ^# $type] {
			continue
		} elseif {"$type" ==""} {
			continue
		} else {
			error "Unknown entrytype $type" 
		}
		Classy::Balloon add $tool.$key $help
	}
	$object _placetopfirst $tool
}

Classy::DynaTool method cmdw {tool {cmdw {}}} {
	private $object cmdws
	if {"$cmdw"==""} {
		return $cmdws($tool)
	} else {
		if [info exists cmdws($tool)] {
			if {"$cmdws($tool)"=="$cmdw"} {return $cmdw}
		}
		set cmdws($tool) $cmdw
		private $object checks
		if [info exists checks($tool)] {
			regsub -all {%W} $checks($tool) $cmdw command
			regsub -all {%%} $command % command
			eval $command
		}
		return $cmdw
	}
}

Classy::DynaTool method invoke {curtool index} {
	$curtool invoke $index
}

Classy::DynaTool method conftool {tooltype {options {*}}} {
	Classycustomise__item "Configure tool" $tooltype.tool [list $object loadtool $tooltype %F] $options
}

Classy::DynaTool method loadtool {tooltype {file {}}} {
	if {"$file"==""} {
		set file [Classygetconffile $tooltype.tool]
	}
	if [file exists $file] {
		set f [open $file]
		set c [read $f]
		close $f
		$object define $tooltype $c
		return $file
	} else {
		error "tool file $tooltype.tool not found in search path"
	}
}

Classy::DynaTool method reqwidth {tool} {
	set slaves [place slaves $tool]
	set x 0
	foreach slave $slaves {
		incr x [winfo reqwidth $slave]
	}
	return [expr $x+2*[$tool cget -bd]+1]
}

Classy::DynaTool method reqheight {tool} {
	set slaves [place slaves $tool]
	set mh 0
	foreach slave $slaves {
		set h [winfo reqheight $slave]
		if {$h>$mh} {set mh $h}
	}
	return [expr $mh+2*[$tool cget -bd]+1]
}

Classy::DynaTool method _placetopfirst {tool} {
	private $object slaves
	set mh 0
	set x 0
	foreach slave $slaves($tool) {
		if {"$slave"=="separator"} {
			set w 5
			set h 0
		} elseif ![winfo exists $slave] {
			continue
		} else {
			set w [winfo reqwidth $slave]
			set h [winfo reqheight $slave]
			if {$h>$mh} {set mh $h}
		}
		if {"$slave"!="separator"} {
			place forget $slave
			place $slave -x $x -y 1 -in $tool
			raise $slave
		}
		incr x $w
	}
	incr mh [$tool cget -bd]
	$tool configure -height $mh -width $x
	bind $tool <Configure> "$object placetop $tool"
}

Classy::DynaTool method placetop {tool} {
	private $object slaves
	set keep [bind $tool <Configure>]
	bind $tool <Configure> {}
	set width [expr [winfo width $tool]-2*[$tool cget -bd]-1]
	set y 0
	set mh 0
	set x 0
	set xs ""
	set curslaves ""
	foreach slave $slaves($tool) {
		if {"$slave"=="separator"} {
			set w 5
			set h 0
		} elseif ![winfo exists $slave] {
			continue
		} else {
			set w [winfo reqwidth $slave]
			set h [winfo reqheight $slave]
			if {$h>$mh} {set mh $h}
		}
		set temp [expr $x+$w]
		if {$temp>$width} {
			foreach temp $curslaves {
				place $temp -height $mh
			}
			set curslaves ""
			set x 0
			incr y $mh
#			incr y 2
			set mh $h
		}
		if {"$slave"!="separator"} {
			lappend curslaves $slave
			place forget $slave
			place $slave -x $x -y $y -in $tool
			raise $slave
		}
		incr x $w
	}
	foreach temp $curslaves {
		place $temp -height $mh
	}
	set y [expr $y+$mh+2*[$tool cget -bd]+1]
	$tool configure -height $y
	after idle "bind $tool <Configure> [list $keep]"
}

Classy::DynaTool method image {tool image} {
	private $object tooltypes
	if [catch {set file [Classy::geticon $image.gif]}] {
		if [catch {set file [Classy::geticon $image.xpm]}] {
			return ""
		}
	} else {
		set name Classy::Tool__img_$tooltypes($tool)_$image
	}
	if [info exists $name] {
		$name read $file
	} else {
		if {"[file extension $file]"==".xpm"} {
			global tcl_platform
			package require Img
			if {"$tcl_platform(platform)"=="windows"} {
				image create photo Classy::Tool__${tool}_$image -file $file
			} else {
				image create pixmap Classy::Tool__${tool}_$image -file $file
			}
		} else {
			image create photo Classy::Tool__${tool}_$image -file $file
		}
	}
	return Classy::Tool__${tool}_$image
}
