#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::Default {set and get} {
	classyclean
	Classy::Default set app try 2
	Classy::Default set app try 1
	Classy::Default get app try
} {1}

test Classy::Default {add} {
	classyclean
	Classy::Default clear
	Classy::Default add app try 1
	Classy::Default add app try {try it}
	Classy::Default get app try
} {{try it} 1}

test Classy::Default {remove} {
	classyclean
	Classy::Default clear
	Classy::Default set app try {{try it} 1}
	Classy::Default remove app try {try it}
	Classy::Default get app try
} {1}

test Classy::DefaultMenu {create and configure} {
	classyclean
	entry .e
	Classy::DefaultMenu .try -key try -command {.e delete 0 end;.e insert 0} -getcommand {.e get}
	pack .e .try -side left
	.e delete 0 end;.e insert 0 try
	Classy::Default set app try {ertu fghfh dfhjdf dffj}
	bind .e <F3> {.try menu}
	manualtest
} {}

testsummarize
