#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Widget
# ----------------------------------------------------------------------
#doc Widget title {
#Widget
#} descr {
# The Widget class is a subclass of <a href="Class.html">Class</a> that
# forms the basis of all widgets in ClassyTcl.
# Widget provides the functionality to produce objects that behave like
# Tk widgets. However it will normally not be used by itself to 
# create objects.
# Subclasses of Widget are used to produce widgets with extra functionality.
# All these "object widgets" are based on a Tk base widget, which by default
# is a frame, but can be different.<p>
# Widget redefines the Tk destroy and bgerror commands to incorporate
# proper destruction of object widgets.<p>
# If SomeWidgetClass is a subclass of Widget, and objectName starts with a dot,
# the command
# <pre>SomeWidgetClass objectName</pre>
# creates an object (a widget) and a new Tcl command 
# whose name is objectName. This command may be used 
# to invoke various operations on the widget by using commands of the form:
# <pre>objectName method ?...?</pre>
#}
#doc {Widget method} h2 {
#	Widget methods
#} descr {
# The Widget methods are available to all instances of Widget or one
# of its subclasses.
#}
#doc {Widget classmethod} h2 {
#	Widget classmethods
#} descr {
# The Widget classmethods are only available to Widget or one
# of its subclasses, not to its instances.
#}

package require Tk 8.0

# ----------------------------------------------------------------------
# special commands
# ----------------------------------------------------------------------

;proc ::class::getwidgetoptions {w} {
	foreach list [$w configure] {
		lappend options [lindex $list 0]
	}
	return $options
}

;proc ::class::getwidgetdefaults {w} {
	foreach list [$w configure] {
		lappend options [lindex $list end]
	}
	return $options
}

;proc ::class::getwidgetmethods {w} {
	catch {$w @} result
	if ![regsub "bad option \"@\": must be " $result {} result] {
		return -code error $result
	}
	regsub -all {,} $result {} result
	return $result
}

;proc ::class::findoptions {class object} {
	private $class options _chain
	set result [array names options]
	eval laddnew result [lremove [array names _chain] {}]
	if [info exists _chain()] {
		eval laddnew result [::class::getwidgetoptions [subst $_chain()]]
	}
	return $result
}

;proc ::class::getconfigure {class object option} {
	if [info exists ::class::${object},,v,options($option)] {
		set result "$option [set ::class::${class},,v,options($option)]"
		lappend result [set ::class::${object},,v,options($option)]
		return $result
	}
	private $class _chain
	if [info exists _chain($option)] {
		return [lreplace [[subst [lindex $_chain($option) 0]] configure [lindex $_chain($option) 1]] 0 0 $option]
	} elseif [info exists _chain()] {
		set w [subst $_chain()]
		return [lreplace [$w configure $option] 0 0 $option]
	} else {
		return -code error "unknown option \"$option\""
	}
}

;proc ::class::getoption {class object option} {
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

;proc ::class::setoption {class object option value} {
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
		if [catch {$object _set${option} $value} result] {
			return -errorinfo $::errorInfo -code error "error while setting option $option to \"$value\": $result"
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

#doc {Widget method init} cmd {
# init
#} descr {
# The Widget init method will normally be called using the "super init"
# command in the init classmethod of one of its subclasses.
# By default the Widget init method will create an object
# with a frame as Tk base widget.<br>
# If one argument is given, it will be used as the type of the base
# widget of the new object, where the class (if possible) or bindtags
# are adapted to the class name.<br>
# If more than one argument is given, the args will be evaluated to
# create the base widget of the object. In this case getting the class
# and bindtags of the Tk widget right is the resonsability of the caller.
#}
Widget method init {args} {
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
					bindtags $object [lreplace $tags 1 0 $class]
				}
			}
		} else {
			eval $args
		}
	} result] {
		catch {destroy $object}
		rename ::class::tempcmd $object
		return -code error $result
	}
	catch {rename ::class::Tk_$object {}}
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

