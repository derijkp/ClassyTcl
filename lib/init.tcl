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
set ::class::patchlevel 4
package provide Class $::class::version

# Load the shared library if present
# If not, Tcl code will be loaded when necessary
#
namespace eval ::class {
	proc export {items cmds} {
		eval $cmds
		eval namespace export $items		
		catch {
			namespace eval [namespace parent] \
				[list foreach item $items {namespace import ::class::$item}]
		}
	}
}

namespace eval ::Classy {
	proc export {items cmds} {
		eval $cmds
		eval namespace export $items		
		catch {
			namespace eval [namespace parent] \
				[list foreach item $items {namespace import ::Classy::$item}]
		}
	}
}

namespace eval ::Dialog {}

if [file exists [file join ${::class::dir} classy[info sharedlibextension]]] {
	if {"[info commands ::class::reinit]" == ""} {
		load [file join ${::class::dir} classy[info sharedlibextension]]
	}
} else {
	source [file join ${::class::dir} lib Class.tcl]
}

#
# The lib dir contains the Tcl code defining the public Class 
# functions. The lib dir is added to the auto_path so that
# these functions will be loaded on demand. The export function
# is used in the Tcl files to automatically export the
# public functions from the class namespace, and import them 
# in the parent namespace.
#

lappend auto_path [file join ${::class::dir} lib] [file join ${::class::dir} classes]
proc tm {args} {puts "[string range $args 0 20]: [uplevel 1 [list time $args]]"}

source [file join $::class::dir lib Class.tcl]

