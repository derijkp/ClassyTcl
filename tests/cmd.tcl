#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::CmdWidget {create and configure} {
	classyclean
	Classy::CmdWidget .try
	pack .try
	.try cget -prompt
} {[pwd] % }

test Classy::CmdWidget {create and configure} {
	classyclean
	Classy::CmdWidget .try
	pack .try
	Classy::CmdWidget .try2
	pack .try2
	.try connect try
	.try2 connect try
	.try cget -prompt
} {[pwd] % }

testsummarize
