#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::HTML {create and configure} {
	clean
	destroy .try
	tk appname test
	package require ClassyTcl
	Classy::HTML .try -yscrollcommand {.vbar set}
	scrollbar .vbar -command {.try yview}
	pack .try -side left -fill both -expand yes
	pack .vbar -side left -fill y
	.try geturl http://rrna.uia.ac.be/lsu/query/index.html
	.try geturl file:[file join $::class::dir html_library-0.3 html help.html]
	.try geturl http://rrna.uia.ac.be/
	.try cget -wrap
} {char}

.try bindlink <3> {puts [.try linkat %x %y]}

test Classy::help {create and configure} {
	clean
	catch {destroy .try}
	tk appname test
	package require ClassyTcl
	Classy::Help .try
	.try gethelp ClassyTcl
	.try cget -wrap
} {word}

testsummarize
catch {unset errors}

