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
# The class named Class forms the basis of the 
# <a href="../classy_object_system.html">ClassyTcl object system</a>. It is the
# superclass of all classes and object in ClassyTcl.
# Class provides the functionality to produce classes and objects. Class 
# will normally not be used by itself to create objects.
#}
#}
if 0 {
proc Class {} {}
}
proc putsvars {args} {
	foreach var $args {
		puts [list set $var [uplevel set $var]]
	}
	puts ""
}


#
# ------------------------------------------------------
# Create the work namespace class
# ------------------------------------------------------
#
namespace eval ::class {
	namespace export super
	namespace export private setprivate getprivate privatevar
}

if {"[info commands ::class::reinit]" != ""} {
	set noc 0
	::class::reinit
} else {
#	set noc 1
#	source [file join $class::dir lib Class-tcl.tcl]
}
# this is for C and Tcl implementation again
catch {namespace import ::class::private ::class::privatevar ::class::setprivate ::class::getprivate}
