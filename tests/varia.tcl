#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"
source tools.tcl

test Classy::parseopt {basic} {
	Classy::parseopt {-a -b try} opt {
		-a {0 1} 0
		-b {} {}
		-c {0 1} 0
	}
	set list ""
	foreach name [lsort [array names opt]] {
		lappend list $name $opt($name)
	}
	set list
} {-a 1 -b try -c 0}

test Classy::parseopt {basic} {
	Classy::parseopt {-a b} opt {
		-a {a b} c
		-b {a b} c
	}
	set list ""
	foreach name [lsort [array names opt]] {
		lappend list $name $opt($name)
	}
	set list
} {-a b -b c}

test Classy::parseopt {error} {
	Classy::parseopt {-a c} opt {
		-a {a b} c
	}
} {Incorrect value "c" for option -a: must be one of: a b} 1

test Classy::Paned {basic} {
	classyclean
	Classy::Paned .try -window .l1
	listbox .l1
	listbox .l2
	grid .l1 .try .l2 -sticky nwse
	grid columnconfigure . 2 -weight 1
	manualtest
} {}

test Classy::Paned {reverse} {
	classyclean
	Classy::Paned .try -window .l2
	listbox .l1
	listbox .l2
	grid .l1 .try .l2 -sticky nwse
	grid columnconfigure . 0 -weight 1
	manualtest
} {}

test Classy::Paned {vertical} {
	classyclean
	Classy::Paned .try -window .l1 -orient vertical
	listbox .l1 -height 4
	listbox .l2
	grid .l1 -sticky nwse
	grid .try -sticky nwse
	grid .l2 -sticky nwse
	grid rowconfigure . 2 -weight 1
	manualtest
} {}

test Classy::Paned {horizontal 3 in frame} {
	classyclean
	frame .f -width 20
	Classy::Paned .f.try -window .f.l1 -gainfrom .f.l2 -snaptoborder 1
	Classy::Paned .f.try2 -window .f.l2
	text .f.l1 -width 2
	text .f.l2 -width 2
	text .f.l3 -width 2
	grid .f.l1 .f.try .f.l2 .f.try2 .f.l3 -sticky nwse
	grid columnconfigure .f 4 -weight 1
	grid rowconfigure .f 0 -weight 1
	button .b -text unused
	grid .f -row 0 -column 0 -sticky nwse
	grid .b -row 0 -column 1
	grid columnconfigure . 0 -weight 1
	grid rowconfigure . 0 -weight 1
	manualtest
} {}

test Classy::Paned {vertical 3 in frame} {
	classyclean
	frame .f -width 20
	text .f.l1 -height 2
	text .f.l2 -height 2
	text .f.l3 -height 2
	Classy::Paned .f.try -window .f.l1 -gainfrom .f.l2 -orient vertical
	Classy::Paned .f.try2 -window .f.l2 -orient vertical
	foreach w {.f.l1 .f.try .f.l2 .f.try2 .f.l3} {
		grid $w -sticky nwse
	}
	grid columnconfigure .f 0 -weight 1
	grid rowconfigure .f 4 -weight 1
	button .b -text unused
	grid .f -row 0 -column 0 -sticky nwse
	grid .b -row 0 -column 1
	grid columnconfigure . 0 -weight 1
	grid rowconfigure . 0 -weight 1
	manualtest
} {}

test Classy::Paned {reverse 3} {
	classyclean
	Classy::Paned .try -window .l2
	Classy::Paned .try2 -window .l3 -gainfrom .l2
	text .l1 -width 2
	text .l2 -width 2
	text .l3 -width 2
	grid .l1 .try .l2 .try2 .l3 -sticky nwse
	grid columnconfigure . 0 -weight 1
	manualtest
} {}

test Classy::OptionBox {basic} {
	classyclean
	Classy::OptionBox .try -label Try -variable try -orient vertical
	pack .try -fill x
	.try add t1 "T 1"
	.try add t2 "T 2"
	.try add t3 "T 3"
	.try set t2
	.try get
} {t2}

test Classy::OptionBox {-labelbackground} {
	classyclean
	Classy::OptionBox .try -label Try -variable try -orient vertical -labelbackground green
	.try add t1 "T 1"
	.try add t2 "T 2"
	pack .try -fill x
	.try cget -labelbackground
} {green}

test Classy::OptionBox {command} {
	classyclean
	set ::try ""
	Classy::OptionBox .try -label Try -variable try -orient vertical -command {set ::try}
	pack .try -fill x
	.try add t1 "T 1"
	.try add t2 "T 2"
	.try add t3 "T 3"
	.try set t2
	set ::try
} {t2}

if {"$::tcl_platform(platform)" != "windows"} {
test Classy::FontSelector {basic} {
	classyclean
	Classy::FontSelect .try
	pack .try -fill both -expand yes
	.try set {times 16 bold italic underline}
	.try set {times 16 {bold italic overstrike}}
	.try set {times 16.2 italic}
	.try set {helvetica 16 {bold}}
	.try get
} {helvetica 16 {bold roman}}

test Classy::getfont {basic} {
	classyclean
	Classy::getfont -font {times 16 {bold italic}}
} {times 16 {bold roman}}

test Classy::getfont {command} {
	classyclean
	set ::temp {}
	Classy::getfont -font {times 16 bold italic} -command {set ::temp}
	tkwait variable temp
	set ::temp
} {times 16 {bold roman}}

} else {
test Classy::FontSelector {basic} {
	classyclean
	Classy::FontSelect .try
	pack .try -fill both -expand yes
	.try set {Arial 16 {bold}}
	.try get
} {Arial 16 {bold roman}}

test Classy::getfont {basic} {
	classyclean
	Classy::getfont -font {Arial 16}
} {Arial 16 { normal}}
}

