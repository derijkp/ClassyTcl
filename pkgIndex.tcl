# Tcl package index file, version 1.0
# This file is sourced either when an application starts up or
# by a "package unknown" script.  It invokes the
# "package ifneeded" command to set up package-related
# information so that packages will be loaded automatically
# in response to "package require" commands.  When this
# script is sourced, the variable $dir must contain the
# full path name of this file's directory.

namespace eval __temp [list set dir $dir]
namespace eval __temp {
	# $Format: "\tset version 0.$ProjectMajorVersion$"$
	set version 0.1
	# $Format: "\tset minorversion $ProjectMinorVersion$"$
	set minorversion 6
	regsub -all {[ab]} $version {} version
	set loadcmd {
		package provide Class @version@
		namespace eval ::class {set dir @dir@}
		source [file join @dir@ lib init.tcl]
		namespace eval ::class {set version @version@}
		namespace eval ::class {set minorversion @minorversion@}
	}
	regsub -all {@version@} $loadcmd [list $version] loadcmd
	regsub -all {@minorversion@} $loadcmd [list $minorversion] loadcmd
	regsub -all {@dir@} $loadcmd [list $dir] loadcmd
	package ifneeded Class $version $loadcmd

	set loadcmd {
		package provide ClassyTcl @version@
		namespace eval ::Classy {}
		set ::Classy::script [info script]
		source [file join @dir@ lib classyinit.tcl]
	}
	regsub -all {@version@} $loadcmd [list $version] loadcmd
	regsub -all {@dir@} $loadcmd [list $dir] loadcmd
	package ifneeded ClassyTcl $version $loadcmd
}
namespace delete __temp

