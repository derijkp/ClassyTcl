#
# ClassyTcl
# --------- Peter De Rijk
#
# Class-tcl
#
# Create the base class Class, the work namespace ::class
# and all supplementary commands: tcl version
#
# ----------------------------------------------------------------------

#doc {Class cm} h2 {
# Classmethods
#} descr {
# The classmethods defined by Class can be invoked from all classes.
#}
#doc {Class m} h2 {
# Methods
#} descr {
# The methods defined by Class can be invoked from all objects
#}

proc ::class::correctcmd {fcmd cmd} {
	set result "$cmd"
	if [regexp {,,cm,} $fcmd] {
		set list [lrange [info args $fcmd] 1 end]
	} else {
		set list [lrange [info args $fcmd] 2 end]
	}
	foreach arg $list {
		if {"$arg" == "args"} {
			append result " ..."
		} elseif [info default $fcmd $arg def] {
			append result " ?$arg?"
		} else {
			append result " $arg"
		}
	}
	return $result
}

proc ::class::classerror {class object result cmd arg} {
	global errorInfo
	set ::class::error $result 
	set ::class::errorInfo $errorInfo 
	if [regexp "called \"(.*)\" with too many arguments" $result temp fcmd] {
		set error "wrong # args: should be \"$object [class::correctcmd $fcmd $cmd]\""
	} elseif [regexp "no value given for parameter \".*\" to \"(.*)\"" $result temp fcmd] {
		set error "wrong # args: should be \"$object [class::correctcmd $fcmd $cmd]\""
	} elseif [regexp "^invalid command name \"(::class::${class},,c?m,.*)\"$" $result temp fcmd] {
		if {"$class"=="$object"} {
			set methods [join [lsort [concat [::class::info_ $class $object methods] [::class::info_ $class $object classmethods]]] ", "]
		} else {
			set methods [join [lsort [::class::info_ $class $object methods]] ", "]
		}
		set error "bad option \"$cmd\": must be $methods"
	} else {
		set error $result
	}
	return $error
}

#doc {Class cm new} cmd {
# ClassName new <u>object</u> ?...?
#} descr {
# create a new instance (or object) with the name $<u>object</u> of class 
# ClassName. When the actual object is created,
# the init method of class ClassName will be invoked with the arguments
# given after $<u>object</u>.<br>
# Usually, the init method of the superclass
# must be invoked somehere in the init method with appropriate parameters.
# This can be done using the command 
#<pre>super init ?...?</pre>.
#}
proc ::class::new {class arg} {
#puts [list new $class $arg]
	set object [lindex $arg 0]
	regsub {^::} $object {} object
	set namespace [namespace qualifiers $object]
	if {"$namespace" != ""} {
		namespace eval $namespace {}
	}
	if {"[info commands ::$object]" != ""} {
		return -code error "command \"$object\" exists"
	}
	set ::class::parent($object) $class
	set ::class::${class},,child($object) 1
	set body {
		if [catch {uplevel ::class::@class@,,m,${cmd} @class@ @object@ $args} result] {
			return -code error -errorinfo [set ::errorInfo] [class::classerror @class@ @object@ $result $cmd $args]
		}
		return $result
	}
	regsub -all {@class@} $body [list $class] body
	regsub -all {@object@} $body [list $object] body
	proc ::$object {cmd args} $body
#	set ::class::current $class
	if [info exists ::class::${class},,init] {
		if [catch {uplevel ::class::${class},,init [list $class] $arg} result] {
			set errorInfo [set ::errorInfo]
			::class::objectdestroy $class $object
			return -code error -errorinfo $errorInfo $result
		} else {
			return $result
		}
	} elseif {"$class" != "Class"} {
		if [catch {eval super init [lrange $arg 1 end]} result] {
			set errorInfo [set ::errorInfo]
			::class::objectdestroy $class $object
			return -code error -errorinfo $errorInfo $result
		} else {
			return $result
		}
	} else {
		return $object
	}
}

