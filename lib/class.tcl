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
#
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

proc ::class::parent {object} {
	return [set ::class::parent($object)]
}

proc ::class::children {class} {
	return [lsort [array names ::class::${class},,child]]
}

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

proc ::class::Class,,m,class {class object} {
#Class
	return $class
}

#
# =========================================
# Variable access
# =========================================
#
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
