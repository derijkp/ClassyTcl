#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::HTML {create and configure} {
	clean
	destroy .try
	classyinit test
	Classy::HTML .try -yscrollcommand {.vbar set}
	scrollbar .vbar -command {.try yview}
	pack .try -side left -fill both -expand yes
	pack .vbar -side left -fill y
	.try geturl file:[file join $::class::dir html_library-0.3 html help.html]
	.try geturl http://localhost/
	.try cget -wrap
} {char}

testsummarize
catch {unset errors}

