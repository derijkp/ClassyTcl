# Classy::TreeView
# ----------------------------------------------------------------------
#doc TreeView title {
#TreeView
#} descr {
# This widget is largely based on code from:
# <p>
# Sensus Consulting Ltd (C) 1997
# Matt Newman <matt@sensus.org>
#}
#doc {TreeView options} h2 {
#	TreeView specific options
#}
#doc {TreeView command} h2 {
#	TreeView specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc Classy::TreeView {} {}
proc TreeView {} {}
}
catch {Classy::TreeView destroy}

option add *TreeView.padX 18 widgetDefault
option add *TreeView.padY 16 widgetDefault
option add *TreeView.background white widgetDefault
option add *TreeView.highlightThickness 0 widgetDefault
option add *TreeView.width 1 widgetDefault
option add *TreeView.height 1 widgetDefault

proc treeview {w args} {
	return [uplevel 1 tk++::TreeView $w $args]
}

Widget subclass Classy::TreeView

Classy::TreeView classmethod init {args} {
	super
	canvas $object.c -relief flat -borderwidth 0
	pack $object.c -anchor nw -side left -fill both -expand yes

	# REM Create bindings
	# -------------------
	$object.c bind ctrl	<Button-1>		[list $object toggle %x %y]
	$object.c bind folder	<Button-1>		[list $object select %x %y]
	$object.c bind folder	<Double-Button-1> [list $object toggle %x %y]
	$object.c bind folder	<Button-3> [list $object context %x %y]

	$object.c configure -scrollregion {0 0 1 1}
	$object _newNode 0 0 [list image folder]
	$object expand 0
	$object.c xview moveto 0.0
	$object.c yview moveto 0.0

	# REM Initialise variables
	# ------------------------
	setprivate $object uid 0
	setprivate $object selection {}

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::TreeView addoption -background {background Background white}
Classy::TreeView addoption -highlightthickness {highlightThickness HighlightThickness 0}
Classy::TreeView addoption -height {height Height 1}
Classy::TreeView addoption -width {width Width 1}
Classy::TreeView addoption -command {command Command ""}
Classy::TreeView addoption -controls [list controls Controls [list [Classy::geticon plus] [Classy::geticon minus]]]
Classy::TreeView addoption -hide {hide Hide 1}
Classy::TreeView addoption -padx {padX PadX 18}
Classy::TreeView addoption -pady {padY PadY 16}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::TreeView method closest {x y} {
	set tag [$object.c find closest \
						[$object.c canvasx $x] \
						[$object.c canvasy $y] ]
	if {$tag == ""} return

	# 1st tag is always object
	set o [lindex [$object.c itemcget $tag -tags] 0]
	if {![string match *.all $o]} {
		error "unexpected tag: \"$o\""
	}
	regsub {\.all$} $o {} o
	return $o
}
#
# Context Request: typically client of this widget will post
#		a "context" menu of operations that may be
#		performed on this node.
#
Classy::TreeView method context {x y} {
	set o [$object closest $x $y]
	if {$o == ""} return

	$object activate $o

	# WARNING:	re-entrant
	# This callback is expected to invoke
	# our insert/delete methods
	$object _callback $o context $x $y
}
Classy::TreeView method curselection {} {
	return [getprivate $object selection]
}
#
# Selection:
#
Classy::TreeView method select {x y} {
	set o [$object closest $x $y]
	if {$o == ""} return

	$object activate $o
}
Classy::TreeView method toggle {x y} {
	private $object v
	set o [$object closest $x $y]
	if {$o == ""} return

	if {$v($o,expanded)} {
		$object unexpand $o
	} else {
		$object expand $o
	}
}
#
# Node specific methods
#
Classy::TreeView method activate {o} {
	private $object selection v
	if {$o != "none" && $v($o,selected)} return

	if {$selection != ""} {
		$object _callback $selection activate 0
		$object.c select clear
		set $selection,selected)	0
		set selection {}
	}
	if {$o == "none"} return

	$object _callback $o activate 1

	set selection		$o
	set v($o,selected)	1

	$object _refreshNode $o

	$object see $o
}
Classy::TreeView method add {o args} {
	private $object uid v
	set po $o
	set o [incr uid]

	lappend v($po,children)	$o
	$object _newNode $po $o $args

	return $o
}
Classy::TreeView method children {o args} {
	private $object v
	if {[llength $args]==0} {
		return $v($o,children)
	}
	set ret {}
	foreach cid $v($o,children) {
		set ok 1
		foreach {fld val} $args {
			set cval [structlget $v($cid) $fld __NULL__]
			if {[string compare $val $cval]!=0}	{
				set ok 0
				break
			}
		}
		if {$ok} {
			lappend ret $cid
		}
	}
	return $ret
}
Classy::TreeView method delete {o {master 1}} {
	private $object selection v
	if {$master && [$object isdesendant $selection $o]} {
		$object activate $v($o,parent)
	}

	foreach co $v($o,children) {
		$object delete $co 0
	}
	if {$o == 0} {
		set v(0,children) {}
		$object _refresh 0
		return
	}
	# remove canvas objects
	$object.c delete $o.all

	set po $v($o,parent)
	# reclaim storage
	unset v($o,parent)
	unset v($o,children)
	unset v($o,tags)
	unset v($o,expanded)
	unset v($o,selected)
	unset v($o,h)

	if $master {
		set idx [lsearch $v($po,children) $o]
		set v($po,children)	[lreplace $v($po,children) $idx $idx]

		# Visable & expanded
		if {[$object isvisable $po]} {
			$object _refresh $po
		}
	}
	return ""
}
#
# Expand nodes immediately below $o
#
Classy::TreeView method expand {o} {
	private $object v
	set xy [$object.c coords $o.image]
	if {$xy == ""} {
		$object expand $v($o,parent)
	}
	if $v($o,expanded)	return

	# WARNING:	re-entrant
	# This callback is expected to invoke
	# our insert/delete methods
	$object _callback $o expand 1

	set v($o,expanded)	1
	foreach co $v($o,children) {
		$object _drawNode $co
	}
	$object _refresh $o

	$object see $o

	return $v($o,children)
}
Classy::TreeView method find {o fld val {defval ""}} {
	private $object v
	foreach co $v($o,children) {
		if {[string compare $val [structlget $v($co) $fld $defval]]==0} {
			return $co
		}
	}
	return -1
}
Classy::TreeView method get {o {option ""} {defval "!@#%"}} {
	private $object v
	if {$option == ""} {
		return $v($o)
	} elseif {[string compare $defval "!@#%"]==0} {
		return [structlget $v($o) $option]
	} else {
		if {[catch {structlget $v($o) $option} ret]} {
			set ret $defval
		}
		return $ret
	}
}
Classy::TreeView method isdesendant {o p} {
	private $object v
	if {$o == ""} {
		return 0
	}
	if {[lsearch $v($o,tags) $p.all]!=-1} {
		return 1
	} else {
		return 0
	}
}
Classy::TreeView method isvisable {o} {
	private $object v
	set po $v($o,parent)
	if {$o == 0 || \
		($v($po,expanded) && [$object.c coords $po.image] != "")} {
		return 1
	} else {
		return 0
	}
}
Classy::TreeView method isexpanded {o} {
	private $object v
	return $v($o,expanded)
}
#
# Create a new node, as a child of $po
#
Classy::TreeView method insert {o idx args} {
	private $object uid v
	set po $o
	set o [incr uid]

	set v($po,children)	[linsert $v($po,children) $idx $o]
	$object _newNode $po $o $args

	return $o
}
Classy::TreeView method parent {o} {
	private $object v
	return $v($o,parent)
}
Classy::TreeView method path {o {sep /}} {
	private $object v
	set name [structlget $v($o) name]
	set po $v($o,parent)

	if {$po == $o} {
		return ""
	} else {
		set path [path $po $sep]
		if {$path == ""} {
			return $name
		} else {
			return "$path$sep$name"
		}
	}
}
Classy::TreeView method put {o args} {
	private $object v
	set v($o) [eval [list structlset $v($o)] $args]
	set v($o) [structlset $v($o) image [Classy::geticon [structlget $v($o) image]]]
	$object _refreshNode $o
}
Classy::TreeView method see {o} {
	private $object v
	foreach val [$object.c bbox all] var {x0 y0 x1 y1} {
		set $var $val
	}
	foreach val [$object.c bbox $o.all] var {cx0 cy0 cx1 cy1} {
		set $var $val
	}
	set rw [winfo width $object.c]
	set rh [winfo height $object.c]

	$object _see yview $rh $y0 $y1 $cy0 $cy1
	$object _see xview $rw $x0 $x1 $cx0 $cx1
}
Classy::TreeView method unexpand {o} {
	private $object selection v options
	if !$v($o,expanded)	return

	if {[$object isdesendant $selection $o]} {
		$object activate $o
	}
	# WARNING:	re-entrant
	# This callback is expected to invoke
	# our insert/delete methods
	$object _callback $o expand 0

	set v($o,expanded)	0
	set v($o,h)			$options(-pady)
	foreach co $v($o,children) {
		$object.c delete $co.all
	}
	$object _refreshNode $o

	foreach val [$object.c coords $o.image] var {xc yc} {
		set $var $val
	}
	$object.c coords $o.vline $xc $yc $xc $yc

	$object _refresh $v($o,parent)

	$object see $o
}
#
# Internal Routines
#
Classy::TreeView method _refreshNode {o} {
	private $object v options
	set name [structlget $v($o) name]
	set image [structlget $v($o) image]

	$object.c itemconf $o.name -text $name
	$object.c itemconf $o.image -image $image

	if {$v($o,expanded)} {
		if {$v($o,children) != ""} {
			$object.c itemconf $o.ctrl -image [lindex $options(-controls) 1]
		} else {
			$object.c itemconf $o.ctrl -image ""
		}
	} else {
		$object.c itemconf $o.ctrl -image [lindex $options(-controls) 0]
	}

	if $v($o,selected) {
		catch {
			$object.c select from $o.name 0
			$object.c select to $o.name end
		}
	}
}
Classy::TreeView method _callback {o args} {
	private $object v options
	if {[string compare $options(-command) ""]==0} return

	$object.c conf -cursor watch
	if [catch [concat $options(-command) $o $args] ret] {
		global errorInfo
		puts stderr "Background error: $errorInfo"
	}
	$object.c conf -cursor {}
}
Classy::TreeView method _see {view size t0 t1 c0 c1} {
	private $object v
	foreach val [$object.c $view] var {pv0 pv1} {
		set $var $val
	}
	set dt	[expr double($t1 - $t0)]
	set pc0	[expr ($c0 - $t0)/$dt]
	set pc1	[expr ($c1 - $t0)/$dt]

	if {$dt < $size} {
		# Display area is smaller than window
		$object.c $view moveto 0.0
	} elseif {$pc0 > $pv0 && $pc1 < $pv1} {
		# donothing - fits w/o scrolling
	} elseif {($pc1 - $pc0) > ($pv1 - $pv0)} {
		# Larger than window
		$object.c $view moveto $pc0
	} else {
		$object.c $view moveto [expr $pv0 + ($pc1 - $pv1)] 
	}
}
#
# Refresh - reposition children to "correct" x,y locations
#
# WARNING:	only call for expanded nodes.
#
Classy::TreeView method _refresh {o} {
	private $object v options
	if {$o == 0} {
		set xc	[expr $options(-padx)/2]
		set yc	[expr $options(-pady)/2]

		set xy	[$object.c coords $o.image]
		set xc1	[lindex $xy 0]
		set yc1	[lindex $xy 1]
		if {$xc != $xc1 || $yc != $yc1} {
			$object.c move $o.all [expr $xc - $xc1] [expr $yc - $yc1]
		}
	} else {
		set xy	[$object.c coords $o.image]
		set xc	[lindex $xy 0]
		set yc	[lindex $xy 1]
	}
	set h0	$options(-pady)
	set x0	[expr $xc + $options(-padx)]
	set y0	$yc
	if $v($o,expanded) {
		foreach co $v($o,children) {
			set y0	[expr $y0 + $h0]
			set xy	[$object.c coords $co.image]
			set xc1	[lindex $xy 0]
			set yc1	[lindex $xy 1]

			# do a delta-move to correct location
			$object.c move $co.all [expr $x0 - $xc1] [expr $y0 - $yc1]
#tclLog "move $co -> $x0, $y0"

			set h0 $v($co,h)
		}
	}
	$object _refreshNode $o

	$object.c coords $o.vline $xc $yc $xc $y0
	set v($o,h)		[expr ($y0 - $yc) + $h0]

	if {$o == 0} {
		$object.c conf -scrollregion [$object.c bbox all]
	} else {
		$object _refresh $v($o,parent)
	}
}
#
# Design Philosophy
#
# 3 main types of change:
#	a.	visable structural change
#		i.	nodes added
#		ii.	nodes removed
#		iii.	nodes (un)expanded
#	b.	visable non-structural change
#		i.	image/name changed
#		ii.	control changed (plus/minus etc.)
#	c.	non-visable change - i.e. unexpanded nodes
#
# Responses:
#	a.	i.	defered
#		ii.	defered
#		iii.	inline
#	b.	inline (direct -> screen)
#	c.	inline
Classy::TreeView method _newNode {po o data} {
	private $object v
	if {[catch {structlget $data name} name]} {
		set name node$o
	}
	if {[catch {structlget $data image} image]} {
		set image [structlget $v($po) image]
		regsub -- {-selected$} $image {} image
	}
	# Ensure image is loaded/cached
	set image [Classy::geticon $image]

	set v($o,parent)	$po
	set v($o,children)	{}
	if {[info exists v($po,tags)]} {
		set v($o,tags)	$v($po,tags)
		lappend v($o,tags)	$po.all
	} else {
		set v($o,tags)	{}
	}
	set v($o,expanded)	0
	set v($o,selected)	0
	set v($o,h)			-1

	set v($o)	[structlset $data name $name image $image]

	# Visable & expanded
	if {[$object isvisable $o]} {
		# draw it "off screen"
		# the refresh to move it to correct location 		
		$object _drawNode $o
	
		$object _refresh $po
	}
	return $o
}
#
# drawNode - create canvas items for node,
#	- by default far off screen, as refresh will reposition
#	them correctly.
#
Classy::TreeView method _drawNode {o {xc -1000} {yc -1000}} {
	private $object v options
	if {$o == 0 && $options(-hide)} {
		set x	$xc
		set y	$yc
	} else {
		set x	[expr $xc - $options(-padx)]
		set y	$yc
		$object.c create image $x $y \
				-anchor c \
				-tag [concat $o.all $o.ctrl ctrl $v($o,tags)]
		$object.c create line $x $y $xc $yc \
				-fill grey \
				-tag [concat $o.all $o.hline $v($o,tags)]
		$object.c lower $o.hline
	}
	$object.c create image $xc $yc \
			-anchor c -image [structlget $v($o) image] \
			-tag [concat $o.all $o.image folder $v($o,tags)]
	$object.c create text [expr $xc + (0.75 * $options(-padx))] $yc \
			-anchor w \
			-font {{MS Sans Serif} 8} -text [structlget $v($o) name] \
			-tag [concat $o.all $o.name folder $v($o,tags)]
	$object.c create line $xc $yc $xc $yc \
			-fill grey \
			-tags [concat $o.all $o.vline $v($o,tags)]
	$object.c lower $o.vline

	# (un)map children
	set y0	$yc
	set h0	$options(-pady)
	if $v($o,expanded) {
		foreach co $v($o,children) {
			set y0	[expr $y0 + $h0]
			set h0	[$object _drawNode $co [expr $xc + $options(-padx)] $y0]
		}
		$object.c coords $o.vline $xc $yc $xc $y0
	}
	$object _refreshNode $o

	set h0	[expr ($y0 - $yc) + $h0]
	return [set v($o,h) $h0]
}
#
# Import and Export
#
Classy::TreeView method export {o} {
	private $object v
	set data {}
	lappend data [concat [list node $v($o,parent) $o] $v($o)]
	foreach co $v($o,children) {
		lvarcat data [$object export $co]
	}
	return $data
}
Classy::TreeView method import {o data} {
	private $object v
	set root [lindex $data 0]
	set map([lindex $root 2]) $o
	eval put $o [lrange $root 3 end]

	set n 1
	foreach node [lrange $data 1 end] {
		set po [lindex $node 1]
		set co [lindex $node 2]

		set ro [eval $object add $map($po) [lrange $node 3 end]]
		set map($co) $ro
		incr n
	}
	$object _refresh $o
	return $n
}
