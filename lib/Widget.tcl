#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Widget
# ----------------------------------------------------------------------
package require Tk

# This is to get the attention of auto_mkindex
if 0 {
proc ::Widget {} {}
}

catch {Widget destroy}

# ----------------------------------------------------------------------
# Change the destroy command
# ----------------------------------------------------------------------
if {"[info commands ::class::Tk_destroy]" == ""} {
	rename destroy ::class::Tk_destroy
	proc destroy {args} {
		foreach w $args {
			if {"$w" == "."} {
				exit
			}
			foreach c [info commands ::class::Tk_$w.*] {
				regexp {^::class::Tk_(.*)$} $c temp tempw
				catch {$tempw destroy}
			}
			if {"[info commands ::class::Tk_$w]" != ""} {
				catch {$w destroy}
			}
		}
		eval ::class::Tk_destroy $args
	}
}

# ----------------------------------------------------------------------
# Change the bgerror command
# ----------------------------------------------------------------------
source [file join $::class::dir lib error.tcl]

# ----------------------------------------------------------------------
# special commands
# ----------------------------------------------------------------------

namespace eval ::class {
	namespace export findoptions setoption getoption getconfigure
}

proc ::class::getwidgetoptions {w} {
	foreach list [$w configure] {
		lappend options [lindex $list 0]
	}
	return $options
}

proc ::class::getwidgetdefaults {w} {
	foreach list [$w configure] {
		lappend options [lindex $list end]
	}
	return $options
}

proc ::class::getwidgetmethods {w} {
	catch {$w @} result
	if ![regsub "bad option \"@\": must be " $result {} result] {
		return -code error $result
	}
	regsub -all {,} $result {} result
	return $result
}

proc ::class::findoptions {class object} {
	private $class options _chain
	set result [array names options]
	eval laddnew result [lremove [array names _chain] {}]
	if [info exists _chain()] {
		eval laddnew result [::class::getwidgetoptions [subst $_chain()]]
	}
	return $result
}

proc ::class::getconfigure {class object option} {
	if [info exists ::class::${object},,v,options($option)] {
		set result "$option [set ::class::${class},,v,options($option)]"
		lappend result [set ::class::${object},,v,options($option)]
		return $result
	}
	private $class _chain
	if [info exists _chain($option)] {
		return [lreplace [[subst [lindex $_chain($option) 0]] configure [lindex $_chain($option) 1]] 0 0 $option]
	} elseif [info exists _chain()] {
		return [lreplace [[subst $_chain()] configure $option] 0 0 $option]
	} else {
		return -code error "unknown option \"$option\""
	}
}

proc ::class::getoption {class object option} {
	if [info exists ::class::${object},,v,options($option)] {
		return [set ::class::${object},,v,options($option)]
	}
	private $class _chain
	if [info exists _chain($option)] {
		return [[subst [lindex $_chain($option) 0]] cget [lindex $_chain($option) 1]]
	} elseif [info exists _chain()] {
		return [[subst $_chain()] cget $option]
	} else {
		return -code error "unknown option \"$option\""
	}
}