#doc {Class cm subclass} cmd {
# ClassName subclass <u>SubClass</u>
#} descr {
# create a new class named $<u>SubClass</u> that inherits data
# and methods from class ClassName. ClassName is the parent or
# superclass of SubClass.
#}
proc ::class::subclass {class arg} {
	set len [llength $arg]
	if {$len != 1} {
		return -code error "wrong # args: should be \"$class subclass class\""
	}
	set child [lindex $arg 0]
	if {"[info commands ::$child]" != ""} {
		return -code error "command \"$child\" exists"
	}
	regsub {^::} $child {} child
	set namespace [namespace qualifiers $child]
	if {"$namespace" != ""} {
		namespace eval $namespace {}
	}
	set ::class::parent($child) $class
	set ::class::${class},,subclass($child) 1
	set body [info body ::$class]
	regsub -all $class $body [list $child] body
	proc ::$child {cmd args} $body

	# copy methods
	foreach cmd [info commands ::class::${class},,m,*] {
		regexp "^::class::${class},,m,(.*)\$" $cmd temp name
		set args ""
		foreach arg [info args $cmd] {
			if [info default $cmd $arg def] {
				lappend args [list $arg $def]
			} else {
				lappend args $arg
			}
		}
		proc ::class::${child},,m,${name} $args [info body $cmd]
	}

	# copy classmethods
	foreach cmd [info commands ::class::${class},,cm,*] {
		regexp "^::class::${class},,cm,(.*)\$" $cmd temp name
		set args ""
		foreach arg [info args $cmd] {
			if [info default $cmd $arg def] {
				lappend args [list $arg $def]
			} else {
				lappend args $arg
			}
		}
		proc ::class::${child},,cm,${name} $args [info body $cmd]
	}

	# copy class variables
	foreach var [info vars ::class::${class},,v,*] {
		regexp "^::class::${class},,v,(.*)\$" $var temp name
		if [array exists $var] {
			array set ::class::${child},,v,${name} [array get $var]
		} else {
			set ::class::${child},,v,${name} [set $var]
		}
	}

	return $child
}

#doc {Class cm destroy} cmd {
# Classname destroy
#} descr {
# destroys a class. All its instances and subclasses and their
# instances will also be destroyed. If the classmethod destroy
# if defined for the class, it will be invoked after the 
# desctruction of its children, but before destroying the class
# itself and and its instances.
#}
proc ::class::classdestroy {class} {
#puts "destroying class $class"
	foreach child [array names ::class::${class},,subclass] {
		catch {::$child destroy}
	}
	foreach child [array names ::class::${class},,child] {
		catch {::$child destroy}
	}
	catch {::class::${class},,classdestroy $class}
	if [info exists ::class::parent($class)] {
		if {"$class" != "Class"} {
			set parent [set ::class::parent($class)]
			if [info exists ::class::${parent},,subclass($class)] {
				unset ::class::${parent},,subclass($class)
			}
		}
		unset ::class::parent($class)
	}
	foreach var [info vars ::class::${class},,*] {
		unset $var
	}
	foreach cmd [info commands ::class::${class},,*] {
		rename $cmd {}
	}
	catch {rename ::$class {}}
}

#doc {Class m destroy} cmd {
# pathName destroy
#} descr {
# destroys an object.
# The destroy method of the objects class (if defined) and those
# of its superclasses (if defined) will be invoked before the 
# destruction of the actual object.
#}
proc ::class::objectdestroy {class object} {
#puts "destroying object $object"
	set current $class
	while {"$current" != ""} {
		catch {::class::$current,,destroy $class $object}
		set current [set ::class::parent($current)]
	}
	if [info exists ::class::parent($object)] {
		unset ::class::parent($object)
	}
	if [info exists ::class::${class},,child($object)] {
		unset ::class::${class},,child($object)
	}
	foreach var [info vars ::class::${object},,*] {
		unset $var
	}
	catch {rename ::$object {}}
	return ""
}

