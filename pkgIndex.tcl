# Tcl package index file, version 1.0
# This file is sourced either when an application starts up or
# by a "package unknown" script.  It invokes the
# "package ifneeded" command to set up package-related
# information so that packages will be loaded automatically
# in response to "package require" commands.  When this
# script is sourced, the variable $dir must contain the
# full path name of this file's directory.

# $Format: "package ifneeded Class 0.$ProjectMajorVersion$ \\"$
package ifneeded Class 0.3 \
	"[list namespace eval ::class {}] ; [list set ::class::dir $dir] ; [list source [file join $dir lib init.tcl]]"

# $Format: "package ifneeded ClassyTcl 0.$ProjectMajorVersion$ \\"$
package ifneeded ClassyTcl 0.3 \
	"namespace eval ::Classy {} ; set ::Classy::script \[info script\] ; [list source [file join $dir lib classyinit.tcl]]"
