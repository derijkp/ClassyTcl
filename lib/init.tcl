# Initialisation of the Class package
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================
package require Tcl 8.0
# $Format: "set ::class::version 0.$ProjectMajorVersion$"$
set ::class::version 0.3
# $Format: "set ::class::patchlevel $ProjectMinorVersion$"$
set ::class::patchlevel 10
package provide Class $::class::version


# Load the shared library if present
# If not, Tcl code will be loaded when necessary
#

# The export function
# is used in the Tcl files to automatically export the
# public functions from the class namespace, and import them 
# in the parent namespace.

namespace eval ::class {}
namespace eval ::Classy {}
namespace eval ::Dialog {}

if [file exists [file join ${::class::dir} classy[info sharedlibextension]]] {
	if {"[info commands ::class::reinit]" == ""} {
		load [file join ${::class::dir} classy[info sharedlibextension]]
	}
}

#
# The lib dir contains the Tcl code defining the public Class 
# functions. The lib dir is added to the auto_path so that
# these functions will be loaded on demand. 
proc tm {args} {puts "[string range $args 0 20]: [uplevel 1 [list time $args]]"}

lappend auto_path [file join ${::class::dir} lib] [file join ${::class::dir} classes]

source [file join $::class::dir lib Class.tcl]
