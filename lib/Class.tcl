#
# ClassyTcl
# --------- Peter De Rijk
#
# Class
#
# Create the base class Class, the work namespace ::class
# and all supplementary commands 
#
# ----------------------------------------------------------------------
#doc Class title {
#Class
#} descr {
# The class named Class is the basis of all classes and object in ClassyTcl.
# Class provides the functionality to produce classes and objects. Class 
# will normally not be used by itself to create objects.
#}
#doc {Class intro} h2 {
#	Introduction
#} descr {
# <h3>Classes and objects</h3>
# In ClassyTcl classes and objects are very similar: they are both 
# entities that combine data and methods (actions that can be performed).
# However, classes are usually used as a template to produce a number
# of objects or instances. The class of an object determines wich
# data it stores, and which methods it has available.<p>
# New classes can be created by subclassing existing classes. The subclass
# inherits the data and methods of its parent class. Extra data and methods
# can be added after the new class is created. Inherited methods can be
# replaced or removed.<p>
# When the package ClassyTcl is loaded, it will create one base class 
# named Class. All other classes and object will be derived from this
# base class.<p>
#
# <h3>Classmethods and methods</h3>
# Class provides two types of methods:
#<dl>
#<dt>classmethods
#<dd>
# A classmethod is a command associated with a class.
# A new classmethod can be defined using the classmethod 
# <i>classmethod</i> (which is defined in the basic class named <i>Class</i>
# and always inherited).
# A classmethod can be invoked using the command:
# <pre>SomeClass classmethod ?...?</pre>
# Classmethods are only available to their class, and cannot be invoked
# from instances (objects) of that class.
#<dt>methods
#<dd>
# A method can be defined using the classmethod <i>method</i>.
# A method of a class is available to all instances (objects) of the
# class (and to the the class itself).
# A method can be invoked using a command of the form:
# <pre>pathName method ?...?</pre>
#</dl>
# Methods and classmethods starting with an underscore are hidden: they
# can be invoked, but are not shown when methods are queried.
# A class can have both a method and a classmethod with the same name.
# If this is the case, the method is invoked when doing:
# <pre>pathName name ?...?</pre>
# and the classmethod is used when doing:
# <pre>ClassName name ?...?</pre>
# <p>A new object can be created using the command (classmethod <i>new</i>):
# <pre>SomeClass new object</pre>
# A new class can be created using the command (classmethod <i>subclass</i>):
# <pre>SomeClass subclass SubClass</pre>
# <h3>private variables</h3>
# Each object (or class) can store its data in private variables. A private
# variable should only be used by the object owning it. In ClassyTcl
# private variables are only protected by convention; An object or 
# function can access the private variables of another object, which is
# great for debugging. However, it is not usually good object oriented 
# programming practice to rely on this feature for your programs (data 
# encapsulation). Private variables can be accessed using the following commands:
#<dl>
#<dt>private object var ?var? ...
#<dd>make the local variables in the list refer to the private variables of $object
#<dt>setprivate object var value
#<dd>set the private variable $var of object $object to $value
#<dt>getprivate object var
#<dd>returns the current value of the private variable $var of object $object
#<dt>privatevar object var
#<dd>returns the fully specified name of the private variable $var of object $object. This
#can eg. be used to link a private variable to an entry:
#<pre>entry .e -textvariable [privatevar someobject somevar]</pre>
#</dl>
#
#}

#doc {Class cm} h2 {
# Classmethods
#} descr {
# The classmethods defined by Class can be invoked from all classes.
#}
#doc {Class m} h2 {
# Methods
#} descr {
# The methods defined by Class can be invoked from all objects and classes.
#}
proc putsvars {args} {
	uplevel [list foreach var $args {
		puts "$var:[set $var]"
	}]
	puts ""
}


