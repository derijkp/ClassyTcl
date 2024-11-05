#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

package require pkgtools
cd [pkgtools::startdir]

# settings
# --------

set libfiles {lib README.md pkgIndex.tcl docs}
set shareddatafiles README.md
set docs {}
set headers {}
set binaries {}

# standard
# --------
pkgtools::uninstall $argv
