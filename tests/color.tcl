#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test ColorEntry {create and configure} {
	clean
	eval destroy [winfo children .]
	classyinit test
	Classy::ColorEntry .try
	pack .try
	.try set green
	.try get
} {green}

test ColorHSV {create and configure} {
	clean
	eval destroy [winfo children .]
	classyinit test
	Classy::ColorHSV .try
	pack .try
	.try set green
	.try get
} {#00ff00}

test ColorHSV {command} {
	clean
	eval destroy [winfo children .]
	classyinit test
	set ::try 0
	Classy::ColorHSV .try -command {set ::try 1}
	pack .try
	.try set green
	update
	set ::try
} {1}

test ColorRGB {create and configure} {
	clean
	eval destroy [winfo children .]
	classyinit test
	Classy::ColorRGB .try
	pack .try
	.try set green
	.try get
} {#00ff00}

test ColorRGB {command} {
	clean
	eval destroy [winfo children .]
	classyinit test
	set ::try 0
	Classy::ColorRGB .try -command {set ::try 1}
	pack .try
	.try set green
	update
	set ::try
} {1}

test ColorSample {create and configure} {
	clean
	eval destroy [winfo children .]
	classyinit test
	Classy::ColorSample .try
	pack .try
	.try set green
	.try get
} {green}

test ColorSelect {create and configure} {
	clean
	eval destroy [winfo children .]
	classyinit test
	Classy::ColorSelect .try
	pack .try -fill both -expand yes
	.try set green
	.try get
} {#00ff00}

test getcolor {getcolor} {
	clean
	eval destroy [winfo children .]
	classyinit test
	option add *GetColor Peos startupFile
	Classy::getcolor -initialcolor yellow
} {#ffff00}

testsummarize
catch {unset errors}

