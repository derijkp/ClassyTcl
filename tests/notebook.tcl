#!/bin/sh
# the next line restarts using wish \
exec wish8.3 "$0" "$@"

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
	.try select Button
	.try delete Button
	.try labels
} {Text {Button 2}}

test Classy::Notebook {rename tab} {
	classyclean
	Classy::NoteBook .try
	pack .try -fill both -expand yes
	text .text
	.try manage Text .text -command {set ::try ok}
	button .b -text "Try"
	.try manage Button .b -sticky {}
	button .b2 -text "Try 2"
	.try manage {Button 2} .b2 -sticky {}
	.try select Button
	.try rename Button {Button 1}
	.try labels
} {Text {Button 1} {Button 2}}

test Classy::Notebook {reorder} {
	classyclean
	Classy::NoteBook .try
	pack .try -fill both -expand yes
	text .text
	.try manage Text .text -command {set ::try ok}
	button .b -text "Try"
	.try manage Button .b -sticky {}
	button .b2 -text "Try 2"
	.try manage {Button 2} .b2 -sticky {}
	.try select Button
	.try reorder {Button 2} Button
	.try labels
} {{Button 2} Button Text}

test Classy::Notebook {in toplevel} {
	classyclean
	catch {Classy::Default unset geometry .try.book}
	Classy::Toplevel .try
	Classy::NoteBook .try.book
	pack .try.book -fill both -expand yes
	text .try.text
	.try.book manage Text .try.text -command {set ::try ok}
	button .try.b -text "Try"
	.try.book manage Button .try.b -sticky {}
	button .try.b2 -text "Try 2"
	.try.book manage {Button 2} .try.b2 -sticky {}
	.try.book select Text
	set ::try
} {ok}

testsummarize


