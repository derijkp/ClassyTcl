#!/bin/sh
# the next line restarts using tclsh \
exec tclsh8.0 "$0" "$@"

cd [file dir [info script]]
package require Extral
if {"$argv" == ""} {
Extral::makedoc [lsort [glob widgets/*.tcl]] help/widgets "ClassyTcl widgets and commands"
Extral::makedoc [lsort [glob lib/*.tcl]] help/basic "ClassyTcl basics"
} else {
file rename help/widgets/index.html help/widgets/index.html.save
Extral::makedoc widgets/[lindex $argv 0].tcl help/widgets "ClassyTcl widgets"
file delete help/widgets/index.html
file rename help/widgets/index.html.save help/widgets/index.html
}

