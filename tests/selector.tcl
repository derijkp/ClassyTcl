#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::Selector {text} {
	classyclean
	Classy::Selector .try -type text -label try -variable ::try
	pack .try -fill both -expand yes
	.try set try
	set ::try
} {try}

test Classy::Selector {color} {
	classyclean
	Classy::Selector .try -type color -label try -variable ::try
	pack .try -fill both -expand yes
	.try set green
	set ::try
} {green}

test Classy::Selector {font} {
	classyclean
	Classy::Selector .try -type font -label try -variable ::try
	pack .try -fill both -expand yes
	.try set {helvetica 10}
	set ::try
} {helvetica 10}

test Classy::Selector {anchor} {
	classyclean
	Classy::Selector .try -type anchor -label Try -variable try
	pack .try -fill both -expand yes
	.try set n
	.try get
} {n}

test Classy::Selector {justify} {
	classyclean
	Classy::Selector .try -type justify -label Try -variable try
	pack .try -fill both -expand yes
	.try set left
	.try get
} {left}

test Classy::Selector {bool} {
	classyclean
	Classy::Selector .try -type bool -label Try -variable try
	pack .try -fill both -expand yes
	.try set 1
	.try get
} {1}

test Classy::Selector {orient} {
	classyclean
	Classy::Selector .try -type orient -label Try -variable try
	pack .try -fill both -expand yes
	.try set horizontal
	.try get
} {horizontal}

test Classy::Selector {relief} {
	classyclean
	Classy::Selector .try -type relief -label Try -variable try
	pack .try -fill both -expand yes
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
	.try set try
	set ::try
} {try}

test Classy::Selector {sticky} {
	classyclean
	Classy::Selector .try -type sticky -label Try -variable try -command puts
	pack .try -fill both -expand yes
	.try set n
	.try get
} {n}

testsummarize