proc super {method args} {
	upvar class class object object
	set level [info level]
	set plevel [expr {$level-2}]
	if [info exists ::class::current($plevel)] {
		set current $::class::current($plevel)
	} else {
		set current $class
	}
	if {"$method" == "init"} {
		while 1 {
			set current [set ::class::parent($current)]
			if {"$current" == "Class"} {
				return $object
			}
			if [info exists ::class::${current},,init] {
				break
			}
		}
		set ::class::current($level) $current
		set error [catch {eval ::class::${current},,init {$class $object} $args} result]
		unset ::class::current($level)
	} elseif [info exists object] {
		set proc ::class::${current},,m,${method}
		if [catch {info body $proc} body] {
			error "No method \"$method\" defined for super of $object (at class \"$current\")"
		}
		regexp "^#(\[^\n\]+)" $body temp cclass
		while 1 {
			set current [set ::class::parent($current)]
			set proc ::class::${current},,m,${method}
			if [catch {info body $proc} body] {
				error "No method \"$method\" defined for super of $object (at class \"$current\")"
			}
			regexp "^#(\[^\n\]+)" $body temp bclass
			if {"$bclass" != "$cclass"} break
		}
		set ::class::current($level) $current
		set error [catch {eval $proc {$class $object} $args} result]
		unset ::class::current($level)
	} else {
		set proc ::class::${current},,cm,${method}
		if [catch {info body $proc} body] {
			error "No classmethod \"$method\" defined for super of $class (at class \"$current\")"
		}
		regexp "^#(\[^\n\]+)" $body temp cclass
		while 1 {
			set current [set ::class::parent($current)]
			set proc ::class::${current},,cm,${method}
			if [catch {info body $proc} body] {
				error "No classmethod \"$method\" defined for super of $class (at class \"$current\")"
			}
			regexp "^#(\[^\n\]+)" $body temp bclass
			if {"$bclass" != "$cclass"} break
		}
		set ::class::current($level) $current
		set error [catch {eval $proc {$class} $args} result]
		unset ::class::current($level)
	}
	if $error {
		error $result
	} else {
		return $result
	}
}

proc ::class::propagatemethod {class type name args body} {
	if ![info exists ::class::${class},,subclass] {
		return ""
	}
	foreach subclass [array names ::class::${class},,subclass] {
		set temp ::class::${subclass},,$type,${name}
		if {("[info commands $temp]" == "")||
			([regexp "^#$class\n" [info body $temp]])} {
			proc $temp $args $body
			::class::propagatemethod $subclass $type $name $args $body
		}
	}
}

proc ::class::propagatedeletemethod {class type name} {
	if ![info exists ::class::${class},,subclass] {
		return ""
	}
	foreach subclass [array names ::class::${class},,subclass] {
		set temp ::class::${subclass},,$type,${name}
		if [regexp "^#$class\n" [info body $temp]] {
			rename $temp {}
			::class::propagatedeletemethod $subclass $type $name
		}
	}
}