#
# ------------------------------------------------------
# Create the work namespace class
# ------------------------------------------------------
#
namespace eval ::class {
	set noc 1
	namespace export super
	namespace export private setprivate getprivate privatevar
}
if [catch {package require Extral}] {
	proc ::class::leval {args} {
		eval [eval concat $args]
	}
}

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
			set methods [join [lsort [concat [::class::method $class {}] [::class::classmethod $class {}]]] ", "]
		} else {
			set methods [join [lsort [::class::method $class {}]] ", "]
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
# the init function of class ClassName will be invoked with the arguments
# given after $<u>object</u>.<br>
# Usually, the init method of the superclass
# must be invoked somehere in the init method with appropriate parameters.
# This can be done using the command 
#<pre>super ?...?</pre>.
#}
proc ::class::new {class arg} {
#puts [list new $class $arg]
	set object [lindex $arg 0]
	regsub {^::} $object {} object
	set namespace [namespace qualifiers $object]
	if {"$namespace" != ""} {
		namespace eval $namespace {}
	}
	if [info exists ::class::parent($object)] {
		return -code error "object \"$object\" exists"
	}
	if {"[info commands ::$object]" != ""} {
		return -code error "command \"$object\" exists"
	}
	set ::class::parent($object) $class
	set ::class::${class},,child($object) 1
	set body {
		if [catch {leval ::class::@class@,,m,${cmd} @class@ @object@ $args} result] {
			return -code error -errorinfo [set ::errorInfo] [class::classerror @class@ @object@ $result $cmd $args]
		}
		return $result
	}
	regsub -all {@class@} $body [list $class] body
	regsub -all {@object@} $body [list $object] body
	proc ::$object {cmd args} $body
	set ::class::current $class
	if [info exists ::class::${class},,init] {
		if [catch {leval ::class::${class},,init [list $class] $arg} result] {
			set errorInfo [set ::errorInfo]
			::class::objectdestroy $class $object
			return -code error -errorinfo $errorInfo "init of class [set ::class::current] failed: $result"
		} else {
			return $result
		}
	} elseif {"$class" != "Class"} {
		if [catch {eval super [lrange $arg 1 end]} result] {
			set errorInfo [set ::errorInfo]
			::class::objectdestroy $class $object
			return -code error -errorinfo $errorInfo "init of class [set ::class::current] failed: $result"
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
	if {$len == 0} {
		if [info exists ::class::${class},,subclass] {
			return [array names ::class::${class},,subclass]
		} else {
			return ""
		}
	} elseif {$len != 1} {
		return -code error "wrong # args: should be \"$class subclass class\""
	}
	set child [lindex $arg 0]
	if {"$class" == "$child"} {
		return -code error "class and subclass \"$class\" are identical"
	}
	regsub {^::} $child {} child
	set namespace [namespace qualifiers $child]
	if {"$namespace" != ""} {
		namespace eval $namespace {
			catch {namespace import ::class::super}
			catch {namespace import ::class::private}
			catch {namespace import ::class::privatevar}
			catch {namespace import ::class::setprivate}
			catch {namespace import ::class::getprivate}
		}
	}
	if [info exists ::class::parent($child)] {
		return -code error "object \"$child\" exists"
	}
	if {"[info commands ::$child]" != ""} {
		return -code error "command \"$child\" exists"
	}
	set ::class::parent($child) $class
	set ::class::${class},,child($child) 1
	set ::class::${class},,subclass($child) 1
	set body [info body ::$class]
	regsub -all $class $body [list $child] body
	proc ::$child {cmd args} $body

	namespace eval ::$child {}

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
	foreach child [array names ::class::${class},,child] {
		catch {$child destroy}
	}
	catch {::class::${class},,classdestroy $class}
	if [info exists ::class::parent($class)] {
		if {"$class" != "Class"} {
			set parent [set ::class::parent($class)]
			if [info exists ::class::${parent},,child($class)] {
				unset ::class::${parent},,child($class)
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

#doc {Class cm parent} cmd {
# ClassName parent
#} descr {
# returns the name of the superclass or parent of the class ClassName.
#}
proc ::class::parent {object} {
	return [set ::class::parent($object)]
}

#doc {Class cm children} cmd {
# ClassName children
#} descr {
# returns the names of all children of the class ClassName.
# These include all instances and all direct subclasses of ClassName.
#}
proc ::class::children {class} {
	return [lsort [array names ::class::${class},,child]]
}

proc ::class::super {args} {
	upvar class class object object
	upvar ::class::current current
	while 1 {
		set current [set ::class::parent($current)]
		if {"$current" == "Class"} {return $object}
		if [info exists ::class::${current},,init] {
			break
		}
	}
	if [catch {eval ::class::${current},,init {$class $object} $args} result] {
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

#doc {Class cm method} cmd {
# ClassName method <u>name</u> <u>args</u> <u>body</u>
#<br>
# ClassName method <u>pattern</u>
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
#<br>
# When method is invoked without arguments, a list of all available 
# methods except the hidden methods (those starting with an underscore
# is returned. When it is invoked with one argument, a list
# of all methods matching the pattern is returned
#}
proc ::class::method {class arg} {
	set len [llength $arg]
	if {$len == 0} {
		set result ""
		foreach cmd [lsort [info commands ::class::${class},,m,*]] {
			if [regexp "^::class::${class},,m,(\[^_\].*)\$" $cmd temp name] {
				lappend result $name
			}
		}
		return $result
	} elseif {$len == 1} {
		set result ""
		foreach cmd [lsort [info commands ::class::${class},,m,[lindex $arg 0]]] {
			regexp "^::class::${class},,m,(.*)\$" $cmd temp name
			lappend result $name
		}
		return $result
	} elseif {$len != 3} {
		return -code error "wrong # args: should be \"$class method name args body\""
	}
	set name [lindex $arg 0]
	set args [lindex $arg 1]
	set body "#$class\n"
	append body [lindex $arg 2]
	if {"$name" == "destroy"} {
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
	}
	set args [concat class object $args]
	proc [list ::class::${class},,m,${name}] $args $body
	::class::propagatemethod $class m $name $args $body
	return $name
}

#doc {Class cm classmethod} cmd {
# ClassName classmethod <u>name</u> <u>args</u> <u>body</u>
#<br>
# ClassName classmethod <u>pattern</u>
#} descr {
# define a new classmethod named $<u>name</u> for class ClassName.
# Whenever the classmethod is invoked, the contents of body will be executed.
# The arguments <u>args</u> and <u>body</u> follow the same conventions
# as in the Tcl command proc.
#<br>
# In body two extra local variables are available named class and object.
# Because a classmethod can only be invoked from a class, they are both
# contain the name of the class that invoked the method.
#<br>
# When classmethod is invoked without arguments, a list of all available 
# classmethods except the hidden methods (those starting with an underscore)
# is returned. When it is invoked with one argument, a list
# of all classmethods matching the pattern is returned
#}
proc ::class::classmethod {class arg} {
	set len [llength $arg]
	if {$len == 0} {
		set result ""
		foreach cmd [lsort [info commands ::class::${class},,cm,*]] {
			if [regexp "^::class::${class},,cm,(\[^_\].*)\$" $cmd temp name] {
				lappend result $name
			}
		}
		return $result
	} elseif {$len == 1} {
		set result ""
		foreach cmd [lsort [info commands ::class::${class},,cm,[lindex $arg 0]]] {
			regexp "^::class::${class},,cm,(.*)\$" $cmd temp name
			lappend result $name
		}
		return $result
	} elseif {$len != 3} {
		return -code error "wrong # args: should be \"$class method name args body\""
	}
	set name [lindex $arg 0]
	set args [lindex $arg 1]
	set body "#$class\n"
	append body [lindex $arg 2]
	switch $name {
		classmethod - method - deletemethod - subclass - parent - children -
		new {return -code error "\"$name\" classmethod cannot be redefined"}
		init {
			if {"$class" == "Class"} {
				return -code error "init classmethod of base Class cannot be redefined"
			}
			if {"$body" == ""} {
				if [info exists ::class::${class},,init] {
					unset ::class::${class},,init
					rename ::class::${class},,init {}
					return $name
				}
			} else {
				set ::class::${class},,init 1
				set args [concat class object $args]
				proc [list ::class::${class},,init] $args $body
				return $name
			}
		}
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
		new -
		method {return -code error "\"$name\" method cannot be deleted"}
		init {
			if {"$class" == "Class"} {
				return -code error "init method of base Class cannot be deleted"
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
	}
	if {"[info commands ::class::${class},,m,${name}]" != ""} {
		rename ::class::${class},,m,${name} {}
		::class::propagatedeletemethod $class m $name
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
		classmethod - method - deletemethod - subclass - parent - children -
		new {return -code error "\"$name\" classmethod cannot be deleted"}
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

proc ::Class {cmd args} {
	if {"[info commands ::class::Class,,cm,${cmd}]" != ""} {
		if [catch {leval ::class::Class,,cm,${cmd} Class $args} result] {
			set error [::class::classerror Class Class $result $cmd $args]
			return -code error -errorinfo [set ::errorInfo] $error
		}
	} elseif [catch {leval ::class::Class,,m,${cmd} Class Class $args} result] {
		set error [::class::classerror Class Class $result $cmd $args]
		return -code error -errorinfo [set ::errorInfo] $error
	}
	return $result
}

# Class classmethods
# -------------
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

proc ::class::Class,,cm,parent {class args} {
#Class
	::class::parent $class
}

proc ::class::Class,,cm,children {class} {
#Class
	::class::children $class
}

proc ::class::Class,,cm,private {class args} {
#Class
	::class::classprivatecmd $class $args
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

#doc {Class m class} cmd {
# pathName class
#} descr {
# returns the class of the object given by pathName
#}
proc ::class::Class,,m,class {class object} {
#Class
	return $class
}

#
# =========================================
# Variable access
# =========================================
#
#doc {Class m private} cmd {
# ClassName private ?<u>name</u>? ?<u>value</u>?
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
		return [set ::class::${object},,v,[lindex $arg 0]]
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
		return [set ::class::${class},,v,[lindex $arg 0]]
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

proc ::class::private {object args} {
	foreach var $args {
		uplevel upvar #0 [list ::class::${object},,v,$var] [list $var]
	}
}

proc ::class::privatevar {object var} {
	return ::class::${object},,v,$var
}

proc ::class::setprivate {object var value} {
	set ::class::${object},,v,$var $value
}

proc ::class::getprivate {object var} {
	set ::class::${object},,v,$var
}

namespace import ::class::private ::class::privatevar ::class::setprivate ::class::getprivate

proc ::class::traceobject {object command {level 1}} {
	::class::untraceobject $object
	set class [set ::class::parent($object)]
	if ![info exists ::class::${class},,child($object)] {
		error "Object $object doesn't exists"
	}
	if {[set ::class::${class},,child($object)]!=1} {
		error "$object is a class"
	}
	set temp [varsubst {command level} {
		if {("$level"=="all")||("[info level]"=="$level")} {uplevel #0 $command [list "\$object [list $cmd] $args\n"]}
		# object trace done
	}]
	append temp [info body $object]
	proc ::$object [info args $object] $temp
}

proc ::class::untraceobject {object} {
	set class [set ::class::parent($object)]
	if ![info exists ::class::${class},,child($object)] {
		error "Object $object doesn't exists"
	}
	if {[set ::class::${class},,child($object)]!=1} {
		error "$object is a class"
	}
	set temp [info body $object]
	regsub "^.*# object trace done\n" $temp {} temp
	proc ::$object [info args $object] $temp
}
