#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl
set object .try

classyclean
Classy::Canvas .try
pack .try
set items ""
time {
for {set i 0} {$i<1000} {incr i} {
	lappend items [.try create text $i 10 -text "A" -tags [list " test" try other a lot of]]
}
}
time {.try itemconfigure 50 -tags test}
time {.try itemconfigure 9000 -tags test}
time {.try create text $i 10 -text "A" -tags try}

time {.try itemconfigure $items -font {helvetica 20 bold}}
time {.try itemconfigure all -font {helvetica 20 bold}}
time {.try itemconfigure try -font {helvetica 10}}
time {.try itemconfigure test -fill green}
time {.try itemconfigure test -font {helvetica 20 bold}}

test Classy::Canvas {create and configure} {
	classyclean
	Classy::Canvas .try
	pack .try
	.try create text 10 10 -text "A"
	.try create text 50 50 -text "B" -font {times 14 bold}
	.try create line 20 10 60 50 -width 4
	.try zoom 2
	.try zoom 1
} {-text {} {} {} A}

test Classy::Canvas {create and configure} {
	classyclean
	Classy::Canvas .try
	pack .try
	set id [.try create text 10 10 -text "A"]
	.try itemconfigure $id -text
} {-text {} {} {} A}

test Classy::Canvas {undo} {
	classyclean
	Classy::Canvas .try
	pack .try
	.try create text 10 10 -text "A"
	.try undo check
	.try create text 20 20 -text "B"
	.try undo
	.try find withtag all
} {1}

test Classy::Canvas {undo and redo} {
	classyclean
	Classy::Canvas .try
	pack .try
	set id [.try create text 10 10 -text "A"]
	.try undo check
	.try create text 20 20 -text "B"
	.try undo check
	.try itemconfigure $id -fill blue -font {helvetica 20 bold}
	.try undo
	.try itemcget $id -fill
} {black}

test Classy::Canvas {undo itemconfigure} {
	classyclean
	Classy::Canvas .try
	pack .try
	set id [.try create text 10 10 -text "A" -tags try]
	.try undo check
	.try create text 20 20 -text "B" -tags try
	.try undo check
	.try itemconfigure $id -fill blue -font {helvetica 20 bold}
	.try undo
	.try itemcget $id -fill
} {black}

test Classy::Canvas {undo itemconfigure by tag} {
	classyclean
	Classy::Canvas .try
	pack .try
	.try create text 10 10 -text "A" -tags try
	.try undo check
	.try create text 20 20 -text "B" -tags try
	.try undo check
	.try create text 30 30 -text "C" -tags test
	.try undo check
	.try itemconfigure try -fill blue -font {helvetica 20 bold}
	.try undo
	.try itemcget try -fill
} {black}

test Classy::Canvas {undo coords} {
	classyclean
	Classy::Canvas .try
	pack .try
	set id [.try create text 10 10 -text "A"]
	.try create text 20 20 -text "B"
	.try undo check
	.try coords $id 30 30
	.try undo check
	.try undo
	.try coords $id
} {10.0 10.0}

test Classy::Canvas {undo move} {
	classyclean
	Classy::Canvas .try
	pack .try
	.try create text 10 10 -text "A" -tags try
	.try create text 20 20 -text "B" -tags try
	.try create text 30 30 -text "C" -tags test
	.try undo check
	.try move try 10 0
	.try move try 10 0
	.try undo
	.try coords 1
} {10.0 10.0}

test Classy::Canvas {undo scale} {
	classyclean
	Classy::Canvas .try
	pack .try
	.try create text 10 10 -text "A" -tags try
	.try create text 20 20 -text "B" -tags try
	.try create text 30 30 -text "C" -tags test
	.try undo check
	.try create line 20 10 60 50 -width 4 -tags try
	.try undo check
	.try scale try 0 0 2 2
	.try undo
	.try coords 1
} {10.0 10.0}

test Classy::Canvas {undo rotate} {
	classyclean
	Classy::Canvas .try
	pack .try
	.try create text 10 10 -text "A" -tags try
	.try itemconfigure 1 -fill blue -font {helvetica 20 bold}
	.try create text 20 20 -text "B" -tags try
	.try create text 30 30 -text "C" -tags test
	.try undo check
	.try create line 20 10 60 50 -width 4 -tags try
	.try undo check
	.try lower 4 1
	.try undo check
	.try lower 2 1
	.try undo check
	.try delete try
	.try undo
	.try find withtag all
} {4 2 1 3}

testsummarize
