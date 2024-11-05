#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

package require pkgtools
cd [pkgtools::startdir]

# settings
# --------

set libfiles {lib README.md pkgIndex.tcl help init.tcl DESCRIPTION.txt}
set shareddatafiles README.md
set docs {}
set headers {}
puts "dir = [pkgtools::startdir]"
set libbinaries [::pkgtools::findlib [file dir [pkgtools::startdir]] class]
puts "libbinaries = $libbinaries"
set binaries {}
set extname Class

# standard
# --------
pkgtools::install $argv

