#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"

source tools.tcl

test Classy::CmdWidget {create and configure} {
	classyclean
	Classy::CmdWidget .try
	pack .try
	.try cget -prompt
} {[pwd] % }

if 0 {
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
}

testsummarize

