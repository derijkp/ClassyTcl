#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::DynaTool
# ----------------------------------------------------------------------
#doc DynaTool title {
#DynaTool
#} index {
# Common tools
#} shortdescr {
# Toolbar widget: nice little buttons in a row
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# The DynaTool widgets are toolbars, for which the contents are managed by
# the DynaTool class in an easy and dynamic way.
# DynaTool can handle several tooltypes.
#<p>
# Each tooltype is defined by a <a href="../classy_dynatool.html">definition in a simple format</a>. 
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
# These will be added to tclIndex by Classy::auto_mkindex
#auto_index DynaTool

option add *Classy::DynaTool.Button.padY 0 widgetDefault
option add *Classy::DynaTool.Checkbutton.padY 1 widgetDefault
option add *Classy::DynaTool.Menubutton.padY 1 widgetDefault

bind Classy::DynaTool <Configure> "%W redraw"

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::DynaTool
Classy::export DynaTool {}

Classy::DynaTool method init {args} {
	# REM Create object
	# -----------------
	super init
	$object configure -bd 0
	# REM Create bindings
	# -------------------
	# REM Initialise variables
	# ------------------------
	private $object data
	catch {unset data(slaves)}
	set data(type) ""
	set data(cmdw) ""
	set data(checks) ""
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	Classy::todo $object redraw
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::DynaTool chainoptions {$object}

Classy::DynaTool addoption -type {type Type {}} {
	private $object data options
	private $class tooldata tools
	set prev $options(-type)
	if [info exists tools($prev)] {
		set tools($prev) [lremove $tools($prev) $object]
	}
	lappend tools($value) $object
	set cmdw $data(cmdw)
	set num 0
	eval destroy [winfo children $object]
	catch {unset data(slaves)}
	if ![info exists tooldata($value)] {
		if [info exists ::Classy::configtoolbar($value)] {
			set tooldata($value) $::Classy::configtoolbar($value)
		} else {
			return -code error "Toolbar type \"$value\" not defined"
		}
	}
	set list [splitcomplete $tooldata($value)]
	if {[lsearch -regexp $list "^\[\t \]*nodisplay\[\t \]*\$"] != -1} {
		[Classy::window $object] configure -height 0 -width $options(-width)
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
			set command [string::change $command [list %% % %W "\[$object cmdw\]"]]
			if ![catch {set image [Classy::geticon $id reload]}] {
				button $object.$key -image $image -highlightthickness 0 -command [list Classy::check $command]
			} else {
				button $object.$key -text $id -highlightthickness 0 -command [list Classy::check $command]
			}
			lappend data(slaves) $object.$key
		} elseif {"$type"=="check"} {
			set command [lshift current]
			if ![catch {set image [Classy::geticon $id reload]}] {
				checkbutton $object.$key -image $image -indicatoron 0 -highlightthickness 0
			} else {
				checkbutton $object.$key -text $id -highlightthickness 0
			}
			set tempcmd [string::change $command [list %% % %W $cmdw]]
			if [string length $cmdw] {
				eval $object.$key configure $tempcmd
			}
			append data(checks) "$object.$key configure $command\n"
			lappend data(slaves) $object.$key
		} elseif {"$type"=="radio"} {
			set command [lshift current]
			set tempcmd [string::change $command [list %% % %W $cmdw]]
			if ![catch {set image [Classy::geticon $id reload]}] {
				eval {radiobutton $object.$key -image $image -indicatoron 0 -highlightthickness 0} $tempcmd
			} else {
				eval {radiobutton $object.$key -text $id -highlightthickness 0} $tempcmd
			}
			append data(checks) "$object.$key configure $command\n"
			lappend data(slaves) $object.$key
		} elseif {"$type"=="widget"} {
			$id $object.$key
			set command [lshift current]
			set tempcmd [string::change $command [list %% % %W $cmdw]]
			eval $object.$key configure $tempcmd
			append data(checks) "$object.$key configure $command\n"
			update idletasks
			lappend data(slaves) $object.$key
		} elseif {"$type"=="tool"} {
			set cmd [$id $object.$key]
			if {"$cmdw" != ""} {
				eval [string::change $cmd [list %% % %W $cmdw]]
			}
			append data(checks) "$cmd\n"
			update idletasks
			lappend data(slaves) $object.$key
		} elseif {"$type"=="label"} {
			if ![catch {set image [Classy::geticon $id reload]}] {
				label $object.$key -image $image
			} else {
				label $object.$key -text $id
			}
			lappend data(slaves) $object.$key
		} elseif {"$type"=="separator"} {
			lappend data(slaves) separator
		} elseif [regexp ^# $type] {
			continue
		} elseif {"$type" == ""} {
			continue
		} else {
			error "Unknown entrytype $type" 
		}
		Classy::Balloon add $object.$key $help
	}
	$object _placetopfirst
}

Classy::DynaTool addoption -cmdw {cmdw Cmdw {}} {
	$object cmdw $value
}