test Classy::RepeatButton {basic} {
	catch {rename Classy::RepeatButton {}}
	Classy::RepeatButton .try -text try -command {puts ok}
	pack .try
	manualtest
} {}

test Classy::Progress {basic} {
	classyclean
	Classy::Progress .try -ticks 10000
	pack .try -fill x -expand yes
	#.try set 50
	for {set i 0} {$i<10000} {incr i} {
		.try incr
	}
	.try redraw
	.try get
} {10000}

test Classy::Progress {run 2 times} {
	classyclean
	Classy::Progress .try -ticks 1000
	pack .try -fill x -expand yes
	for {set i 0} {$i<1000} {incr i} {
		.try incr
	}
	.try redraw
	.try set 0
	for {set i 0} {$i<1000} {incr i} {
		.try incr
	}
	.try redraw
	.try get
} {1000}

test Classy::ProgressDialog {basic} {
	classyclean
	Classy::ProgressDialog .try -message "Testing\n Please wait" -ticks 5000
	#.try set 50
	for {set i 0} {$i<5000} {incr i} {
		.try incr
	}
	.try redraw
	.try get
} {5000}

test Classy::OptionMenu {basic} {
	classyclean
	Classy::OptionMenu .try -list {try {try 1} {try 2} {try 3} dfgsd\\1dfg xdg&dfj cfdgdsgh\\gdsf}
	pack .try -fill x
	.try set {try 2}
	.try get
} {try 2}

test Classy::OptionMenu {two} {
	classyclean
	Classy::OptionMenu .try -list {try {try 1} {try 2} {try 3} dfgsd\\1dfg xdg&dfj cfdgdsgh\\gdsf}
	pack .try -fill x
	Classy::OptionMenu .try2 -list {try {try 1} {try 2} {try 3} dfgsd\\1dfg xdg&dfj cfdgdsgh\\gdsf}
	pack .try2 -fill x
	.try set {try 2}
	.try2 get
} {try}

test Classy::OptionMenu {command} {
	classyclean
	catch {unset ::try}
	Classy::OptionMenu .try \
		-command {set ::try} \
		-list {try {try 1} {try 2} {try 3} dfgsd\\1dfg xdg&dfj cfdgdsgh\\gdsf}
	pack .try -fill x
	.try set {try 2}
	set ::try
} {try 2}

test Classy::OptionMenu {images} {
	classyclean
	catch {unset ::try}
	set ::try w
	Classy::OptionMenu .try -textvariable try \
		-images [list [Classy::geticon anchor_center] [Classy::geticon anchor_e] [Classy::geticon anchor_w]] \
		-list [list center e w]
	pack .try -fill x
	.try set e
	get ::try
} {e}

test Classy::OptionMenu {textvariable} {
	classyclean
	catch {unset ::try}
	set ::try w
	Classy::OptionMenu .try -textvariable try \
		-list [list center e w] \
		-images [list [Classy::geticon anchor_center] [Classy::geticon anchor_e] [Classy::geticon anchor_w]]
	pack .try -fill x
	set ::try e
	.try get
} {e}

test Classy::OptionMenu {array textvariable} {
	classyclean
	catch {unset ::try}
	set ::try(it) w
	Classy::OptionMenu .try -textvariable try(it) \
		-images [list [Classy::geticon anchor_center] [Classy::geticon anchor_e] [Classy::geticon anchor_w]] \
		-list [list center e w]
	pack .try -fill x
	set ::try(it) e
	.try get
} {e}

test Classy::MultiListBox {basic} {
	classyclean
	Classy::MultiListbox .try -number 2 -command {puts stdout}
	pack .try -fill both -expand yes
	.try add a b c d e f g h
	.try select 1
	.try get
} {c
d}

test Classy::Fold {basic} {
	classyclean
	Classy::Fold .try -title {Fold it} -opencommand {set ::try 1}
	pack .try -fill both
	set w [.try component content]
	text $w.text
	pack $w.text
	set ::try 0
	.try open
	set ::try
} {1}

test Classy::ScrolledFrame {basic} {
	classyclean
	set w .try.test
	set w [Classy::ScrolledFrame .try]
	pack .try -fill both -expand yes
	pack [button $w.b1 -text "Trying an terribly long button with lots of nonsense on it"]
	pack [button $w.b2 -text "Try 1"] -fill x
	pack [button $w.b3 -text "Try 2"]
	pack [button $w.b4 -text "Try 3" -height 20]
	pack [button $w.b5 -text "Try 4"]
	pack .try -fill both -expand yes
	manualtest
} {}

test Classy::Message {basic} {
	classyclean
	Classy::Message .try -text "Trying it out"
	pack .try -fill x
} {}

test Classy::ListBox {basic} {
	classyclean
	Classy::ListBox .try -content {{Trying it out with something long} now a b c d e f g h i j}
	pack .try -fill both -expand yes
	.try configure -command {puts} -browsecommand {invoke value {puts "browse:$value"}}
} {}

test Classy::MultiFrame {basic} {
	classyclean
	Classy::MultiFrame .try
	pack .try -fill both -expand yes
	frame .try.f1 -bg gray
	frame .try.f2 -bg blue
	.try select f2
	update
	winfo viewable .try.f2
} {1}

testsummarize

