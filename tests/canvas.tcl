#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl
set object .trys

if 0 {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
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
	.try selection add withtag try
}

test Classy::Canvas {create and configure} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A"]
	.try create text 50 50 -text "B" -font {times 14 bold}
	.try create line 20 10 60 50 -width 4
	.try itemconfigure $id -text
} {-text {} {} {} A}

test Classy::Canvas {zoom} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A"]
	.try create text 50 50 -text "B" -font {times 14 bold}
	.try create line 20 10 60 50 -width 4
	.try zoom 2
	.try coords $id
} {20.0 20.0}

test Classy::Canvas {coord} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create line 20 10 60 50 100 100 -width 4]
	.try coord $id 1 90 50
	.try coord $id 1
} {90.0 50.0}

test Classy::Canvas {coord undo} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create line 20 10 60 50 100 100 -width 4]
	.try coord $id 1 90 50
	.try undo
	.try coord $id 1
} {60.0 50.0}

test Classy::Canvas {coord undo and redo} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create line 20 10 60 50 100 100 -width 4]
	.try coord $id 1 90 50
	.try undo
	.try redo
	.try coord $id 1
} {90.0 50.0}

test Classy::Canvas {create and configure} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A"]
	.try itemconfigure $id -text
} {-text {} {} {} A}

test Classy::Canvas {undo create} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A"]
	.try create text 20 20 -text "B"
	.try undo
	if {[.try find withtag all] != $id} error
	set try 1
} {1}

test Classy::Canvas {undo create with check} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A"]
	.try undo check start
	.try create text 20 20 -text "B"
	.try create text 30 30 -text "C"
	.try undo check stop
	.try undo
	if {[.try find withtag all] != $id} error
	set try 1
} {1}

test Classy::Canvas {undo and redo create with check} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A"]
	.try undo check start
	.try create text 20 20 -text "B"
	.try create text 30 30 -text "C"
	.try undo check stop
	.try undo
	.try redo
	.try mitemcget all -text
} {A B C}

test Classy::Canvas {undo and redo create} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A"]
	.try create text 20 20 -text "B"
	.try undo
	.try redo
	llength [.try find withtag all]
} {2}

test Classy::Canvas {undo itemconfigure} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A" -tags try]
	.try create text 20 20 -text "B" -tags try
	.try itemconfigure $id -fill blue -font {helvetica 20 bold}
	.try undo
	.try itemcget $id -fill
} {black}

test Classy::Canvas {redo itemconfigure} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A" -tags try]
	.try create text 20 20 -text "B" -tags try
	.try itemconfigure $id -fill blue -font {helvetica 20 bold}
	.try undo
	.try redo
	.try itemcget $id -fill
} {blue}

test Classy::Canvas {undo itemconfigure by tag} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create text 10 10 -text "A" -tags try
	.try create text 20 20 -text "B" -tags try
	.try create text 30 30 -text "C" -tags test
	.try itemconfigure try -fill blue -font {helvetica 20 bold}
	.try undo
	.try itemcget try -fill
} {black}

test Classy::Canvas {undo coords} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A"]
	.try create text 20 20 -text "B"
	.try coords $id 30 30
	.try undo
	.try coords $id
} {10.0 10.0}

test Classy::Canvas {redo coords} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A"]
	.try create text 20 20 -text "B"
	.try coords $id 30 30
	.try undo
	.try redo
	.try coords $id
} {30.0 30.0}

test Classy::Canvas {undo move} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A" -tags try]
	.try create text 20 20 -text "B" -tags try
	.try create text 30 30 -text "C" -tags test
	.try move try 10 0
	.try move try 10 0
	.try undo
	.try coords $id
} {10.0 10.0}

test Classy::Canvas {undo 2 moves} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A" -tags try]
	.try create text 20 20 -text "B" -tags try
	.try create text 30 30 -text "C" -tags test
	.try move try 10 0
	.try move test 10 0
	.try undo
	.try undo
	.try coords $id
} {10.0 10.0}