proc ::class::setoption {class object option value} {
	set classvar ::class::${class},,v,options($option)
	set privatevar ::class::${object},,v,options($option)
	if ![info exists $classvar] {
		private $class _chain
		if [info exists _chain($option)] {
			foreach {w wopt} $_chain($option) {
				[subst $w] configure $wopt $value
			}
		} elseif [info exists _chain()] {
			[subst [getprivate $class _chain()]] configure $option $value
		} else {
			return -code error "unknown option \"$option\""
		}
	} else {
		if [catch {::class::${class},,m,_set${option} $class $object $value} result] {
			return -code error "error while setting option $option to \"$value\": $result"
		} else {
			set value $result
		}
		set $privatevar $value
	}
	return $value
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Class subclass Widget
proc Widget [info args Widget] "if \[regexp {^\\.} \$cmd\] {set args \[concat \$cmd \$args\];set cmd new}\n[info body Widget]"

Widget classmethod init {args} {
	if [regexp :: $object] {
		return -code error "no :: allowed in widget path \"$object\""
	}
	catch {rename ::class::tempcmd {}}
	rename $object ::class::tempcmd
	set len [llength $args]
	if [catch {
		if {$len == 0} {
			frame $object -class $class
		} elseif {$len == 1} {
			switch $args {
				frame -
				toplevel {
					$args $object -class $class
				}
				default {
					$args $object
					set tags [bindtags $object]
					bindtags $object [concat [lindex $tags 0] $class [lrange $tags 1 end]]
				}
			}
		} else {
			eval $args
		}
	} result] {
		rename ::class::tempcmd $object
		return -code error $result
	}
	rename $object ::class::Tk_$object
	rename ::class::tempcmd ::$object

	# set options
	foreach option [array names ::class::${class},,v,options] {
		set default [set ::class::${class},,v,options($option)]
		set value [option get $object [lindex $default 0] [lindex $default 1]]
		if {"$value" != ""} {
			set ::class::${object},,v,options($option) $value
		} else {
			set ::class::${object},,v,options($option) [lindex $default 2]
		}
	}
	return ::class::Tk_$object
}

# ------------------------------------------------------------------
#  Class variable
# ------------------------------------------------------------------

Widget	private _chain() {::class::Tk_$object}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Widget classmethod configure {args} {
	private $class options
	if {"$args" == ""} {
		set result ""
		foreach option [array names options] {
			lappend result [concat $option $options($option) [list [lindex $options($option) end]]]
		}
		return $result
	} elseif {[llength $args] == 1} { 
		set option [lindex $args 0]
		if [info exists options($option)] {
			return [concat $option $options($option) [list [lindex $options($option) end]]]
		}
	} else {
		foreach {option value} $args {
			if [info exists options($option)] {
				set options($option) [lreplace $options($option) end end $value]
			}
		}
		return {}
	}
}

Widget method configure {args} {
	private $class options
	if {"$args" == ""} {
		set result ""
		foreach option [::class::findoptions $class $object] {
			lappend result [::class::getconfigure $class $object $option]
		}
		return $result
	} elseif {[llength $args] == 1} { 
		set opt [lindex $args 0]
		return [::class::getconfigure $class $object $opt]
	} else {
		foreach {option value} $args {
			::class::setoption $class $object $option $value
		}
		return {}
	}
}

Widget method config {args} {
	eval $object configure $args
}

Widget method cget {option} {
		return [::class::getoption ::$class $object $option]
}

Widget method component {args} {
		set len [llength $args]
		if {$len == 0} {
			set vars [info vars [privatevar $class _comp_*]]
			if {"$vars" == ""} {
				return ""
			} else {
				regsub -all [privatevar $class _comp_] $vars {} vars
				return $vars
			}
		} elseif {$len == 1} {
			set name _comp_[lindex $args 0]
			private $class $name
			if [info exists $name] {
				return [subst [set $name]]
			} else {
				error "$object does not have component \"[lindex $args 0]\""
			}
		} else {
			::$class private _comp_[lindex $args 0] [lindex $args 1]
		}
}

Widget classmethod chainmethods {list widget} {
	if {"$widget" == {$object}} {
		set widget {::class::Tk_$object}
	}
	foreach method $list {
		if [regexp {^configure$|^cget$} $method] continue
		::$class method $method {args} "eval [list $widget] $method \$args"
	}
}

Widget classmethod chainallmethods {widget widgettype} {
	if {"$widget" == {$object}} {
		set widget {::class::Tk_$object}
	}
	catch {destroy .class,,temp}
	$widgettype .class,,temp
	foreach method [::class::getwidgetmethods .class,,temp] {
#		if [regexp {^configure$|^config$|^cget$|^destroy$|^class$|^private$|^component$} $method] continue
		if {"[::$class method $method]" == ""} {
			::$class method $method {args} "uplevel 2 $widget $method \$args"
		}
	}
	destroy .class,,temp
}

Widget	classmethod chainoptions {widget} {
	if {"$widget" == {$object}} {
		set widget {::class::Tk_$object}
	}
	$class private _chain() $widget
}

Widget classmethod chainoption {option widget woption args} {
	if [expr [llength $args]&1] {
		return -code error "wrong # args: should be \"$class chainoption option widget widgetoption ?widget widgetoption ...?\""
	}
	foreach {w wopt} [concat [list $widget] [list $woption] $args] {
		if {"$w" == {$object}} {
			set w {::class::Tk_$object}
		}
		lappend list $w $wopt
	}
	$class private _chain($option) $list
}

Widget classmethod addoption {option default args} {
	if {[llength $default] != 3} {
		return -code error "wrong # of entries in default: should have 3"
	}
	$class private options($option) $default
	if {"[lindex $args 0]" != ""} {
		set cmd [lindex $args 0]
		if ![regexp "return \[^\n\]+\[\n\]*$" $cmd] {
			append cmd "\nreturn \$value"
		}
		$class method _set$option {value} $cmd
	} else {
		$class method _set$option {value} {return $value}
	}
}

Widget classmethod destroy {} {
	rename ::destroy {}
	rename ::class::Tk_destroy ::destroy
	proc ::bgerror {err} $::Classy::keepbgerror
}

# ------------------------------------------------------------------
#  Widget destruction
# ------------------------------------------------------------------

Widget method destroy {} {
	if {"$object" == "."} {
		exit
	}
	Classy::cleartodo $object
	foreach c [info commands ::class::Tk_$object.*] {
		regexp {^::class::Tk_(.*)$} $c temp child
		catch {$child destroy}
	}
	catch {::class::Tk_destroy $object}
}
