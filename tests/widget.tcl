#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl
option add *Try 1

test Widget {configure no args} {
	classyclean
	destroy .try
	Widget addoption -try {try Try 1}
	Widget .try
	lindex [.try configure] 0
} {-try try Try 1 1}

test Widget {configure 1 arg} {
	classyclean
	destroy .try
	Widget addoption -try {try Try 1}
	Widget .try
	.try configure -try
} {-try try Try 1 1}

test Widget {configure 2 args} {
	classyclean
	destroy .try
	Widget addoption -try {try Try 1}
	Widget .try
	.try configure -try 2
	.try cget -try
} {2}

test Widget {configure get from option database} {
	classyclean
	destroy .try
	option add *Try 2
	Widget addoption -try {try Try 1}
	Widget .try
	.try cget -try
} {2}

test Widget {configure get from option database} {
	classyclean
	destroy .try
	option add *Try 2
	Widget addoption -try {try Try 1}
	Widget chainoptions {$object}
	Widget .try
	lindex [.try configure] 0
} {-try try Try 1 2}

test Widget {configure no args} {
	classyclean
	destroy .try
	Widget component entry {$object.entry}
	Widget .try
	.try component entry
} {.try.entry}

test Widget {init entry} {
	classyclean
	destroy .try
	Widget subclass Test
	Test method init {} {
		super init entry
	}
	Test .try
} {::class::Tk_.try}

test Widget {init entry with args} {
	classyclean
	destroy .try
	Widget subclass Test
	Test method init {} {
		super init entry $object -textvariable try
	}
	[Test .try] cget -textvariable
} {try}

test Widget {pass args in init} {
	classyclean
	destroy .try
	Widget subclass Test
	Test method init {args} {
		super init
		set ::c $args
	}
	set ::c {}
	Test .try test
	set ::c
} {test}

testsummarize

