# Initialisation of the Class package
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================
package require Tcl 8.0
# $Format: "set ::Class::version 0.$ProjectMajorVersion$"$
set ::Class::version 0.4
# $Format: "set ::Class::patchlevel $ProjectMinorVersion$"$
set ::Class::patchlevel 1
package provide Class $::Class::version

proc ::Class::init {name testcmd} {
	global tcl_platform
	foreach var {version patchlevel execdir dir bindir datadir} {
		variable $var
	}
	#
	# If the following directories are present in the same directory as pkgIndex.tcl, 
	# we can use them otherwise use the value that should be provided by the install
	#
	if [file exists [file join $execdir lib]] {
		set dir $execdir
	} else {
		set dir {@TCLLIBDIR@}
	}
	if [file exists [file join $execdir bin]] {
		set bindir [file join $execdir bin]
	} else {
		set bindir {@BINDIR@}
	}
	if [file exists [file join $execdir data]] {
		set datadir [file join $execdir data]
	} else {
		set datadir {@DATADIR@}
	}
	#
	# Try to find the compiled library in several places
	#
	if {"[info commands $testcmd]" != "$testcmd"} {
		set libbase {@LIB_LIBRARY@}
		if [regexp ^@ $libbase] {
			if {"$tcl_platform(platform)" == "windows"} {
				regsub {\.} $version {} temp
				set libbase $name$temp[info sharedlibextension]
			} else {
				set libbase lib${name}$version[info sharedlibextension]
			}
		}
		foreach libfile [list \
			[file join $dir build $libbase] \
			[file join $dir .. $libbase] \
			[file join {@LIBDIR@} $libbase] \
			[file join {@BINDIR@} $libbase] \
			[file join $dir $libbase] \
		] {
			if [file exists $libfile] {break}
		}
		#
		# Load the shared library if present
		# If not, Tcl code will be loaded when necessary
		#
		if [file exists $libfile] {
			if {"[info commands $testcmd]" == ""} {
				load $libfile
			}
		} else {
			set noc 1
			source [file join ${dir} lib listnoc.tcl]
		}
		catch {unset libbase}
	}
}
Class::init Class Class
rename Class::init {}

#
# The lib dir contains the Tcl code defining the public Class 
# functions. The lib dir is added to the auto_path so that
# these functions will be loaded on demand. 

lappend auto_path [file join ${::Class::dir} lib]

source [file join $::Class::dir lib Class.tcl]
