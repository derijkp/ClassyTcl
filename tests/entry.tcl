#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::Entry {create and configure} {
	clean
	eval destroy [winfo children .]
	classyinit test
	Classy::Entry .try
	pack .try
	.try configure -label test
	.try cget -label
} {test}

test Classy::Entry {create with configuration configure} {
	clean
	classyinit test
	Classy::Entry .try -label try
	pack .try
	.try cget -label
} {try}

test Classy::Entry {create, destroy, create} {
	clean
	classyinit test
	Classy::Entry .try -label try
	pack .try
	destroy .try
	Classy::Entry .try
	pack .try
	.try cget -label
} {}

test Classy::Entry {create with configuration configure} {
	clean
	classyinit test
	Classy::Entry .try -label try -orient vert
	pack .try
	.try cget -orient
} {vertical}

test Classy::Entry {create with configuration configure} {
	clean
	classyinit test
	Classy::Entry .try -label int -constraint {[0-9]}
	pack .try
	.try cget -constraint
} {[0-9]}

test Classy::Entry {command} {
	clean
	classyinit test
	Classy::Entry .try -label try -command {set ::c 1}
	pack .try
	set ::c 0
	.try set try
	set ::c
} {1}

test Classy::Entry {constraint} {
	clean
	classyinit test
	Classy::Entry .try -label try -constraint {^[a-z]*$}
	pack .try
	.try set try
	.try set try2
	.try get
} {try}

test Classy::FileEntry {create and configure} {
	clean
	eval destroy [winfo children .]
	classyinit test
	Classy::FileEntry .try
	pack .try
	.try configure -label test
	.try cget -label
} {test}

testsummarize
catch {unset errors}
