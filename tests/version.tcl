#!/bin/sh
# the next line restarts using wish \
exec tclsh8.0 "$0" "$@"

source tools.tcl

catch {Class xx}

test class {is loaded} {
	info commands Class
} {Class}

if [catch {info body Class}] {
	puts "C version"
} else {
	puts "Tcl-only version"
}

testsummarize
