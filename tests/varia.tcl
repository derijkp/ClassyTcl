#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"
source tools.tcl

test Classy::Paned {basic} {
	classyclean
	Classy::Paned .try -window .l1
	listbox .l1
	listbox .l2
	grid .l1 .try .l2 -sticky nwse
	grid columnconfigure . 2 -weight 1
	manualtest
	set try 1
} {1}

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

test Classy::FontSelector {basic} {
	classyclean
	Classy::FontSelect .try
	pack .try -fill both -expand yes
	.try set {helvetica 16 {bold}}
	.try get
} {helvetica 16 {bold roman}}

test Classy::getfont {basic} {
	classyclean
	Classy::getfont -font {helvetica 16 {bold roman}}
} {helvetica 16 {bold roman}}

test Classy::RepeatButton {basic} {
	catch {rename Classy::RepeatButton {}}
	Classy::RepeatButton .try -text try -command {puts ok}
	pack .try
	manualtest
	set try 1
} {1}

test Classy::Progress {basic} {
	classyclean
	Classy::Progress .try -message "Testing\n Please wait" -ticks 1000 -step 100
	#.try set 50
	for {set i 0} {$i<1000} {incr i} {
		.try incr
	}
	.try get
} {1000}

test Classy::OptionMenu {basic} {
	classyclean
	Classy::OptionMenu .try -list {try {try 1} {try 2} {try 3} dfgsd\\1dfg xdg&dfj cfdgdsgh\\gdsf}
	pack .try -fill x
	.try set {try 2}
	.try get
} {try 2}

test Classy::MultiListBox {basic} {
	classyclean
	Classy::MultiListbox .try -number 2 -command {puts stdout [.try get]}
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

testsummarize