#doc {Class m info} cmd {
# pathName info <u>option</u> ?...?
#} descr {
#<b>pathName info class</b><br>
# returns the class of pathName<br>
#<b>pathName info classmethods ?pattern?</b><br>
# returns a list of all available classmethods except the hidden ones (those starting 
# with an underscore is returned. When it is invoked with one argument, a list
# of all classmethods matching the pattern is returned<br>
#<b>pathName info methods ?pattern?</b><br>
# returns a list of all available methods except the hidden methods (those starting 
# with an underscore is returned. When it is invoked with one argument, a list
# of all methods matching the pattern is returned<br>
#<b>pathName info parent</b><br>
# returns the parent of pathName<br>
#<b>pathName info children</b><br>
# returns the children of pathName<br>
#<b>pathName info subclasses</b><br>
# returns the subclasses pathName<br>
#<b>pathName info classmethod option name ...</b><br>
# returns information about the classmethod $name of pathName. Following options are supported:
#<ul>
#<li> body: returns the body of the classmethod (if it is defined in Tcl)
#<li> args: returns the arguments of the classmethod
#<li> default arg varname: returns 0 if the argument $arg does not have a default value, 
# otherwise it returns 1, and places the default value in the variable varname
#</ul>
#<br><b>pathName info method option name ...</b><br>
# returns information about the method $name of pathName. It takes the same options 
# as "info classmethod"
#}
proc ::class::info_ {class object arg} {
	set len [llength $arg]
	if {$len < 1} {
		return -code error "wrong # args: should be \"$object info option ?...?\""
	}
	set option [lindex $arg 0]
	switch $option {
		parent {
			return [set ::class::parent($object)]
		}
		class {
			return $class
		}
		children {
			if {"$class" == "$object"} {
				return [lsort [array names ::class::${class},,child]]
			}
		}
		subclasses {
			if {"$class" == "$object"} {
				if [info exists ::class::${class},,subclass] {
					return [array names ::class::${class},,subclass]
				} else {
					return ""
				}
			}
		}
		methods {
			if {$len == 1} {
				set result ""
				foreach cmd [lsort [info commands ::class::${class},,m,*]] {
					if [regexp "^::class::${class},,m,(\[^_\].*)\$" $cmd temp name] {
						lappend result $name
					}
				}
				return $result
			} elseif {$len == 2} {
				set result ""
				foreach cmd [lsort [info commands ::class::${class},,m,[lindex $arg 1]]] {
					regexp "^::class::${class},,m,(.*)\$" $cmd temp name
					lappend result $name
				}
				return $result
			} else {
				return -code error "wrong # args: should be \"$object info methods ?pattern?\""
			}
		}
		classmethods {
			if {("$class" == "$object")||("$object"=="")} {
				if {$len == 1} {
						set result ""
						foreach cmd [lsort [info commands ::class::${class},,cm,*]] {
							if [regexp "^::class::${class},,cm,(\[^_\].*)\$" $cmd temp name] {
								lappend result $name
							}
						}
						return $result
					} elseif {$len == 2} {
						set result ""
						foreach cmd [lsort [info commands ::class::${class},,cm,[lindex $arg 1]]] {
							regexp "^::class::${class},,cm,(.*)\$" $cmd temp name
							lappend result $name
						}
						return $result
					}
				}
			}
		method {
			set name [lindex $arg 2]
			if {"$name" != "init"} {
				switch [lindex $arg 1] {
					body {
						set body [info body ::class::${class},,m,$name]
						regsub "^#.+\n" $body {} body
						return $body
					}
					args {
						return [lrange [info args ::class::${class},,m,$name] 2 end]
					}
					default {
						if {$len != 5} {
							return -code error "wrong # args: should be \"$object info method default arg varname\""
						}
						return [uplevel 2 info default ::class::${class},,m,$name [lindex $arg 3] [lindex $arg 4]]
					}
					default {
						return -code error "wrong option \"[lindex $arg 1]\" must be body, args or default"
					}
				}
			} else {
				set tmpclass $class
				while 1 {
					set proc ::class::${tmpclass},,$name
					if [string length [info commands $proc]] break
					if {"$tmpclass" == "Class"} {return {}}
					set tmpclass [set ::class::parent($tmpclass)]
				}
				switch [lindex $arg 1] {
					body {
						set body [info body $proc]
						regsub "^#.+\n" $body {} body
						return $body
					}
					args {
						return [lrange [info args $proc] 2 end]
					}
					default {
						if {$len != 5} {
							return -code error "wrong # args: should be \"$class info classmethod default arg varname\""
						}
						return [uplevel 2 info default $proc [lindex $arg 3] [lindex $arg 4]]
					}
					default {
						return -code error "wrong option \"[lindex $arg 0]\" must be body, args or default"
					}
				}
			}
		}
		classmethod {
			if {"$class" == "$object"} {
				set name [lindex $arg 2]
				set proc ::class::${class},,cm,$name
				switch [lindex $arg 1] {
					body {
						set body [info body $proc]
						regsub "^#.+\n" $body {} body
						return $body
					}
					args {
						return [lrange [info args $proc] 1 end]
					}
					default {
						if {$len != 5} {
							return -code error "wrong # args: should be \"$class info classmethod default arg varname\""
						}
						return [uplevel 2 info default $proc [lindex $arg 3] [lindex $arg 4]]
					}
					default {
						return -code error "wrong option \"[lindex $arg 0]\" must be body, args or default"
					}
				}
			} else {
				return -code error "object cannot have classmethods"
			}
		}
	}
	if {"$class" != "$object"} {
		return -code error "wrong option \"$option\" must be parent, class, methods or method"
	} else {
		return -code error "wrong option \"$option\" must be parent, class, children, subclasses, methods, method, classmethods or classmethod"
	}
}

