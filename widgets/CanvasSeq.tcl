# *************************************************
#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# CanvasSeq
# ----------------------------------------------------------------------
#doc CanvasSeq title {
#CanvasSeq
#} index {
# Charts
#} shortdescr {
# grid that can be displayed on canvas
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# <b>A CanvasSeq is not a widget type</b>. It is a class whose objects can 
# be associated with a canvas widget. When a CanvasSeq instance is 
# associated with a canvas, it will draw on this canvas. 
# Several CanvasSeq objects can be associated
# with the same canvas.
#}
#doc {CanvasSeq options} h2 {
#	CanvasSeq specific options
#} descr {
# BarcHart objects support the following options in its configure method
#<dl>
#<dt>-canvas<dd>name of canvas to draw the barchart
#<dt>-area<dd>area in which to diplay the chart (a list of four numbers)
#<dt>-boxwidth<dd>display a rectangle with this width showing the area 
#<dt>-boxcolor<dd>color of area rectangle
#</dl>
#}
#doc {CanvasSeq command} h2 {
#	CanvasSeq specific methods
#} descr {
#}
# These will be added to tclIndex by Classy::auto_mkindex
#auto_index ::Classy::CanvasSeq
#auto_index CanvasSeq

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::CanvasObject subclass Classy::CanvasSeq
Classy::export CanvasSeq {}

Classy::CanvasSeq classmethod init {args} {
	super init
	private $class actions
	private $object options id
	array set options {
		-height 100 -between 20 -start 0 -end 200
		-basesperline 100 -getseq {} 
		-tickstart 0 -tickinterval 50 -endtick 0
		-getboxes {}
	}
	array set actions {
		-height {
			::Classy::todo $object redraw
		}
		-between {
			::Classy::todo $object redraw
		}
		-start {
			::Classy::todo $object redraw
		}
		-basesperline {
			::Classy::todo $object redraw
		}
		-tickstart {
			::Classy::todo $object redraw
		}
		-tickinterval {
			::Classy::todo $object redraw
		}
		-endtick {
			::Classy::todo $object redraw
		}
		-end {
			::Classy::todo $object redraw
		}
		-getseq {
			::Classy::todo $object redraw
		}
		-font {
			::Classy::todo $object redraw
		}
		-getboxes {
			::Classy::todo $object redraw
		}
	}
	eval $object configure $args
	return $object
}


#doc {CanvasSeq command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::CanvasSeq method destroy {} {
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {CanvasSeq command redraw} cmd {
#pathname redraw
#} descr {
#}
Classy::CanvasSeq method redraw {args} {
	private $object options
	set c $options(-canvas)
	catch {$c delete __co::$object}
	$object _redrawbox
	set pl $options(-basesperline)
	set length [expr {$options(-end) - $options(-start)}]
	set end $options(-end)
	set areax1 [lindex $options(-area) 0]
	set areax2 [lindex $options(-area) 2]
	set width [expr {$areax2 - $areax1}]
	set y [lindex $options(-area) 1]
	set tick $options(-tickstart)
	set currentpos $options(-start)
	while {1} {
		if {$tick >= $currentpos} break
		incr tick $options(-tickinterval)
	}
	while {1} {
		if {$currentpos > $end} break
		incr y $options(-height)
		if {$y > [lindex $options(-area) 3]} break
		if {$length > $pl} {
			set x2 $areax2
		} else {
			set x2 [expr {$areax1+$length*$width/$pl}]
		}
		incr length -$pl
		$c create line $areax1 $y $x2 $y -tags __co::$object
		set x [expr {$areax1+($tick-$currentpos)*$width/$pl}]
		set incr [expr {$options(-tickinterval)*$width/$pl}]
		incr currentpos $pl
		while {1} {
			$c create line $x $y $x [expr {$y+4}] -tags __co::$object
			$c create text $x [expr {$y+4}] -anchor nw -text $tick -tags __co::$object
			incr x $incr
			incr tick $options(-tickinterval)
			if {$tick > $end} {
				set tick $end
				if !$options(-endtick) break
				set x [expr {$areax1+($end-$currentpos+$pl)*$width/$pl}]
				$c create line $x $y $x [expr {$y+4}] -tags __co::$object
				$c create text $x [expr {$y+4}] -anchor nw -text $end -tags __co::$object
				break
			}
			if {$tick > $currentpos} break
		}
		incr y $options(-between)
	}
	if {"$options(-getboxes)" != ""} {
		set f [expr {$width/$pl}]
		set hdiff [expr {$options(-height) + $options(-between)}]
		set hf [expr {$options(-height)/100.0}]
		foreach box [eval $options(-getboxes) $options(-start) $tick] {
			foreach {tag s e h opt} $box {}
			set block 0
			set y [lindex $options(-area) 1]
			incr y $options(-height)
			while {$s > $pl} {
				incr y $hdiff
				incr s -$pl
				incr e -$pl
			}
			set x1 [expr {$areax1+$s*$f}]
			set x2 [expr {$areax1+$e*$f}]
			set ytop [expr {$y-$h*$hf}]
			eval {$c create rectangle $x1 $ytop $x2 $y \
				-tags [concat __co::$object __coblock::$object $tag]]} $opt
		}
		$c lower __coblock::$object
	}
}

Classy::CanvasSeq method xpos {x y} {
	private $object options
	set c $options(-canvas)
	set hdiff [expr {$options(-height) + $options(-between)}]
	set areax1 [lindex $options(-area) 0]
	set areay1 [lindex $options(-area) 1]
	set areax2 [lindex $options(-area) 2]
	set width [expr {$areax2 - $areax1}]
	set x [$c canvasx $x]
	set y [$c canvasy $y]
	set block [expr {int(($y-$areay1)/$hdiff)}]
	set xpos [expr {($x-$areax1)*$options(-basesperline)/$width}]
	return [expr {$block * $options(-basesperline) + $xpos}]
}

Classy::CanvasSeq method addboxes {args} {
	private $object boxes
	
}
