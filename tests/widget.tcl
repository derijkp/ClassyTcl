#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl
option add *Try 1

test Widget {configure no args} {
	clean
	destroy .try
	Widget addoption -try {try Try 1}
	Widget .try
	lindex [.try configure] 0
} {-try try Try 1 1}

test Widget {configure 1 arg} {
	clean
	destroy .try
	Widget addoption -try {try Try 1}
	Widget .try
	.try configure -try
} {-try try Try 1 1}

test Widget {configure 2 args} {
	clean
	destroy .try
	Widget addoption -try {try Try 1}
	Widget .try
	.try configure -try 2
	.try cget -try
} {2}

test Widget {configure get from option database} {
	clean
	destroy .try
	option add *Try 2
	Widget addoption -try {try Try 1}
	Widget .try
	.try cget -try
} {2}

test Widget {configure get from option database} {
	clean
	destroy .try
	option add *Try 2
	Widget addoption -try {try Try 1}
	Widget chainoptions {$object}
	Widget .try
	lindex [.try configure] 0
} {-try try Try 1 2}

test Widget {configure no args} {
	clean
	destroy .try
	Widget component entry {$object.entry}
	Widget .try
	.try component entry
} {.try.entry}

test Widget {init entry} {
	clean
	destroy .try
	Widget subclass Test
	Test classmethod init {} {
		super entry
	}
	[Test .try] cget -validate
} {none}

test Widget {init entry with args} {
	clean
	destroy .try
	Widget subclass Test
	Test classmethod init {} {
		super entry $object -textvariable try
	}
	[Test .try] cget -textvariable
} {try}

test Widget {pass args in init} {
	clean
	destroy .try
	Widget subclass Test
	Test classmethod init {args} {
		super
		set ::c $args
	}
	set ::c {}
	Test .try test
	set ::c
} {test}

testsummarize
catch {unset errors}
