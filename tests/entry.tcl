#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::Entry {create and configure} {
	classyclean
	Classy::Entry .try
	pack .try
	.try configure -label test
	.try cget -label
} {test}

test Classy::Entry {create with configuration configure} {
	classyclean
	Classy::Entry .try -label try
	pack .try
	.try cget -label
} {try}

test Classy::Entry {create, destroy, create} {
	classyclean
	Classy::Entry .try -label try
	pack .try
	destroy .try
	Classy::Entry .try
	pack .try
	.try cget -label
} {}

test Classy::Entry {create with configuration configure} {
	classyclean
	Classy::Entry .try -label try -orient vert
	pack .try
	.try cget -orient
} {vertical}

test Classy::Entry {create with configuration configure} {
	classyclean
	Classy::Entry .try -label int -constraint {^[0-9]*$}
	pack .try
	.try cget -constraint
} {^[0-9]*$}

test Classy::Entry {create with configuration configure} {
	classyclean
	Classy::Entry .try -label a* -validate {puts ok}
	pack .try -fill x
	.try cget -validate
} {puts ok}

test Classy::Entry {create with configuration configure} {
	classyclean
	Classy::Entry .try -label a* -validate {
		if ![regexp ^a [.try.get]] {error "\"$new\" does not start with an a"}
		return 1
	}
	pack .try -fill x
	.try cget -validate
} {
		if ![regexp ^a [.try.get]] {error "\"$new\" does not start with an a"}
		return 1
	}

test Classy::Entry {command} {
	classyclean
	Classy::Entry .try -label try -command {set ::c}
	pack .try
	set ::c 0
	.try set try
	set ::c
} {try}

test Classy::Entry {constraint} {
	classyclean
	Classy::Entry .try -label try -constraint {^[a-z]*$} -warn 0
	pack .try
	.try set try
	.try set try2
	.try get
} {try}

test Classy::Entry {gridlabel} {
	classyclean
	Classy::Entry .try -label short -labelwidth 12
	Classy::Entry .try2 -label "a lot longer" -labelwidth 12
	pack .try -fill x
	pack .try2 -fill x
	.try cget -label
} {short}

test Classy::Entry {textvariable} {
	classyclean
	Classy::Entry .try -textvariable try
	pack .try
	set ::try t
	.try get
} {t}

test Classy::Entry {textvariable set before} {
	classyclean
	set ::try t
	Classy::Entry .try -textvariable try
	pack .try
	.try get
} {t}

test Classy::FileEntry {create and configure} {
	classyclean
	Classy::FileEntry .try
	pack .try
	.try configure -label test
	.try cget -label
} {test}

testsummarize

