#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::Browser
# ----------------------------------------------------------------------
#doc Browser title {
#Browser
#} descr {
#}
#doc {Browser options} h2 {
#	Browser specific options
#}
#doc {Browser command} h2 {
#	Browser specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Browser {} {}
proc Browser {} {}
}
catch {Classy::Browser destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Browser
Classy::export Browser {}

bind Classy::Browser <Configure> {%W redraw}
Classy::Browser classmethod init {args} {
	# REM Create object
	# -----------------
	super
	canvas $object.c -xscrollcommand [list $object.hbar set] -yscrollcommand [list $object.vbar set]
	scrollbar $object.vbar -command [list $object.c yview] -orient vertical
	scrollbar $object.hbar -command [list $object.c xview] -orient horizontal
	grid $object.c $object.vbar -row 0 -sticky nwse
	grid columnconfigure $object 0 -weight 1
	grid columnconfigure $object 1 -weight 0
	grid rowconfigure $object 0 -weight 1
	grid rowconfigure $object 1 -weight 0

	# REM Create bindings
	# -------------------

	# REM Initialise variables
	# ------------------------
	private $object data
	set data() {}

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::Browser chainoptions {$object.c}

Classy::Browser addoption -minx {minX MinX 50} {
	Classy::todo $object redraw
}

Classy::Browser addoption -miny {minY MinY 50} {
	Classy::todo $object redraw
}

Classy::Browser addoption -padx {padX PadX 4} {
	Classy::todo $object redraw
}

Classy::Browser addoption -pady {padY PadY 4} {
	Classy::todo $object redraw
}

Classy::Browser addoption -padtext {padText PadText 4} {
	Classy::todo $object redraw
}

Classy::Browser addoption -font {font Font {}} {
	if {"$value" == ""} {
		set value [option get $object.c font Font]
	}
	Classy::todo $object redraw
}

Classy::Browser addoption -datafont {dataFont Font {}} {
	if {"$value" == ""} {
		set value [option get $object.c font Font]
	}
	Classy::todo $object redraw
}

Classy::Browser addoption -data {data Data {}} {
	Classy::todo $object redraw
}

Classy::Browser addoption -dataunder {dataUnder DataUnder 0} {
	set value [true $value]
	Classy::todo $object redraw
}

Classy::Browser addoption -order {order Order row} {
	switch $value {
		column {
			grid forget $object.vbar
			grid $object.hbar -row 1 -column 0 -sticky we
		}
		row {
			grid forget $object.hbar
			grid $object.vbar -row 0 -column 1 -sticky ns
		}
		list {
			grid forget $object.hbar
			grid $object.vbar -row 0 -column 1 -sticky ns
		}
		default {
			error "unknown value \"$value\" for option -order: must be row, column or list"
		}
	}
	Classy::todo $object redraw
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Browser chainallmethods {$object.c} canvas

Classy::Browser method add {name args} {
	private $object data options
	Classy::parseopt $args opt [list \
		-text {} $name \
		-data {} {} \
		-image {} [Classy::geticon file] \
		-window {} {} \
	] args
	lappend data() $name
	set data(n,$name) $opt(-text)
	set data(d,$name) $opt(-data)
	set data(i,$name) $opt(-image)
	set data(w,$name) $opt(-window)
	Classy::todo $object redraw
}

Classy::Browser method redraw {} {
	private $object data options
	set minx $options(-minx)
	set miny $options(-miny)
	set padx $options(-padx)
	set pady $options(-pady)
	set padtext $options(-padtext)
	set w $object.c
	$w delete all
	Classy::canceltodo $object redraw
	update idletasks
	set startx $padx
	set starty $pady

	if {"$options(-order)" == "row"} {
		set sw [winfo width $object.c]
		set x $startx
		set y $starty
		set ny $y
		set notfirst 0
		foreach name $data() {
			set bx $x
			set by $y
			set id [$w create image $x $y -anchor nw -image $data(i,$name) -tags [list $name image]]
			set bbox [$w bbox $id]
			set height [expr {[lindex $bbox 3]-[lindex $bbox 1]}]
			set width [expr {[lindex $bbox 2]-[lindex $bbox 0]}]
			if {$width < $minx} {
				$w move $id [expr {($minx - $width)/2}] 0
				set width $minx
			}
			if {$height < $miny} {
				$w move $id 0 [expr {($miny - $height)/2}]
				set height $miny
			}
			set id [$w create text [expr {$x+$width/2}] [expr {$y+$height+$padtext}] \
				-anchor n -justify center -text $data(n,$name) \
				-tags [list $name text] -font $options(-font)]
			set bbox [$w bbox $id]
			set temp [expr {$y + $height + [expr {[lindex $bbox 3]-[lindex $bbox 1]}] + $padtext + $pady}]
			if {$temp > $ny} {set ny $temp}
			set temp [expr {[lindex $bbox 2]-[lindex $bbox 0]}]
			if {$temp > $width} {
				$w move $name [expr {($temp-$width)/2}] 0
				set x [expr {$x + $temp + $padx}]
			} else {
				set x [expr {$x + $width + $padx}]
			}
			if $options(-dataunder) {
				set ny [$object _drawdataunder $x $ny $name $id]
				set x [lshift ny]
			}

			if {($x > $sw)&&$notfirst} {
				set notfirst 0
				$w move $name [expr {$startx - $bx}] [expr {$ny - $by}]
				set bbox [$w bbox $name]
				set x [expr {[lindex $bbox 2]+$padx}]
				set y $ny
			}
			set notfirst 1
		}
		$object.c configure -scrollregion [list 0 0 $sw $ny]
	} elseif {"$options(-order)" == "column"} {
		set sh [winfo height $object.c]
		set x $startx
		set y $starty
		set nx $x
		set notfirst 0
		foreach name $data() {
			set bx $x
			set by $y
			set id [$w create image $x $y -anchor nw -image $data(i,$name) -tags [list $name image]]
			set bbox [$w bbox $id]
			set height [expr {[lindex $bbox 3]-[lindex $bbox 1]}]
			set width [expr {[lindex $bbox 2]-[lindex $bbox 0]}]
			if {$width < $minx} {
				$w move $id [expr {($minx - $width)/2}] 0
				set width $minx
			}
			if {$height < $miny} {
				$w move $id 0 [expr {($miny - $height)/2}]
				set height $miny
			}
			set id [$w create text [expr {$x+$width+$padtext}] [expr {$y+$height/2}] \
				-anchor w -text $data(n,$name) \
				-tags [list $name text] -font $options(-font)]
			set bbox [$w bbox $id]
			set temp [expr {$x + $width + [expr {[lindex $bbox 2]-[lindex $bbox 0]}] + $padtext + $padx}]
			if {$temp > $nx} {set nx $temp}
			set y [expr {$y + $height + $pady}]
			if $options(-dataunder) {
				$w move $id 0 [expr {-$height/2}]
				$w itemconfigure $id -anchor nw
				set y [$object _drawdataunder $nx $y $name $id]
				set nx [lshift y]
			}
			if {($y > $sh)&&$notfirst} {
				if !$options(-dataunder) {
					set nx [$object _drawdata $nx $names $items]
				}
				$w move $name [expr {$nx - $bx}] [expr {$starty - $by}]
				set names {}
				set items {}
				set notfirst 0
				set bbox [$w bbox $name]
				set x $nx
				set y [expr {[lindex $bbox 3]+$pady}]
			}
			lappend names $name
			lappend items $id
			set notfirst 1
		}
		if !$options(-dataunder) {
			set nx [$object _drawdata $nx $names $items]
		}
		$object.c configure -scrollregion [list 0 0 $nx $sh]
	} elseif {"$options(-order)" == "list"} {
		set sh [winfo height $object.c]
		set x $startx
		set y $starty
		set nx $x
		set notfirst 0
		set items {}
		foreach name $data() {
			set id [$w create image $x $y -anchor nw -image $data(i,$name) -tags [list $name image]]
			set bbox [$w bbox $id]
			set height [expr {[lindex $bbox 3]-[lindex $bbox 1]}]
			set width [expr {[lindex $bbox 2]-[lindex $bbox 0]}]
			if {$width < $minx} {
				$w move $id [expr {($minx - $width)/2}] 0
				set width $minx
			}
			if {$height < $miny} {
				$w move $id 0 [expr {($miny - $height)/2}]
				set height $miny
			}
			set temp [expr {$y + $height + 2*$pady}]
			set id [$w create text [expr {$x+$width+$padtext}] [expr {$y+$height/2}] \
				-anchor w -text $data(n,$name) \
				-tags [list $name text] -font $options(-font)]
			lappend items $id
			set bbox [$w bbox $id]
			set temp [expr {$x + $width + [expr {[lindex $bbox 2]-[lindex $bbox 0]}] + $padtext + $padx}]
			if {$temp > $nx} {set nx $temp}
			set y [expr {$y + $height + $pady}]
			if $options(-dataunder) {
				$w move $id 0 [expr {-$height/2}]
				$w itemconfigure $id -anchor nw
				set y [$object _drawdataunder $nx $y $name $id]
				set nx [lshift y]
			}
		}
		set cy $y
		if !$options(-dataunder) {
			set nx [$object _drawdata $nx $data() $items]
		}
		$object.c configure -scrollregion [list 0 0 $nx $cy]
	}
}

Classy::Browser method _drawdataunder {nx ny name id} {
	private $object data options
	set padx $options(-padx)
	set pady $options(-pady)
	set padtext $options(-padtext)
	set w $object.c
	set bbox [$w bbox $id]
	set tempy [lindex $bbox 3]
	set tempx [lindex $bbox 0]
	foreach dt $options(-data) d $data(d,$name) {
		set tempid [$w create text $tempx $tempy \
			-anchor nw -text $d -tags [list $name $dt] -font $options(-datafont)]
		set bbox [$w bbox $tempid]
		set tempy [lindex $bbox 3]
		set temp [expr {$tempx + [expr {[lindex $bbox 2]-[lindex $bbox 0]}] + $padx}]
		if {$temp > $nx} {set nx $temp}
	}
	set tempy [expr {$tempy+$pady}]
	if {$tempy > $ny} {set ny $tempy}
	return [list $nx $ny]
}

Classy::Browser method _drawdata {nx names items} {
	private $object data options
	set padx $options(-padx)
	set pady $options(-pady)
	set padtext $options(-padtext)
	set w $object.c
	set i 0
	foreach dt $options(-data) {
		set cx [expr {$nx-$padx+$padtext}]
		set nitems ""
		foreach name $names item $items {
			set d [lindex $data(d,$name) $i]
			set y [lindex [$object.c coords $item] 1]
			set id [$w create text $cx $y \
				-anchor w -text $d -tags [list $name $dt] -font $options(-datafont)]
			set bbox [$w bbox $id]
			lappend nitems $id
			set temp [expr {$cx + [expr {[lindex $bbox 2]-[lindex $bbox 0]}]}]
			if {$temp > $nx} {set nx $temp}
		}
		foreach name $names item $nitems {
			$w coords $item $nx [lindex [$object.c coords $item] 1]
			$w itemconfigure $item -anchor e
		}
		incr i
		set nx [expr {$nx + $padx}]
	}
	return $nx
}

Classy::Browser method clear {} {
	private $object data options
	$object.c delete all
	unset data
	set data() {}
}

Classy::Browser method name {index {y {}}} {
	if {"$y" != ""} {
		set index [$object.c find overlapping $index $y $index $y]
	}
	set tags [$object itemcget $index -tags]
	return [lindex $tags 0]
}

Classy::Browser method type {index {y {}}} {
	if {"$y" != ""} {
		set index [$object.c find overlapping $index $y $index $y]
	}
	set tags [$object itemcget $index -tags]
	return [lindex $tags 1]
}
