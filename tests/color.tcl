#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test ColorEntry {create and configure} {
	classyclean
	Classy::ColorEntry .try
	pack .try -fill x
	.try set green
	.try get
} {green}

test ColorEntry {command} {
	classyclean
	Classy::ColorEntry .try -command {set try}
	pack .try -fill x
	set ::try ""
	.try set green
	set ::try
} {green}

test ColorHSV {create and configure} {
	classyclean
	Classy::ColorHSV .try -command puts
	pack .try
	.try set green
	.try get
} {#00ff00}

test ColorHSV {command} {
	classyclean
	set ::try 0
	Classy::ColorHSV .try -command {set ::try}
	pack .try
	.try set green
	update
	set ::try
} {#00ff00}

test ColorRGB {create and configure} {
	classyclean
	Classy::ColorRGB .try -command {puts}
	pack .try
	.try set green
	.try get
} {#00ff00}

test ColorRGB {command} {
	classyclean
	set ::try 0
	Classy::ColorRGB .try -command {set ::try}
	pack .try
	.try set green
	update
	set ::try
} {#00ff00}

test ColorSample {create and configure} {
	classyclean
	Classy::ColorSample .try
	pack .try
	.try set green
	.try get
} {green}

test ColorSelect {create and configure} {
	classyclean
	Classy::ColorSelect .try
	pack .try -fill both -expand yes
	.try set green
	.try get
} {green}

test getcolor {getcolor} {
	classyclean
	option add *GetColor Classy startupFile
	Classy::getcolor -initialcolor yellow
} {yellow}

testsummarize
