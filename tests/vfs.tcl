#!/bin/sh
# the next line restarts using wish \
exec wish8.3 "$0" "$@"

source tools.tcl
proc clean {} {
	VFS destroy
}

test vfs {glob} {
	clean
	VFS new vfs
	vfs glob *
}