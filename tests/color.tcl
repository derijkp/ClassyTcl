#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test ColorEntry {create and configure} {
	classyclean
	Classy::ColorEntry .try
	pack .try
	.try set green
	.try get
} {green}

test ColorHSV {create and configure} {
	classyclean
	Classy::ColorHSV .try
	pack .try
	.try set green
	.try get
} {#00ff00}

test ColorHSV {command} {
	classyclean
	set ::try 0
	Classy::ColorHSV .try -command {set ::try 1}
	pack .try
	.try set green
	update
	set ::try
} {1}

test ColorRGB {create and configure} {
	classyclean
	Classy::ColorRGB .try
	pack .try
	.try set green
	.try get
} {#00ff00}

test ColorRGB {command} {
	classyclean
	set ::try 0
	Classy::ColorRGB .try -command {set ::try 1}
	pack .try
	.try set green
	update
	set ::try
} {1}

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
} {#00ff00}

test getcolor {getcolor} {
	classyclean
	option add *GetColor Peos startupFile
	Classy::getcolor -initialcolor yellow
} {#ffff00}

testsummarize
