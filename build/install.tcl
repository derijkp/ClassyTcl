#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

# settings
# --------

set libfiles {lib README pkgIndex.tcl help}
set shareddatafiles README
set docs {}
set headers {}
set libbinaries [glob *[info sharedlibextension]]
set binaries {}

# standard
# --------
source [file join [file dir [info script]] buildtools.tcl]
install $argv

