#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

test Classy::ChartGrid {create and configure} {
	clean
	eval destroy [winfo children .]
	tk appname test
	package require ClassyTcl
	canvas .try
	pack .try -fill both -expand yes
	update idletasks
	Classy::ChartGrid new try -canvas .try \
		-ystep 1 -xrange {0 20} -yrange {0 20} \
		-font {helvetica 9}
	set ::try 1
} {1}

test Classy::BarChart {create and configure} {
	clean
	eval destroy [winfo children .]
	tk appname test
	package require ClassyTcl
	canvas .try
	pack .try -fill both -expand yes
	update idletasks
	Classy::ChartGrid new chartgrid -ystep 1 -xrange {0 20} -yrange {0 20} -font {helvetica 9}
	chartgrid configure -canvas .try
	BarChart new try -xrange {0 20} -yrange {0 20}
	try configure -canvas .try
	try dataset Try {5 6 5 5 4 5 6 7}
	try dataset "Try 2" {4 5 4 4 5 6 5 9}
	try dataset "Try3" {10 6 3 9 3 8 4 10}
	try configure -displace 0.2 -barwidth 0.5
	chartgrid configure -showx 0
	try configure -labels {Aa Bb Cccc D E F G H I J K L M N} -labelorient vertical
	if 0 {
		try barconfigure Try -fill green -stipple gray50
		try barconfigure "Try 2" -fill red
		try configure -percentages yes -stacked yes
		set yrange {0 100}
		chartgrid configure -yrange $yrange
		try configure -yrange $yrange
		set xrange {0 20}
		set xrange {0 100}
		try configure -xrange $xrange
		chartgrid configure -xrange $xrange
	}
	try dataget Try
} {5 6 5 5 4 5 6 7}

test Classy::BarChartBox {create and configure} {
	clean
	eval destroy [winfo children .]
	tk appname test
	package require ClassyTcl

	Classy::BarChartBox .try
	.try dataset Try {5 6 5 5 4 5 6 7}
	.try dataset "Try 2" {4 5 4 4 5 6 5 9}
	.try dataset "Try3" {10 6 3 9 3 8 4 10}
	.try chartconfigure -displace 0.2 -barwidth 0.5
	.try chartconfigure -labels {Aa Bb Cccc D E F G H I J K L M N} -labelorient vertical
	.try dataget Try
	manualtest
} {5 6 5 5 4 5 6 7}

test Classy::LineChart {create and configure} {
	clean
	eval destroy [winfo children .]
	tk appname test
	package require ClassyTcl
	canvas .try
	pack .try -fill both -expand yes
	update idletasks
	Classy::ChartGrid new chartgrid -ystep 1 -xrange {0 20} -yrange {0 10} -font {helvetica 9}
	chartgrid configure -canvas .try
	Classy::LineChart new try -ystep 1 -xrange {0 20} -yrange {0 10} -canvas .try
	try dataset Try {1 5 2 6 3 5 4 5 5 4 6 5 7 6 8 7}
	try dataset "Try 2" {1 4 2 5 3 4 4 4 5 5 6 6 7 5 8 9}
	try dataset "Try 3" {1 8 2 9 3 8 4 8 5 20 6 -4 7 -3 8 9}
	set xrange {2 7.5};set yrange {-2 15}
	try configure -xrange $xrange -yrange $yrange 
	chartgrid configure -xrange $xrange -yrange $yrange
	if 0 {
		try lineconfigure Try -width 2 -fill green
		try lineconfigure "Try 2" -width 2 -fill blue
		set data ""
		for {set i 0} {$i<1000} {incr i} {
			lappend data $i [random [expr $i/2.0] $i]
		}
		try dataset Try $data
	}
	try dataget Try
} {1 5 2 6 3 5 4 5 5 4 6 5 7 6 8 7}

test Classy::LineChartBox {create and configure} {
	clean
	eval destroy [winfo children .]
	tk appname test
	package require ClassyTcl

	Classy::LineChartBox .try
	.try dataset Try {1 5 2 6 3 5 4 5 5 4 6 5 7 6 8 7}
	.try dataset "Try 2" {1 4 2 5 3 4 4 4 5 5 6 6 7 5 8 9}
	.try dataset "Try 3" {1 8 2 9 3 8 4 8 5 20 6 7 7 9 8 9}
	.try dataget Try
	manualtest
} {1 5 2 6 3 5 4 5 5 4 6 5 7 6 8 7}

testsummarize
catch {unset errors}