#doc {Widget classmethod addoption} cmd {
# className addoption <u>option</u> <u>defaultlist</u> ?<u>body</u>?
#} descr {
# addoption is used to add an option to a class. The value of these options
# can be changed or queried for each object (Widget) using the configure
# and cget commands.<br>
# If <u>body</u> is given, it will be executed every time the option is changed.
# In <u>body</u>, the special variables class and object are available.
# Also available is a variable named value. This contains the new
# value for the option on entry. The option value will be set to the
# the return value of command. If no explicit return command is given in 
# command, the option value will be set to the value of the variable
# value at exit.
#<br>
# <u>defaultlist</u> must be a list containing three elements:
# databasename databaseclass defaultvalue
#<br>
# The values of options for each object are stored in the private
# array options, and can be accessed by methods this way.
#} example {
# SomeWidgetClass addoption -try {try Try 1} {return [true $value]}
#}
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

#doc {Widget classmethod configure} cmd {
# className configure ?<u>option</u>? ?<u>value</u>? ?<u>option</u> <u>value</u> ...?
#} descr {
# Query or modify the class specific configuration options.
# If no <u>option</u> is specified, returns a list
# describing all of the available options for the class. 
# If <u>option</u> is specified with
# no <u>value</u>, then the command returns a list describing 
# the <u>option</u> (this list will be identical to 
# the  corresponding  sublist  of  the  value
# returned  if  no  <u>option</u>  is specified).  If one or
# more <u>option</u>-<u>value</u> pairs  are  specified, then the
# command modifies the given class option(s) to have
# the given  value(s)
#} example {
# SomeWidgetClass configure -try yes
#}
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

#doc {Widget method configure} cmd {
# objectName configure ?<u>option</u>? ?<u>value</u>? ?<u>option</u> <u>value</u> ...?
#} descr {
# Query or modify the configuration options of an widget (object).
# If no <u>option</u> is specified, returns a list
# describing all of the available options for the widget. 
# If <u>option</u> is specified with
# no <u>value</u>, then the command returns a list describing 
# the <u>option</u> (this list will be identical to 
# the  corresponding  sublist  of  the  value
# returned if no <u>option</u> is specified). If one or
# more option-value pairs  are  specified, then the
# command modifies the given class option(s) to have
# the given value(s)
#} example {
# SomeWidgetClass configure -try yes
#}
Widget method configure {args} {
	private $class options
	if {"$args" == ""} {
		set result ""
		foreach option [::class::findoptions $class $object] {
			catch {lappend result [::class::getconfigure $class $object $option]}
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

#doc {Widget method cget} cmd {
# objectName cget <u>option</u>
#} descr {
# get the value of the option <u>option</u>
#}
Widget method cget {option} {
		return [::class::getoption ::$class $object $option]
}

#doc {Widget method component} cmd {
# objectName component ?<u>componentname</u>? ?<u>widget</u>?
#} descr {
# If no <u>componentname</u> is given, the names of all accessible 
# components are returned.
# If <u>componentname</u> is given, the component widget associated with
# <u>componentname</u> is returned.
# If <u>componentname</u> and <u>widget</u> are given, <u>widget</u> 
# will be associated as a component with <u>componentname</u>.
#}
Widget classmethod component {args} {
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
			error "$class does not have component \"[lindex $args 0]\""
		}
	} elseif {$len == 2} {
		::$class private _comp_[lindex $args 0] [lindex $args 1]
	} else {
		error "wrong # args: should be \"$class component ?componentname? ?component?\""
	}
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
		error "wrong # args: should be \"$class component ?componentname?\""
	}
}

#doc {Widget classmethod chainmethods} cmd {
# className chainmethods <u>list</u> <u>widget</u>
#} descr {
# chainmethods is a convenience to make commands of the Tk base widget
# or subwidgets available to your class. It will
# chain all methods given in <u>list</u> to <u>widget</u>. You can use the variable
# object in the name; <b>note that if you do this, you must put the $object
# between braces, to delay substitution to when the actual object
# calls the chained method!</b>
#} example {
# SomeWidgetClass chainmethods {set get} {$object}
# SomeWidgetClass chainmethods {action} {$object.subwidget}
#}
Widget classmethod chainmethods {list widget} {
	if {"$widget" == {$object}} {
		set widget {::class::Tk_$object}
	}
	foreach method $list {
		if [regexp {^configure$|^cget$} $method] continue
		::$class method $method {args} "eval [list $widget] $method \$args"
	}
}

