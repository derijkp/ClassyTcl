#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::Text {create and configure} {
	clean
	destroy .try
	classyinit test
	Classy::Text .try
	pack .try -fill both -expand yes
	.try cget -wrap
} {char}

test Classy::Text {insert} {
	clean
	destroy .try
	Classy::Text .try
	pack .try
	.try insert end "try"
	.try get 1.0 end
} {try
}

test Classy::Text {undo} {
	clean
	destroy .try
	Classy::Text .try
	pack .try
	.try insert end "try"
	.try insert 1.2 "try"
	.try undo
	.try get 1.0 end
} {try
}

testsummarize
catch {unset errors}

