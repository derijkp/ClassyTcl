#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::DynaTool
# ----------------------------------------------------------------------
#doc DynaTool title {
#DynaTool
#} descr {
# subclass of <a href="../basic/Class.html">Class</a><br>
# DynaTool is not a widget and is not intended to produce instances. 
# It is a class that manages toolbars in an easy and dynamic way.
# DynaTool can handle several tooltypes.
#<p>
# Each tooltype is defined by a definition in a simple format. 
# DynaTool can create one or more toolbars for each
# tooltype. When the definition of the tooltype is changed
# all toolbars of that type will be changed accordingly.
#<p>
# Toolbar definitions for tooltype are usually controlled from the
# Toolbars part of the <a href="../classy_configure.html">configuration 
# system</a>.
#<p>
# A toolbar managed by DynaTool can control several widgets: The commands 
# associated with the toolbar can include a %W, that on invocation is
# changed to the current cmdw (command widget). The cmdw of a toolbar can be
# changed at any time.
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::DynaTool {} {}
proc DynaTool {} {}
}

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

#doc {DynaTool maketool} cmd {
#pathname maketool tooltype tool cmdw
#} descr {
# create a toolbar of type $tooltype. $cmdw
# determines the initial commmand widget.
#}
Classy::DynaTool method maketool {tooltype tool cmdw} {
	private $object cmdws tooldata tooltypes checks slaves
	if ![info exists tooldata($tooltype)] {
		$object define $tooltype
	}
	catch {unset slaves($tool)}
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
	set list [splitcomplete $tooldata($tooltype)]
	if {[lsearch -regexp $list "^\[\t \]*nodisplay\[\t \]*\$"] != -1} {
		$tool configure -height 0 -width 0
		return
	}
	foreach current $list {
		if {"$current" == ""} continue
		set type [lshift current]
		incr num
		set key b$num
		set id [lshift current]
		set help [lshift current]
		if {"$type"=="action"} {
			set command [lshift current]
			regsub -all {%W} $command "\[$object cmdw $tool\]" command
			regsub -all {%%} $command % command
			set image [Classy::geticon $id reload]
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
			set image [Classy::geticon $id reload]
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
			set image [Classy::geticon $id reload]
			if {"$image"!=""} {
				eval {radiobutton $tool.$key -image $image -indicatoron 0 -highlightthickness 0} $tempcmd
			} else {
				eval {radiobutton $tool.$key -text $id -highlightthickness 0} $tempcmd
			}
			append checks($tool) "$tool.$key configure $command\n"
			lappend slaves($tool) $tool.$key
		} elseif {"$type"=="widget"} {
			eval $id $tool.$key
			update idletasks
			lappend slaves($tool) $tool.$key
		} elseif {"$type"=="separator"} {
			lappend slaves($tool) separator
		} elseif [regexp ^# $type] {
			continue
		} elseif {"$type" == ""} {
			continue
		} else {
			error "Unknown entrytype $type" 
		}
		Classy::Balloon add $tool.$key $help
	}
	$object _placetopfirst $tool
}

#doc {DynaTool define} cmd {
#pathname define tooltype ?data?
#} descr {
# set the definition describing the tools that will be generated 
# for $tooltype.
# If data is not given, the toolbar definition for $tooltype will be returned.
# Definition of toolbars is usually done in the
# <a href="../classy_configure.html">configuration system</a>.
# You will usually not invoke this method, as the maketool
# method will automatically define a tooltype that isn't managed yet.
#}
Classy::DynaTool method define {tooltype {data {}}} {
	private $object tooldata keep
	if [info exists tooldata($tooltype)] {set keep $tooldata($tooltype)}
	if {"$data" != ""} {
		set tooldata($tooltype) $data
		$object redraw $tooltype
	} else {
		return $tooldata($tooltype)
	}
}

#doc {DynaTool names} cmd {
#pathname names 
#} descr {
#}
Classy::DynaTool method names {{pattern *}} {
	private $object tooldata
	return [array names tooldata $pattern]
}

Classy::DynaTool method add {tooltype data} {
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

#doc {DynaTool redraw} cmd {
#pathname redraw tooltype
#} descr {
# redraw toolbars of type $tooltype
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

#doc {DynaTool get} cmd {
#pathname get tooltype
#} descr {
# returns the definition of $tooltype
#}
Classy::DynaTool method get {tooltype} {
	private $object tooldata
	return [join $tooldata($tooltype) "\n"]
}

#doc {DynaTool deletetool} cmd {
#pathname deletetool tool
#} descr {
# delete $tool managed by DynaTool
#}
Classy::DynaTool method deletetool {tool} {
	private $object tooldata tooltypes cmdws checks slaves
	if ![info exists tooltypes($tool)] {
		error "Couldn't delete $tool; it is not a tool managed by $object."
	}
	if [winfo exists $tool] {destroy $tool}
	catch {unset slaves($tool)}
	catch {unset tooltypes($tool)}
	catch {unset cmdws($tool)}
	catch {unset checks($tool)}
}

#doc {DynaTool delete} cmd {
#pathname delete tooltype
#} descr {
# delete the definition and all toolbars of $tooltype
#}
Classy::DynaTool method delete {tooltype} {
	private $object tooldata tooltypes cmdws checks
	if ![info exists tooldata($tooltype)] {
		error "Couldn't delete $tooltype; it is not a tooltype managed by $object."
	}
	unset tooldata($tooltype)
#	foreach image [info commands Classy::Tool__img_$tooltype_*] {
#		image delete $image
#	}
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

#doc {DynaTool cmdw} cmd {
#pathname cmdw tool {cmdw {}}
#} descr {
# change the current cmdw for $tool to $cmdw. If the cmdw argument is
# not given, the method returns the current cmdw for $tool.
# This method is automatically called when a widget which has bindtags
# defined by DynaTool recieves the focus.
#}
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

#doc {DynaTool invoke} cmd {
#pathname invoke curtool index
#} descr {
# invoke the item given by $index in $curtool
#}
Classy::DynaTool method invoke {curtool index} {
	$curtool invoke $index
}

#doc {DynaTool conftool} cmd {
#pathname conftool tooltype
#} descr {
#}
Classy::DynaTool method conftool {tooltype} {
	Classy::Configurator conftool $tooltype
}

#Classy::DynaTool method loadtool {tooltype {file {}}} {
#	if {"$file"==""} {
#		set file [Classygetconffile $tooltype.tool]
#	}
#	if [file exists $file] {
#		set f [open $file]
#		set c [read $f]
#		close $f
#		$object define $tooltype $c
#		return $file
#	} else {
#		error "tool file $tooltype.tool not found in search path"
#	}
#}

#doc {DynaTool reqwidth} cmd {
#pathname reqwidth tool
#} descr {
#}
Classy::DynaTool method reqwidth {tool} {
	private $object slaves
	set x 0
	if ![info exists slaves($tool)] {return 0}
	foreach slave $slaves($tool) {
		if {"$slave"=="separator"} {
			incr x 5
		} else {
			incr x [winfo reqwidth $slave]
		}
	}
	return [expr $x+2*[$tool cget -bd]+1]
}

#doc {DynaTool reqheight} cmd {
#pathname reqheight tool
#} descr {
#}
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
	if [info exists slaves($tool)] {
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
	}
	incr mh [$tool cget -bd]
	$tool configure -height $mh -width [expr $x+2*[$tool cget -bd]+1]
	bind $tool <Configure> "$object _placetop $tool"
}


Classy::DynaTool method _placetop {tool} {
	private $object slaves
	if ![info exists slaves($tool)] {return 0}
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
