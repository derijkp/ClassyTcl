#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::Canvas {create and configure} {
	clean
	eval destroy [winfo children .]
	tk appname test
	package require ClassyTcl
	Classy::Canvas .try
	pack .try
	set id [.try create text 10 10 -text "A"]
	.try itemconfigure $id -text
} {-text {} {} {} A}

test Classy::Canvas {undo} {
	clean
	eval destroy [winfo children .]
	tk appname test
	package require ClassyTcl
	Classy::Canvas .try
	pack .try
	.try create text 10 10 -text "A"
	.try undo check
	.try create text 20 20 -text "B"
	.try undo
	.try find withtag all
} {1}

testsummarize
catch {unset errors}