#doc {Class cm method} cmd {
# ClassName method <u>name</u> <u>args</u> <u>body</u>
#} descr {
# define a new method named $<u>name</u> for class ClassName.
# Whenever the method is invoked, the contents of body will be executed.
# The arguments <u>args</u> and <u>body</u> follow the same conventions
# as in the Tcl command proc.
#<br>
# In body two extra local variables are available named class and object.
# They contain the name of respectively the class and the object that
# invoked the method. If the method was invoked from a class, the values
# of variables class and object will be identical (name of the class).
#}
proc ::class::method {class arg} {
	set len [llength $arg]
	if {$len != 3} {
		return -code error "wrong # args: should be \"$class method name args body\""
	}
	set name [lindex $arg 0]
	set args [lindex $arg 1]
	set body "#$class\n"
	append body [lindex $arg 2]
	if {"$name" == "init"} {
		if {"$class" == "Class"} {
			return -code error "init classmethod of base Class cannot be redefined"
		}
		if {"$body" == ""} {
			if [info exists ::class::${class},,init] {
				unset ::class::${class},,init
				rename ::class::${class},,init {}
			}
		} else {
			set ::class::${class},,init 1
			set args [concat class object $args]
			proc [list ::class::${class},,init] $args $body
		}
		return $name
	} elseif {"$name" == "destroy"} {
		if {"$class" == "Class"} {
			return -code error "destroy method of base Class cannot be redefined"
		}
		if {"$args" != ""} {
			return -code error "destroy method cannot have arguments"
		}
		if {"$body" != ""} {
			proc ::class::${class},,destroy {class object} $body
		} elseif {"[info commands ::class::${class},,destroy]" != ""} {
			rename ::class::$class,,destroy {}
		}
		return $name
	} else {
		set args [concat class object $args]
		proc [list ::class::${class},,m,${name}] $args $body
#		if [catch {proc [list ::class::${class},,m,${name}] $args $body} result] {
#			regsub "procedure \".+\"" $result "method \"$name\" of class \"$class\"" result
#			return -code error $result
#		}
		::class::propagatemethod $class m $name $args $body
		return $name
	}
}

#doc {Class cm classmethod} cmd {
# ClassName classmethod <u>name</u> <u>args</u> <u>body</u>
#} descr {
# define a new classmethod named $<u>name</u> for class ClassName.
# Whenever the classmethod is invoked, the contents of body will be executed.
# The arguments <u>args</u> and <u>body</u> follow the same conventions
# as in the Tcl command proc.
#<br>
# In body two extra local variables are available named class and object.
# Because a classmethod can only be invoked from a class, they are both
# contain the name of the class that invoked the method.
#}
proc ::class::classmethod {class arg} {
	set len [llength $arg]
	if {$len != 3} {
		return -code error "wrong # args: should be \"$class method name args body\""
	}
	set name [lindex $arg 0]
	set args [lindex $arg 1]
	set body "#$class\n"
	append body [lindex $arg 2]
	switch $name {
		classmethod - deleteclassmethod - method - deletemethod - subclass - 
		new {return -code error "\"$name\" classmethod cannot be redefined"}
		destroy {
			if {"$class" == "Class"} {
				return -code error "destroy classmethod of base Class cannot be redefined"
			}
			if {"$args" != ""} {
				return -code error "destroy classmethod cannot have arguments"
			}
			if {"$body" != ""} {
				proc ::class::${class},,classdestroy {class} $body
			} elseif {"[info commands ::class::${class},,classdestroy]" != ""} {
				rename ::class::$class,,classdestroy {}
			}
			return $name
		}
	}
	set args [concat class $args]
	proc [list ::class::${class},,cm,${name}] $args $body
#	if [catch {proc [list ::class::${class},,cm,${name}] $args $body} result] {
#		regsub "procedure \".+\"" $result "classmethod \"$name\" of class \"$class\"" result
#		return -code error $result
#	}
	::class::propagatemethod $class cm $name $args $body
	return $name
}

