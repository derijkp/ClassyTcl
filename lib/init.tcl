# Initialisation of the Class package
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================
package require Tcl 8.0
# $Format: "set ::Class::version 1.0$ProjectMajorVersion$"$
set ::Class::version 1.0
# $Format: "set ::Class::patchlevel $ProjectMinorVersion$"$
set ::Class::patchlevel 0

package provide Class $::Class::version

source $Class::dir/lib/package.tcl
package::init $Class::dir class Class lib/Class-tcl.tcl

#
# The lib dir contains the Tcl code defining the public Class 
# functions. The lib dir is added to the auto_path so that
# these functions will be loaded on demand. 

lappend auto_path [file join ${::Class::dir} lib]

source [file join $::Class::dir lib Class.tcl]




