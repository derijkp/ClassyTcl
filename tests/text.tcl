#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"

source tools.tcl

test Classy::Text {create and configure} {
	classyclean
	Classy::Text .try
	pack .try -fill both -expand yes
	.try cget -wrap
} {char}

test Classy::Text {insert} {
	classyclean
	destroy .try
	Classy::Text .try
	pack .try
	.try insert end "try"
	.try get 1.0 end
} {try
}

test Classy::Text {link} {
	classyclean
	destroy .t1 .t2
	Classy::Text .t1 -width 10 -height 5
	Classy::Text .t2 -width 10 -height 5
	pack .t1 .t2 -side left -fill both -expand yes
	.t1 insert end "try"
	.t2 link .t1
	.t1 insert end it
	.t2 get 1.0 end
} {tryit
}

test Classy::Text {undo} {
	classyclean
	Classy::Text .try
	pack .try
	.try insert end "try"
	.try insert 1.2 "try"
	.try undo
	.try get 1.0 end
} {try
}

test Classy::ScrolledText {undo} {
	classyclean
	Classy::ScrolledText .try
	pack .try -fill both -expand yes
	.try insert end "try"
	.try insert 1.2 "try"
	.try undo
	.try get 1.0 end
} {try
}

test Classy::ScrolledText {undo} {
	classyclean
	Classy::ScrolledText .try
	pack .try -fill both -expand yes
	for {set i 1} {$i<50} {incr i} {
		for {set j 0} {$j<$i} {incr j} {
			.try insert end "a"
		}
		.try insert end "\n"
	}
	wm geometry . 248x128
	set try 1
} {1}

testsummarize
