#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::Notebook {create and configure} {
	classyclean
	Classy::NoteBook .try
	pack .try -fill both -expand yes
	text .text
	.try manage Text .text -command {set ::try ok}
	button .b -text "Try"
	.try manage Button .b -sticky {}
	button .b2 -text "Try 2"
	.try manage {Button 2} .b2 -sticky {}
	.try select Text
	set ::try
} {ok}

test Classy::Notebook {delete tab} {
	classyclean
	Classy::NoteBook .try
	pack .try -fill both -expand yes
	text .text
	.try manage Text .text -command {set ::try ok}
	button .b -text "Try"
	.try manage Button .b -sticky {}
	button .b2 -text "Try 2"
	.try manage {Button 2} .b2 -sticky {}
	.try trace puts
	.try select Button
	.try delete Button
	.try labels
} {Text {Button 2}}

testsummarize

