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
} {^(-?)[0-9]*$}

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

testsummarize