test Classy::Canvas {redo move} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A" -tags try]
	.try create text 20 20 -text "B" -tags try
	.try create text 30 30 -text "C" -tags test
	.try move try 10 0
	.try move try 10 0
	.try undo
	.try redo
	.try coords $id
} {30.0 10.0}

test Classy::Canvas {undo scale} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A" -tags try]
	.try create text 20 20 -text "B" -tags try
	.try create text 30 30 -text "C" -tags test
	.try create line 20 10 60 50 -width 4 -tags try
	.try scale try 0 0 2 2
	.try undo
	.try coords $id
} {10.0 10.0}

test Classy::Canvas {redo scale} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A" -tags try]
	.try create text 20 20 -text "B" -tags try
	.try create text 30 30 -text "C" -tags test
	.try create line 20 10 60 50 -width 4 -tags try
	.try scale try 0 0 2 2
	.try undo
	.try redo
	.try coords $id
} {20.0 20.0}

test Classy::Canvas {undo rotate} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A" -tags try]
	.try itemconfigure $id -fill blue -font {helvetica 20 bold}
	.try create text 20 20 -text "B" -tags try
	.try create text 30 30 -text "C" -tags test
	.try create line 20 10 60 50 -width 4 -tags try
	.try rotate try 0 0 -45
	.try undo
	set try [.try coords try]
	list [expr {round([lindex $try 0])}] [expr {round([lindex $try 1])}]
} {10 10}

test Classy::Canvas {redo rotate} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A" -tags try]
	.try itemconfigure $id -fill blue -font {helvetica 20 bold}
	.try create text 20 20 -text "B" -tags try
	.try create text 30 30 -text "C" -tags test
	.try create line 20 10 60 50 -width 4 -tags try
	.try rotate try 0 0 -30
	.try undo
	.try redo
	set try [.try coords try]
	list [expr {round([lindex $try 0])}] [expr {round([lindex $try 1])}]
} {4 14}

test Classy::Canvas {undo lower} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create text 10 10 -text "A" -tags t1
	.try itemconfigure try1 -fill blue -font {helvetica 20 bold}
	.try create text 20 20 -text "B" -tags t2
	.try create text 30 30 -text "C" -tags t3
	.try create line 20 10 60 50 -width 4 -tags t4
	.try lower t4 t1
	.try lower t2 t1
	.try undo
	.try undo
	.try mitemcget all -tags
} {t1 t2 t3 t4}

test Classy::Canvas {redo lower} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create text 10 10 -text "A" -tags t1
	.try itemconfigure try1 -fill blue -font {helvetica 20 bold}
	.try create text 20 20 -text "B" -tags t2
	.try create text 30 30 -text "C" -tags t3
	.try create line 20 10 60 50 -width 4 -tags t4
	.try lower t4 t1
	.try lower t2 t1
	.try undo
	.try redo
	.try mitemcget all -tags
} {t4 t2 t1 t3}

test Classy::Canvas {undo raise} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create text 10 10 -text "A" -tags t1
	.try itemconfigure try1 -fill blue -font {helvetica 20 bold}
	.try create text 20 20 -text "B" -tags t2
	.try create text 30 30 -text "C" -tags t3
	.try create line 20 10 60 50 -width 4 -tags t4
	.try raise t1 t4
	.try raise t1 t2
	.try undo
	.try undo
	.try mitemcget all -tags
} {t1 t2 t3 t4}

test Classy::Canvas {redo raise} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create text 10 10 -text "A" -tags t1
	.try itemconfigure try1 -fill blue -font {helvetica 20 bold}
	.try create text 20 20 -text "B" -tags t2
	.try create text 30 30 -text "C" -tags t3
	.try create line 20 10 60 50 -width 4 -tags t4
	.try raise t1 t4
	.try raise t1 t2
	.try undo
	.try redo
	.try mitemcget all -tags
} {t2 t1 t3 t4}

test Classy::Canvas {undo delete} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create text 10 10 -text "A" -tags {t1 try}
	.try itemconfigure try1 -fill blue -font {helvetica 20 bold}
	.try create text 20 20 -text "B" -tags {t2 try}
	.try create text 30 30 -text "C" -tags {t3 test}
	.try create line 20 10 60 50 -width 4 -tags {t4 try}
	.try lower t4 t1
	.try lower t2 t1
	.try delete try
	.try undo
	.try mitemcget all -tags
} {{t4 try} {t2 try} {t1 try} {t3 test}}