#doc {Class cm deletemethod} cmd {
# ClassName deletemethod <u>name</u>
#} descr {
# delete the method named $<u>name</u> from class ClassName.
# Some special methods cannot be deleted.
#}
proc ::class::deletemethod {class arg} {
	set len [llength $arg]
	if {$len != 1} {
		return -code error "wrong # args: should be \"$class deletemethod name\""
	}
	set name [lindex $arg 0]
	switch $name {
		init {
			if {"$class" == "Class"} {
				return -code error "init classmethod of base Class cannot be deleted"
			}
			if [info exists ::class::${class},,init] {
				unset ::class::${class},,init
				rename ::class::${class},,init {}
				return $name
			}
		}
		destroy {
			if {"$class" == "Class"} {
				return -code error "destroy method of base Class cannot be deleted"
			}
			if {"[info commands ::class::${class},,destroy]" != ""} {
				rename ::class::${class},,destroy {}
			}
		}
		default {
			if {"[info commands ::class::${class},,m,${name}]" != ""} {
				rename ::class::${class},,m,${name} {}
				::class::propagatedeletemethod $class m $name
			}
		}
	}
	return {}
}

#doc {Class cm deleteclassmethod} cmd {
# ClassName deleteclassmethod <u>name</u>
#} descr {
# delete the classmethod named $<u>name</u> from class ClassName.
# Some special classmethods cannot be deleted.
#}
proc ::class::deleteclassmethod {class arg} {
	set len [llength $arg]
	if {$len != 1} {
		return -code error "wrong # args: should be \"$class deleteclassmethod name\""
	}
	set name [lindex $arg 0]
	switch $name {
		classmethod - method - deletemethod - deleteclassmethod - subclass -
		new {return -code error "\"$name\" classmethod cannot be deleted"}
		destroy {
			if {"$class" == "Class"} {
				return -code error "destroy classmethod of base Class cannot be deleted"
			}
			if {"[info commands ::class::${class},,classdestroy]" != ""} {
				rename ::class::$class,,classdestroy {}
			}
			return $name
		}
	}
	if {"[info commands ::class::${class},,cm,${name}]" != ""} {
		rename ::class::${class},,cm,${name} {}
		::class::propagatedeletemethod $class cm $name
	}
	return {}
}

#
# ------------------------------------------------------
# Create the base Class
# ------------------------------------------------------
#
namespace eval ::class {
	set parent(Class) ""
}

#proc ::Class {cmd args} {
#	if [regexp {^\.} $cmd] {set args [concat $cmd $args];set cmd new}
#	if {"[info commands ::class::Class,,cm,${cmd}]" != ""} {
#		if [catch {uplevel ::class::Class,,cm,${cmd} Class $args} result] {
#			set error [::class::classerror Class Class $result $cmd $args]
#			return -code error -errorinfo [set ::errorInfo] $error
#		}
#	} elseif [catch {uplevel ::class::Class,,m,${cmd} Class Class $args} result] {
#		set error [::class::classerror Class Class $result $cmd $args]
#		return -code error -errorinfo [set ::errorInfo] $error
#	}
#	return $result
#}

proc ::Class {cmd args} {
	if [regexp {^\.} $cmd] {set args [concat $cmd $args];set cmd new}
	if [catch {uplevel ::class::Class,,cm,${cmd} Class $args} result] {
		set error [::class::classerror Class Class $result $cmd $args]
		return -code error -errorinfo [set ::errorInfo] $error
	}
	return $result
}

# Class classmethods
# ------------------
proc ::class::Class,,cm,classmethod {class args} {
#Class
	::class::classmethod $class $args
}

proc ::class::Class,,cm,new {class args} {
#Class
	::class::new $class $args
}

proc ::class::Class,,cm,destroy {class} {
#Class
	::class::classdestroy $class
	return {}
}

proc ::class::Class,,cm,method {class args} {
#Class
	::class::method $class $args
}

proc ::class::Class,,cm,deletemethod {class args} {
#Class
	::class::deletemethod $class $args
}

proc ::class::Class,,cm,deleteclassmethod {class args} {
#Class
	::class::deleteclassmethod $class $args
}

proc ::class::Class,,cm,subclass {class args} {
#Class
	::class::subclass $class $args
}

proc ::class::Class,,cm,private {class args} {
#Class
	::class::classprivatecmd $class $args
}

proc ::class::Class,,cm,info {class args} {
#Class
	::class::info_ $class $class $args
}

# Class methods
# -------------
proc ::class::Class,,m,destroy {class object} {
#Class
	::class::objectdestroy $class $object
	return $object
}

proc ::class::Class,,m,private {class object args} {
#Class
	::class::privatecmd $class $object $args
}

