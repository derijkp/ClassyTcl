#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl
set object try

test Classy::CanvasObject {create and configure} {
	classyclean
	catch {CanvasObject destroy}
	catch {try destroy}
	canvas .try
	pack .try -fill both -expand yes
	update idletasks
	Classy::CanvasObject new try -canvas .try -area {10 10 100 100}
	try configure -boxwidth 0
	try configure -boxcolor green -boxwidth 4
	try configure -area {5 5 200 200}
	update idletasks
	set id [.try find all]
	.try itemcget $id -tags
} {__co::try}

test Classy::CanvasSeq {create and configure} {
	classyclean
	catch {CanvasSeq destroy}
	catch {try destroy}
	canvas .try
	pack .try -fill both -expand yes
	update idletasks
	Classy::CanvasSeq new try -canvas .try -area {10 10 210 250}
	try configure -end 150
	update idletasks
	set id [.try find all]
	.try itemcget $id -tags
} {__co::try}


	classyclean
	catch {CanvasSeq destroy}
	catch {try destroy}
	canvas .try
	pack .try -fill both -expand yes
	update idletasks
	Classy::CanvasSeq new try -boxwidth 0 -canvas .try -area {10 10 210 250}
	try configure -end 160

