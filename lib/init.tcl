# Initialisation of the Class package
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================
package require -exact Tcl 8.0

# Solve problems with auto_loading from namespaces
# in patchlevels 0 and 1 of Tcl8.0
if {("$tcl_patchLevel" == "8.0")||("$tcl_patchLevel" == "8.0p1")} {
	source [file join $::class::dir patches init.tcl]
}
#
# Load the shared library if present
# If not, Tcl code will be loaded when necessary
#
namespace eval ::class {
	proc export {items cmds} {
		eval $cmds
		eval namespace export $items		
		namespace eval [namespace parent] \
			[list foreach item $items {namespace import ::class::$item}]
	}
}

namespace eval ::Classy {
	proc export {items cmds} {
		eval $cmds
		eval namespace export $items		
		namespace eval [namespace parent] \
			[list foreach item $items {namespace import ::Classy::$item}]
	}
}

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

lappend auto_path [file join ${::class::dir} lib]