test Classy::Canvas {redo delete} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create text 10 10 -text "A" -tags {t1 try}
	.try itemconfigure try1 -fill blue -font {helvetica 20 bold}
	.try create text 20 20 -text "B" -tags {t2 try}
	.try create text 30 30 -text "C" -tags {t3 test}
	.try create line 20 10 60 50 -width 4 -tags {t4 try}
	.try lower t4 t1
	.try lower t2 t1
	.try delete try
	.try undo
	.try redo
	.try mitemcget all -tags
} {{t3 test}}

test Classy::Canvas {undo addtag} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create text 10 10 -text "A" -tags try
	.try create text 20 20 -text "B" -tags try
	.try create text 30 30 -text "C" -tags {t3 try find}
	.try create line 20 10 60 50 -width 4 -tags {t4 try find new}
	.try addtag new withtag find
	.try undo
	.try mitemcget new -tags
} {{t4 try find new}}

test Classy::Canvas {redo addtag} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create text 10 10 -text "A" -tags try
	.try create text 20 20 -text "B" -tags try
	.try create text 30 30 -text "C" -tags {t3 try find}
	.try create line 20 10 60 50 -width 4 -tags {t4 try find new}
	.try addtag new withtag find
	.try undo
	.try redo
	.try mitemcget new -tags
} {{t3 try find new} {t4 try find new}}

test Classy::Canvas {undo dtag} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create text 10 10 -text "A" -tags try1
	.try create text 20 20 -text "B" -tags try2
	.try create text 30 30 -text "C" -tags {try3 find}
	.try create line 20 10 60 50 -width 4 -tags {try4 find new}
	.try dtag find new
	.try undo
	.try mitemcget new -tags
} {{try4 find new}}

test Classy::Canvas {redo dtag} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create text 10 10 -text "A" -tags try1
	.try create text 20 20 -text "B" -tags try2
	.try create text 30 30 -text "C" -tags {try3 find}
	.try create line 20 10 60 50 -width 4 -tags {try4 find new}
	.try dtag find new
	.try undo
	.try redo
	.try mitemcget new -tags
} {}

test Classy::Canvas {undo dchars} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create text 50 50 -text "ABCDE" -tags try1
	.try dchars try1 2 3
	.try undo
	.try itemcget try1 -text
} {ABCDE}

test Classy::Canvas {redo dchars} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create text 50 50 -text "ABCDE" -tags try1
	.try dchars try1 2 3
	.try undo
	.try redo
	.try itemcget try1 -text
} {ABE}

test Classy::Canvas {undo insert} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create text 50 50 -text "ACDE" -tags try1
	.try insert try1 1 B
	.try undo
	.try itemcget try1 -text
} {ACDE}

test Classy::Canvas {redo insert} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create text 50 50 -text "ACDE" -tags try1
	.try insert try1 1 B
	.try undo
	.try redo
	.try itemcget try1 -text
} {ABCDE}

test Classy::Canvas {delete lower undo} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create text 10 10 -text "A" -tags t1
	.try itemconfigure t1 -fill blue -font {helvetica 20 bold}
	.try create text 20 20 -text "B" -tags {t2 try}
	.try create text 30 30 -text "C" -tags {t3 test}
	.try delete try
	.try create line 20 10 60 50 -width 4 -tags t4
	.try lower t4 t1
	.try undo
	.try mitemcget all -tags
} {t1 {t3 test} t4}

test Classy::Canvas {selection} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	for {set i 0} {$i<1000} {incr i 10} {
		.try create text $i $i -text $i -tags "t$i"
	}
	.try selection add {t20 t30 t40 t50}
	.try selection clear
	.try selection get
	.try selection redraw
} {}