proc ::class::Class,,m,info {class object args} {
#Class
	::class::info_ $class $object $args
}

#
# =========================================
# Variable access
# =========================================
#
#doc {Class m private} cmd {
# pathName private ?<u>name</u>? ?<u>value</u>?
#} descr {
# private is used to get or change data associated with an object.
# Without arguments a list of all private variables is returned.
# If the name argument is given, but not the value argument, the 
# current value of private variable $<u>name</u> is returned. If both arguments
# are present, the private variable $<u>name</u> is set to $<u>value</u>.
#}
proc ::class::privatecmd {class object arg} {
	set len [llength $arg]
	if {$len == 0} {
		set list ""
		foreach var [lsort [info vars ::class::${object},,v,*]] {
			regexp "^::class::${object},,v,(.*)\$" $var temp name
			lappend list $name
		}
		return $list
	} elseif {$len == 1} {
		set name ::class::${object},,v,[lindex $arg 0]
		if [info exists $name] {
			return [set $name]
		} else {
			return -code error "\"$object\" does not have a private variable \"[lindex $arg 0]\""
		}
	} elseif {$len == 2} {
		return [set ::class::${object},,v,[lindex $arg 0] [lindex $arg 1]]
	} else {
		return -code error "wrong # args: should be \"$object private ?varName? ?newValue?\""
	}
}

#doc {Class cm private} cmd {
# ClassName private ?<u>name</u>? ?<u>value</u>?
#} descr {
# classmethod private is used to get or change private data 
# associated with a class.
# Without arguments a list of all private class variables is returned.
# If the name argument is given, but not the value argument, the 
# current value of private class variable $<u>name</u> is returned. If both arguments
# are present, the private class variable $<u>name</u> is set to $<u>value</u>.
#}
proc ::class::classprivatecmd {class arg} {
	set len [llength $arg]
	if {$len == 0} {
		set list ""
		foreach var [lsort [info vars ::class::${class},,v,*]] {
			regexp "^::class::${class},,v,(.*)\$" $var temp name
			lappend list $name
		}
		return $list
	} elseif {$len == 1} {
		set name ::class::${class},,v,[lindex $arg 0]
		if [info exists $name] {
			return [set $name]
		} else {
			return -code error "\"$class\" does not have a private variable \"[lindex $arg 0]\""
		}
	} elseif {$len == 2} {
		set name [lindex $arg 0]
		set ::class::${class},,vd($name) 1
		class::propagatevar $class $name [lindex $arg 1]
		return [set ::class::${class},,v,$name [lindex $arg 1]]
	} else {
		return -code error "wrong # args: should be \"$class private ?varName? ?newValue?\""
	}
}

proc ::class::propagatevar {class name value} {
	if ![info exists ::class::${class},,subclass] {
		return ""
	}
	foreach subclass [array names ::class::${class},,subclass] {
		if ![info exists ::class::${subclass},,vd($name)] {
			setprivate $subclass $name $value
			::class::propagatevar $subclass $name $value
		}
	}
}

proc private {object args} {
	foreach var $args {
		uplevel upvar #0 [list ::class::${object},,v,$var] [list $var]
	}
}

proc privatevar {object var} {
	return ::class::${object},,v,$var
}

proc setprivate {object var value} {
	set ::class::${object},,v,$var $value
}

proc getprivate {object var} {
	set ::class::${object},,v,$var
}

Class classmethod trace {command} {
	set temp [info body $class]
	regsub "^.*# class trace done\n" $temp {} temp
	if {"$command" != ""} {
		set temp {
			@command@ [eval list {@class@ [list $cmd]} $args]
			# class trace done
		}
		regsub -all {@command@} $temp $command temp
		regsub -all {@class@} $temp [list $class] temp
		append temp [info body $class]
	}
	proc ::$class [info args $class] $temp
}

Class method trace {command} {
	set temp [info body $object]
	regsub "^.*# object trace done\n" $temp {} temp
	if {"$command" != ""} {
		set temp {
			@command@ [eval list {@object@ [list $cmd]} $args]
			# object trace done
		}
		regsub -all {@command@} $temp $command temp
		regsub -all {@object@} $temp [list $object] temp
		append temp [info body $object]
	}
	proc ::$object [info args $object] $temp
}
