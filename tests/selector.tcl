#!/bin/sh
# the next line restarts using wish \
exec wish8.3 "$0" "$@"

source tools.tcl
set object .try
	classyclean
	Classy::Selector .try -type text -label try -variable ::try -command puts
	pack .try -fill both -expand yes
	.try configure -state disabled
	.try configure -state normal
	.try set try
	set ::try

test Classy::Selector {text} {
	classyclean
	Classy::Selector .try -type text -label try -variable ::try -command puts
	pack .try -fill both -expand yes
	.try configure -state disabled
	.try configure -state normal
	.try set try
	set ::try
} {try}

test Classy::Selector {color} {
	classyclean
	Classy::Selector .try -type color -label try -variable ::try
	pack .try -fill both -expand yes
	.try configure -state disabled
	.try configure -state normal
	.try set green
	set ::try
} {green}

test Classy::Selector {font} {
	classyclean
	Classy::Selector .try -type font -label try -variable ::try
	pack .try -fill both -expand yes
	.try configure -state disabled
	.try configure -state normal
	.try set {helvetica 10}
	set ::try
} {helvetica 10}

test Classy::Selector {anchor} {
	classyclean
	Classy::Selector .try -type anchor -label Try -variable try
	pack .try -fill both -expand yes
	.try configure -state disabled
	.try configure -state normal
	.try set n
	.try get
} {n}

test Classy::Selector {justify} {
	classyclean
	Classy::Selector .try -type justify -label Try -variable try
	pack .try -fill both -expand yes
	.try configure -state disabled
	.try configure -state normal
	.try set left
	.try get
} {left}

test Classy::Selector {bool} {
	classyclean
	Classy::Selector .try -type bool -label Try -variable try
	pack .try -fill both -expand yes
	.try configure -state disabled
	.try configure -state normal
	.try set 1
	.try get
} {1}

test Classy::Selector {orient} {
	classyclean
	Classy::Selector .try -type orient -label Try -variable try
	pack .try -fill both -expand yes
	.try configure -state disabled
	.try configure -state normal
	.try set horizontal
	.try get
} {horizontal}

test Classy::Selector {relief} {
	classyclean
	Classy::Selector .try -type relief -label Try -variable try
	pack .try -fill both -expand yes
	.try configure -state disabled
	.try configure -state normal
	.try set groove
	.try get
} {groove}

test Classy::Selector {select} {
	classyclean
	Classy::Selector .try -type {select try it out} -label Try -variable try
	pack .try -fill both -expand yes
	.try set it
	.try get
} {it}

test Classy::Selector {text variable} {
	classyclean
	Classy::Selector .try -type text -label "try it" -variable ::try
	pack .try -fill both -expand yes
	.try configure -state disabled
	.try configure -state normal
	.try set try
	set ::try
} {try}

test Classy::Selector {sticky} {
	classyclean
	Classy::Selector .try -type sticky -label Try -variable try -command puts
	pack .try -fill both -expand yes
	.try configure -state disabled
	.try configure -state normal
	.try set n
	.try get
} {n}

test Classy::Selector {menu} {
	classyclean
	catch {Classy::Default unset geometry .try.menueditor}
	Classy::Selector .try -type menu -label try -variable ::try
	pack .try -fill both -expand yes
	.try configure -state disabled
	.try configure -state normal
	.try set {menu File {}}
	set ::try
} {menu File {}}

test Classy::Selector {toolbar} {
	classyclean
	catch {Classy::Default unset geometry .try.toolbareditor}
	Classy::Selector .try -type toolbar -label try -variable ::try
	pack .try -fill both -expand yes
	.try configure -state disabled
	.try configure -state normal
	.try set {action Action {}}
	set ::try
} {action Action {}}

test Classy::Selector {key} {
	classyclean
	Classy::Selector .try -type key -label try -variable ::try -command puts
	pack .try -fill both -expand yes
	.try configure -state disabled
	.try configure -state normal -orient vertical
	.try set <a>
	set ::try
} <a>

test Classy::Selector {two} {
	classyclean
	Classy::Selector .try -type key -label try -variable ::try
	Classy::Selector .try2 -type text -label try -variable ::try2 -command puts
	.try set <a>
	.try2 set try
	.try configure -label test
	pack .try -fill x
	pack .try2 -fill both -expand yes
	set ::try
} <a>

testsummarize

