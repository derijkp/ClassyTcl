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

test Classy::Entry {command not at creation} {
	classyclean
	set ::c 0
	Classy::Entry .try -labelwidth 5 -label try \
		-command {set ::c try}
	pack .try
	set ::c
} 0

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

test Classy::Entry {combo} {
	classyclean
	set ::try t
	Classy::Entry .try -textvariable try -combo 10
	pack .try
	.try set test
	.try set test2
	.try.defaults invoke
	.try.defaults.combo.list get 0
} {test2}

test Classy::Entry {combo with command} {
	classyclean
	proc t object {return [list $object try it now]}
	set ::try t
	Classy::Entry .try -textvariable try -combo {t .try}
	pack .try
	.try.defaults invoke
	.try.defaults.combo.list get 0
} {.try}

test Classy::Entry {combo with preset} {
	classyclean
	set ::try t
	Classy::Entry .try -textvariable try -combo 10 -combopreset {echo {pre1 pre2}}
	pack .try -fill x
	.try set test
	.try set test2
	.try.defaults invoke
	.try.defaults.combo.list get end
} {pre2}

test Classy::FileEntry {create and configure} {
	classyclean
	Classy::FileEntry .try
	pack .try
	.try configure -label test
	.try cget -label
} {test}

test Classy::FileEntry {with combo} {
	classyclean
	Classy::FileEntry .try
	pack .try
	.try configure -label test -combo 10
	.try cget -label
} {test}

test Classy::Entry {-state} {
	classyclean
	Classy::Entry .try
	pack .try
	.try configure -label test -state disabled
	.try cget -label
} {test}

testsummarize

