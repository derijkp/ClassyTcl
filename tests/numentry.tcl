#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test NumEntry {create and configure} {
	classyclean
	destroy .try
	Classy::NumEntry .try
	pack .try
	.try configure -label test
	.try cget -label
} {test}

test NumEntry {create with configuration configure} {
	classyclean
	NumEntry .try -label try
	pack .try
	.try cget -label
} {try}

test NumEntry {create, destroy, create} {
	classyclean
	NumEntry .try -label try
	pack .try
	destroy .try
	NumEntry .try
	pack .try
	.try cget -label
} {}

test NumEntry {create with configuration configure} {
	classyclean
	NumEntry .try -label try -orient vertical
	pack .try
	.try cget -orient
} {vertical}

test NumEntry {create with configuration configure} {
	classyclean
	NumEntry .try -label int -constraint int
	pack .try
	.try cget -constraint
} {^(-?)[0-9]*$}

test NumEntry {min} {
	classyclean
	NumEntry .try -label try -min 0 -max 10
	pack .try
	.try set 5
	.try set -1
	.try get
} {5}

test NumEntry {max} {
	classyclean
	NumEntry .try -label try -min 0 -max 10
	pack .try
	.try set 5
	.try set 20
	.try get
} {5}

test NumEntry {int} {
	classyclean
	NumEntry .try -label try -min 0 -max 10 -constraint int
	pack .try
	.try set 5
	.try set 5.5
	.try get
} {5}

test NumEntry {int} {
	classyclean
	NumEntry .try -label try -min 0 -max 10 -constraint int -command {set ::try 10}
	pack .try
	update
	set ::try 1
	.try set 1
	update
	set ::try
} {10}

testsummarize
