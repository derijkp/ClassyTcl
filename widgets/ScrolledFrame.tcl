#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::ScrolledFrame
# ----------------------------------------------------------------------
#doc ScrolledFrame title {
#ScrolledFrame
#} index {
# Tk improvements
#} shortdescr {
# frame with auto scroll bars
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# creates a view frame in which a component frame is displayed.
# If the component frame is larger than the view frame, scrollbars
# are automatically added.
# The component frame is available as component frame
#}
#doc {ScrolledFrame command} h2 {
#	ScrolledFrame specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::ScrolledFrame {} {}
proc ScrolledFrame {} {}
}

bind Classy::ScrolledFrame <Configure> {Classy::todo %W redraw}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------
Widget subclass Classy::ScrolledFrame
Classy::export ScrolledFrame {}

Classy::ScrolledFrame classmethod init {args} {
	# REM Create object
	# -----------------
	super init
	frame $object.view
	frame $object.view.frame
	::class::rebind $object.view.frame $object
	::class::refocus $object $object.view.frame
	grid $object.view -column 0 -row 0 -sticky nwse
	grid $object.view.frame -column 0 -row 0 -sticky nwse
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	Classy::todo $object redraw
	return $object.view.frame
}
Classy::ScrolledFrame component frame {$object.view.frame}

# ------------------------------------------------------------------
#  Widget destroy
# ------------------------------------------------------------------
Classy::ScrolledFrame method destroy {} {
	::class::rebind $object.view.frame {}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {ScrolledFrame command redraw} cmd {
#pathname redraw 
#} descr {
#}
Classy::ScrolledFrame method redraw {} {
	private $object options x y
	set w $object.view.frame
	update idletasks
	set reqw [winfo reqwidth $w]
	set reqh [winfo reqheight $w]
	set width [winfo width $object]
	set height [winfo height $object]
	if {$reqw > $width} {
		if ![winfo exists $object.hbar] {
			scrollbar $object.hbar -command [list $object xview] -orient horizontal
		}
		set x 0
		grid $object.hbar -column 0 -row 1 -sticky we
		place $w -width $reqw
	} else {
		if [winfo exists $object.hbar] {destroy $object.hbar}
		$object configure -width $reqw
		place $w -x 0 -width [winfo width $object.view]
	}
	if {$reqh > $height} {
		if ![winfo exists $object.vbar] {
			scrollbar $object.vbar -command [list $object yview] -orient vertical
		}
		set y 0
		grid $object.vbar -column 1 -row 0 -sticky ns
		place $w -height $reqh
	} else {
		if [winfo exists $object.vbar] {destroy $object.vbar}
		$object configure -height $reqh
		place $w -y 0 -height [winfo height $object]
	}
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 0 -weight 1
	grid columnconfigure $object.view 0 -weight 1
	grid rowconfigure $object.view 0 -weight 1
	bind Classy::ScrolledFrame <Configure> {}
	update idletasks
	bind Classy::ScrolledFrame <Configure> {Classy::todo %W redraw}
	$object _sethbar
	$object _setvbar
}

#doc {ScrolledFrame command xview} cmd {
#pathname xview args
#} descr {
#}
Classy::ScrolledFrame method xview {args} {
	if ![winfo exists $object.hbar] return
	private $object options x
	set w $object.view.frame
	set vieww [winfo width $object.view]
	set realw [winfo width $w]
	set first [lindex $args 0]
	set max [expr $realw-$vieww]
	switch $first {
		"" {
			return [list [expr double($x)/$realw] [expr ($x+double($vieww))/$realw]]
		}
		moveto {
			set fraction [lindex $args 1]
			set x [expr $fraction*$realw]
		}
		scroll {
			set number [lindex $args 1]
			set what [lindex $args 2]
			if {"$what"=="pages"} {
				set x [expr $x+$number*$vieww]
			} else {
				set x [expr $x+$number*8]
			}
		}
	}
	if {$x > $max} {set x $max}
	if {$x < 0} {set x 0}
	place $w -in $object.view -x -$x
	$object.hbar set [expr double($x)/$realw] [expr ($x+double($vieww))/$realw]
}


#doc {ScrolledFrame command yview} cmd {
#pathname yview args
#} descr {
#}
Classy::ScrolledFrame method yview {args} {
	if ![winfo exists $object.vbar] return
	private $object options y
	set w $object.view.frame
	set viewh [winfo height $object.view]
	set realh [winfo height $w]
	set first [lindex $args 0]
	set max [expr $realh-$viewh]
	switch $first {
		"" {
			return [list [expr double($y)/$realh] [expr ($y+double($viewh))/$realh]]
		}
		moveto {
			set fraction [lindex $args 1]
			set y [expr $fraction*$realh]
		}
		scroll {
			set number [lindex $args 1]
			set what [lindex $args 2]
			if {"$what"=="pages"} {
				set y [expr $y+$number*$viewh]
			} else {
				set y [expr $y+$number*8]
			}
		}
	}
	if {$y > $max} {set y $max}
	if {$y < 0} {set y 0}
	place $w -in $object.view -y -$y
	$object.vbar set [expr double($y)/$realh] [expr ($y+double($viewh))/$realh]
}

Classy::ScrolledFrame method _sethbar {args} {
	if ![winfo exists $object.hbar] return
	private $object options x
	set w $object.view.frame
	set realw [winfo reqwidth $w]
	set vieww [winfo width $object.view]
	$object.hbar set [expr $x/$realw] [expr ($x+double($vieww))/$realw]
}

Classy::ScrolledFrame method _setvbar {args} {
	if ![winfo exists $object.vbar] return
	private $object options y
	set w $object.view.frame
	set realh [winfo reqheight $w]
	set viewh [winfo height $object.view]
	$object.vbar set [expr -$y/$realh] [expr ($y+double($viewh))/$realh]
}

Classy::ScrolledFrame method _children {} {
	return [winfo children $object.view.frame]
}


