# Tcl package index file, version 1.0
# This file is sourced either when an application starts up or
# by a "package unknown" script.  It invokes the
# "package ifneeded" command to set up package-related
# information so that packages will be loaded automatically
# in response to "package require" commands.  When this
# script is sourced, the variable $dir must contain the
# full path name of this file's directory.

namespace eval ::__temp {}
proc ::__temp::initpkg dir {
	# $Format: "\tset version 0.$ProjectMajorVersion$"$
	set version 0.3
	# $Format: "\tset minorversion $ProjectMinorVersion$"$
	set minorversion 2
	regsub -all {[ab]} $version {} version
	set loadcmd {
		package provide Class @version@
		namespace eval ::class {}
		set ::class::dir @dir@
		source [file join @dir@ lib init.tcl]
		set ::class::version @version@
		set ::class::minorversion @minorversion@
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
::__temp::initpkg $dir