Classy::DynaTool addoption -width {width Width 0} {
	[Classy::window $object] configure -width $value
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {DynaTool define} cmd {
#pathname define tooltype ?data?
#} descr {
# set the <a href="../classy_dynatool.html">definition describing the tools</a> that will be generated 
# for $tooltype.
# If data is not given, the toolbar definition for $tooltype will be returned.
# Definition of toolbars is usually done in the
# <a href="../classy_configure.html">configuration system</a>.
# You will usually not invoke this method, as the definition of 
# tooltype that isn't managed yet will be automatically fetched and defined
# when creating a new toolbar.
#}
Classy::DynaTool classmethod define {tooltype {data {}}} {
	private $class tooldata keep
	if [info exists tooldata($tooltype)] {
		set keep $tooldata($tooltype)
	} else {
		catch {unset keep}
	}
	if {"$data" != ""} {
		set tooldata($tooltype) $data
		$class redraw $tooltype
	} else {
		return $tooldata($tooltype)
	}
}

#doc {DynaTool redraw} cmd {
#pathname redraw tooltype
#} descr {
# redraw toolbars of type $tooltype
#}
Classy::DynaTool classmethod redraw {tooltype} {
	private $class tooldata keep
	if [catch {$class _refresh $tooltype} result] {
		global errorInfo
		set error $errorInfo
		if [info exists keep] {
			set tooldata($tooltype) $keep
			$class _refresh $tooltype
			append result "\nRestored old tool"
		}
		error $result $error
	}
}

#doc {DynaTool types} cmd {
#pathname types ?pattern? 
#} descr {
#}
Classy::DynaTool classmethod types {{pattern *}} {
	private $class tooldata
	set list ""
	foreach tool [array names ::Classy::configtoolbar] {
		if [string match $pattern $tool] {
			laddnew list $tool
		}
	}
	foreach tool [array names tooldata $pattern] {
		if [string match $pattern $tool] {
			laddnew list $tool
		}
	}
	return $list
}

#doc {DynaTool get} cmd {
#pathname get tooltype
#} descr {
# returns the definition of $tooltype
#}
Classy::DynaTool classmethod get {tooltype} {
	private $class tooldata
	return [join $tooldata($tooltype) "\n"]
}

#doc {DynaTool deletetool} cmd {
#pathname deletetool tool
#} descr {
# delete $tool managed by DynaTool
#}
Classy::DynaTool method destroy {} {
	private $object data
	catch {unset tools($object)}
	catch {unset data(slaves)}
	catch {unset data(type)}
	catch {unset data(cmdw)}
	catch {unset data(checks)}
}

#doc {DynaTool delete} cmd {
#pathname delete tooltype
#} descr {
# delete the definition and all toolbars of $tooltype
#}
Classy::DynaTool classmethod delete {tooltype} {
	private $class tooldata tools
	if ![info exists tooldata($tooltype)] {
		error "Couldn't delete $tooltype; it is not a tooltype managed by $object."
	}
	if [info exists tools($tooltype)] {
		foreach tool $tools($tooltype) {
			destroy $tool
		}
	}
}

Classy::DynaTool classmethod _refresh {tooltype} {
	private $class tools
	set code 0
	set result ""
	if [info exists tools($tooltype)] {
		foreach tool $tools($tooltype) {
			if [winfo exists $tool] {
				set code [catch {$tool configure -type $tooltype} result]
			} else {
				set tools($tooltype) [lremove tools($tooltype) $tool]
			}
		}
	}
	if $code {error $result}
	return $result
}

#doc {DynaTool cmdw} cmd {
#pathname cmdw tool {cmdw {}}
#} descr {
# change the current cmdw for $tool to $cmdw. If the cmdw argument is
# not given, the method returns the current cmdw for $tool.
#}
Classy::DynaTool method cmdw {{cmdw {}}} {
	private $object data options
	if {"$cmdw"==""} {
		return $data(cmdw)
	} else {
		if [info exists data(cmdw)] {
			if {"$data(cmdw)"=="$cmdw"} {return $cmdw}
		}
		set data(cmdw) $cmdw
		if [info exists data(checks)] {
			if [string length $cmdw] {
				set command [string::change $data(checks) [list %% % %W $cmdw]]
				eval $command
			}
		}
		set options(-cmdw) $cmdw
		return $cmdw
	}
}

#doc {DynaTool invoke} cmd {
#pathname invoke curtool index
#} descr {
# invoke the item given by $index in the tool
#}
Classy::DynaTool method invoke {index} {
	$object.b$index invoke
}

#doc {DynaTool reqwidth} cmd {
#pathname reqwidth tool
#} descr {
#}
Classy::DynaTool method reqwidth {tool} {
	private $object data
	set x 0
	if ![info exists data(slaves)] {return 0}
	foreach slave $data(slaves) {
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

Classy::DynaTool method _placetopfirst {} {
	private $object data options
	set mh 0
	set x 0
	if [info exists data(slaves)] {
		foreach slave $data(slaves) {
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
				place $slave -x $x -y 1 -in $object
				raise $slave
			}
			incr x $w
		}
	}
	incr mh [$object cget -bd]
	[Classy::window $object] configure -height $mh
	if {$options(-width) == 0} {
		[Classy::window $object] configure -width [expr $x+2*[$object cget -bd]+1]
	}
}

Classy::DynaTool method redraw {} {
	private $object data
	if ![info exists data(slaves)] {return 0}
	set keep [bind $object <Configure>]
	bind $object <Configure> {}
	set width [expr [winfo width $object]-2*[$object cget -bd]-1]
	set y 0
	set mh 0
	set x 0
	set xs ""
	set curslaves ""
	foreach slave $data(slaves) {
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
			set mh $h
		}
		if {"$slave"!="separator"} {
			lappend curslaves $slave
			place forget $slave
			place $slave -x $x -y $y -in $object
			raise $slave
		}
		incr x $w
	}
	foreach temp $curslaves {
		place $temp -height $mh
	}
	set y [expr $y+$mh+2*[$object cget -bd]+1]
	$object configure -height $y
	after idle "bind $object <Configure> [list $keep]"
}