test Classy::Canvas {selection undo} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	for {set i 0} {$i<1000} {incr i 10} {
		.try create text $i $i -text $i -tags "t$i"
	}
	.try selection add {t20 t30}
	.try selection add {t40 t50}
	.try undo
	.try mitemcget _sel -text
} {20 30}

test Classy::Canvas {save} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create text 10 10 -text "A" -tags t1
	.try itemconfigure t1 -fill green -font {helvetica 20 bold}
	.try create text 20 20 -text "B" -tags t2
	.try create text 30 30 -text "C" -tags {t3 test}
	.try create line 10 10 60 50 -width 4 -tags t4
	.try lower t4 t1
	.try lower t3 t2
	set d [.try save]
	.try delete all
	.try load $d
	.try dtag _new
	.try mitemcget all -tags
} {t4 t1 {t3 test} t2}

test Classy::Canvas {save line} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create line 10 10 20 20 10 20 -fill green -tags try
	set d [.try save]
	.try delete all
	.try load $d
	.try type [.try find all]
} {line}

test Classy::Canvas {save line params} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create line 10 10 50 50 10 50 -fill green -width 4 -stipple gray25 -tags try
	set d [.try save]
	.try delete all
	.try load $d
	.try itemcget [.try find all] -stipple
} {gray25}

test Classy::Canvas {save polygon} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create polygon 10 10 20 20 10 20 -fill green -tags try
	set d [.try save]
	.try delete all
	.try load $d
	.try type [.try find all]
} {polygon}

test Classy::Canvas {save image} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create image 10 10 -image [Classy::geticon save] -tags try
	.try create image 20 20 -image [Classy::geticon print]
	.try create image 30 30 -image [Classy::geticon save]
	set d [.try save]
	.try delete all
	.try load $d
	.try mitemcget all -image
} {.try:::Classy::icon_save1 .try:::Classy::icon_print1 .try:::Classy::icon_save1}

test Classy::Canvas {save bitmap} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	.try create bitmap 10 10 -bitmap info -tags try
	.try create bitmap 20 20 -bitmap @[set ::Classy::dir(def)]/icons/cbxarrow.xbm
	set id [.try create bitmap 30 30 -bitmap info -foreground blue]
	.try create bitmap 40 40 -bitmap @[set ::Classy::dir(def)]/icons/cbxarrow.xbm -foreground green
	set d [.try save]
	.try delete all
	.try load $d
	.try itemcget $id -bitmap
} {info}

test Classy::Canvas {group} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	for {set i 0} {$i<5} {incr i} {
		set pos [expr {10*$i}]
		set id($i) [.try create text $pos $pos -text $pos -tags "t$pos"]
	}
	set g1 [.try group items $id(0) $id(1)]
	set g2 [.try group items $id(2) $id(3)]
	set g3 [.try group tags $g1 $g2]
	.try mitemcget all -tags
} {{t0 _g1 _g3} {t10 _g1 _g3} {t20 _g2 _g3} {t30 _g2 _g3} t40}

test Classy::Canvas {save group} {
	classyclean
	Classy::Canvas .try
	pack .try -fill both -expand yes
	for {set i 0} {$i<5} {incr i} {
		set pos [expr {10*$i}]
		set id($i) [.try create text $pos $pos -text $pos -tags "t$pos"]
	}
	set g1 [.try group items $id(0) $id(1)]
	set g2 [.try group items $id(2) $id(3)]
	set g3 [.try group tags $g1 $g2]
	set d [.try save]
	.try delete all
	.try create text 10 50 -text A -tags a
	.try create text 10 50 -text A -tags a
	.try group withtag a
	.try load $d
	.try mitemcget all -tags
} {{a _g4} {a _g4} {t0 _g5 _g6 _new} {t10 _g5 _g6 _new} {t20 _g7 _g6 _new} {t30 _g7 _g6 _new} {t40 _new}}

test Classy::Canvas {print dialog} {
	classyclean
	Classy::Canvas .try
	.try configure -papersize A4
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A"]
	.try create text 50 50 -text "B" -font {times 14 bold}
	.try create line 20 10 60 50 -width 4
	.try itemconfigure $id -text
	.try print
	manualtest
} {}

testsummarize