#doc {Widget classmethod chainallmethods} cmd {
# className chainallmethods <u>widget</u> <u>widgettype</u>
#} descr {
# chain all commands of <u>widgettype</u> to a Tk widget <u>widget</u>.
# The Tk widgets should be of type widgettype.
# However, commands with the same name of several basic Class methods 
# are ignored (configure, config, cget, destroy, class, private, component).
#} example {
# SomeWidgetClass chainallmethods {$object} text
#}
Widget classmethod chainallmethods {widget widgettype} {
	if {"$widget" == {$object}} {
		set widget {::class::Tk_$object}
	}
	set num 1
	while {[winfo exists .class,,temp$num]} {
		incr num
	}
	if [regexp ^:*Classy:: $widgettype] {
		set methods [$widgettype info methods *]
	} else {
		$widgettype .class,,temp$num
		set methods [::class::getwidgetmethods .class,,temp$num]
	}
	foreach method $methods {
		if [regexp {^cget$|^class$|^component$|^config$|^configure$|^destroy$|^private$|^trace$} $method] continue
		if {"[::$class info methods $method]" == ""} {
			if {"$method" != "destroy"} {
				::$class method $method {args} "uplevel 1 $widget $method \$args"
			} else {
				::$class method destroy {} "uplevel 1 $widget $method \$args"
			}
		}
	}
	destroy .class,,temp$num
if {"$class" != "Classy::Editor"} {
}
}

#doc {Widget classmethod chainoptions} cmd {
# className chainoptions <u>widget</u>
#} descr {
# chainoptions is a convenience to make all options of the base widget
# or a subwidget available to your class. It will
# add all options that <u>widget</u> has to the options
# of the class. Changing one of these options will change the option
# of the chained widget. <b>The options of only one base widget can
# be chained this way!</b>
#} example {
# SomeWidgetClass chainoptions {$object}
#}
Widget	classmethod chainoptions {widget} {
	if {"$widget" == {$object}} {
		set widget {::class::Tk_$object}
	}
	$class private _chain() $widget
}

#doc {Widget classmethod chainoption} cmd {
# className chainoption option <u>widget</u> <u>widgetoption</u> ?<u>widget</u> <u>widgetoption</u>? ...
#} descr {
# chainoption is a convenience to make options of component widgets
# available to your class. One option can be linked to several component
# widgets. Changing the option will change the given widgetoptions for
# all chained widgets. Querying the option will return the value
# of the first chained option.
#} example {
# SomeWidgetClass chainoption -bg {$object} -bg {$object.sub} -fg
#}
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

#doc {Widget classmethod destroy} cmd {
# Widget destroy
#} descr {
# When class Widget is destroyed, it tries to clean up after itself:
# It undoes the redefinition of the destroy and bgerror command
#} example {
# SomeWidgetClass addoption -try {try Try 1} {return [true $value]}
#}
Widget classmethod destroy {} {
	proc ::bgerror {err} $::Classy::keepbgerror
}

Widget classmethod _children {} {
	return ""
}

# ------------------------------------------------------------------
#  Widget destruction
# ------------------------------------------------------------------

#doc {Widget method destroy} cmd {
# objectName destroy
#} descr {
# destroys an instance of Widget or one of its subclasses.
# The Widget class also redefines the Tk destroy command, so
# that objects can also be properly destroyed by the command
# <pre>destroy objectName</pre>
#} example {
# objectName destroy
#}
Widget method destroy {} {
	if {"$object" == "."} {
		exit
	}
	Classy::cleartodo $object
	private $object rebind
	foreach name $rebind {
		$object _unrebind $name
	}
	foreach c [info commands ::class::Tk_$object.*] {
		regexp {^::class::Tk_(.*)$} $c temp child
		catch {$child destroy}
	}
	catch {::Tk::destroy $object}
}

namespace eval Classy::rebind {}

Widget method _rebind {name} {
	private $object rebind
	bindtags $name [bindtags $object]
	rename $name ::Classy::rebind::$name
	set body [string::change {
		if {[info level] == 1} {
			eval @object@ [string::change $args {@name@ @object@}]
		} else {
			eval ::Classy::rebind::@name@ $args
		}
	} [list @name@ $name @object@ $object]]
	uplevel #0 [list proc $name args $body]
	lappend rebind $name
}

Widget method _unrebind {name} {
	private $object rebind
	uplevel #0 [list rename $name {}]
	catch {rename ::Classy::rebind::$name {}}
	set rebind [lremove $rebind $name]
}
