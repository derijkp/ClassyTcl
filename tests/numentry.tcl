#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::NumEntry {create and configure} {
	classyclean
	destroy .try
	Classy::NumEntry .try
	pack .try
	.try configure -label test
	.try cget -label
} {test}

test Classy::NumEntry {create with configuration configure} {
	classyclean
	Classy::NumEntry .try -label try
	pack .try
	.try cget -label
} {try}

test Classy::NumEntry {create, destroy, create} {
	classyclean
	Classy::NumEntry .try -label try
	pack .try
	destroy .try
	Classy::NumEntry .try
	pack .try
	.try cget -label
} {}

test Classy::NumEntry {create with configuration configure} {
	classyclean
	Classy::NumEntry .try -label try -orient vertical
	pack .try
	.try cget -orient
} {vertical}

test Classy::NumEntry {create with configuration configure} {
	classyclean
	Classy::NumEntry .try -label int -constraint int -warn 0
	pack .try
	.try cget -constraint
} {int}

test Classy::NumEntry {-warn 1} {
	classyclean
	Classy::NumEntry .try -label int -constraint int -warn 1
	pack .try
	.try set a
	.try get
} {a}

test Classy::NumEntry {-warn 0} {
	classyclean
	Classy::NumEntry .try -label int -constraint int -warn 0
	pack .try
	.try set 1
	.try set a
	.try get
} {1}

test Classy::NumEntry {min} {
	classyclean
	Classy::NumEntry .try -label try -min 0 -max 10 -warn 0
	pack .try
	.try set 5
	.try set -1
	.try get
} {5}

test Classy::NumEntry {max} {
	classyclean
	Classy::NumEntry .try -label try -min 0 -max 10 -warn 0
	pack .try
	.try set 5
	.try set 20
	.try get
} {5}

test Classy::NumEntry {int} {
	classyclean
	Classy::NumEntry .try -label try -min 0 -max 10 -constraint int -warn 0
	pack .try
	.try set 5
	.try set 5.5
	.try get
} {5}

test Classy::NumEntry {int} {
	classyclean
	Classy::NumEntry .try -label try -min 0 -max 10 -constraint int \
		-command {set ::try} -warn 0
	pack .try
	update
	set ::try 1
	.try set 10
	update
	set ::try
} {10}

test Classy::NumEntry {with combo} {
	classyclean
	destroy .try
	Classy::NumEntry .try
	pack .try
	.try configure -label test -combo 10
	.try cget -label
} {test}

testsummarize

