#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# NoteBook
# ----------------------------------------------------------------------
#doc NoteBook title {
#NoteBook
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# create a notebook widget. A notebook has several frames which can be 
# selected by clicking on an appropriate "tab"
#}
#doc {NoteBook options} h2 {
#	NoteBook specific options
#} descr {
#}
#doc {NoteBook command} h2 {
#	NoteBook specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::NoteBook {} {}
proc NoteBook {} {}
}

option add *Classy::NoteBook.Background [option get . darkBackground DarkBackground] widgetDefault
#option add *Classy::NoteBook.book.borderWidth 2 widgetDefault
#option add *Classy::NoteBook.Button.borderWidth 2 widgetDefault
option add *Classy::NoteBook.borderWidth 0 widgetDefault
#option add *Classy::NoteBook.highlightthickness 0 widgetDefault

bind Classy::NoteBook <Configure> {%W redraw}
# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::NoteBook
Classy::export NoteBook {}

Classy::NoteBook classmethod init {args} {
	# REM Create object
	# -----------------
	set w [super]
	label $object.label -text "" -width 0 -relief flat -bg [$w cget -bg]
	frame $object.cover_ -relief flat
	frame $object.book -relief raised -bd [$object.label cget -bd]
	bind $object.book <Configure> [list $object propagate]

	# REM set variables
	# -----------------
	setprivate $object num 0
	setprivate $object current {}

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	Classy::todo $object redraw
}

Classy::NoteBook component book {$object.book}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {NoteBook options -label} option {-label label Label} descr {
#}
Classy::NoteBook addoption -label {label Label {}} {
	$object.label configure -text $value
	Classy::todo $object redraw
	return $value
}


#doc {NoteBook options -side} option {-side side Side} descr {
#}
Classy::NoteBook addoption -side {side Side top} {
	Classy::todo $object redraw
	return $value
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

## ---- object manage label window options ----
# The notebook will manage the given window by the name label.
## option -command command
# The command is executed everytime when the label is being selected. 
# If the command returns 0, the new label will not be selected.

#doc {NoteBook command manage} cmd {
#pathname manage label w ?option? ?value? ?option value ...?
#} descr {
#}
Classy::NoteBook method manage {label w args} {
	private $object managed_options widget button num cmd
	set pos [lsearch $args -command] 
	if {$pos != -1} {
		set cmd($label) [lindex $args [expr $pos+1]]
		set args [lreplace $args $pos [expr $pos+1]]
	}
	if {"$args" == ""} {
		set args {-sticky nwse}
	}
	button $object.tab$num -text $label -highlightthickness 0\
		-command [list $object select $label]
	$object.tab$num configure -activebackground [$object.tab$num cget -background]
	set widget($label) $w
	set button($label) $num
	set managed_options($label) $args
	incr num
	Classy::todo $object redraw
	return $w
}

#doc {NoteBook command select} cmd {
#pathname select label
#} descr {
# This method selects the managed window that is managed by the notebook
# under the name label.
#}
Classy::NoteBook method select {label} {
	private $object widget button managed_options cmd current
	if [info exists cmd($label)] {
		if {[uplevel #0 $cmd($label)] == 0} return
	}
	set current $label
	catch {eval pack forget [pack slaves $object.book]}
	catch {eval grid forget [grid slaves $object.book]}
	eval grid $widget($label) -in $object.book -row 0 -col 0 $managed_options($label)
	grid columnconfigure $object.book 0 -weight 1
	grid rowconfigure $object.book 0 -weight 1
	Classy::todo $object redraw
}

#doc {NoteBook command propagate} cmd {
#pathname propagate ?state?
#} descr {
#}
Classy::NoteBook method propagate {{state {}}} {
	if {"$state" == ""} {
		set side [getprivate $object options(-side)]
		set list ""
		foreach item [lsort -dict [winfo children $object]] {
			if [regexp "^$object.tab\[0-9\]+\$" $item] {
				lappend list $item
			}
		}
		if {"$side" == "top"} {
			set bd [$object.book cget -bd]
			set reqheight [winfo reqheight $object.book]
			set y 0
			foreach w $list {
				set ny [winfo reqheight $w]
				if {$ny > $y} {
					set y $ny
				}
			}
			set reqheight [expr $reqheight + 2*$bd + 1 + $y]
			set reqwidth [expr [winfo reqwidth $object.book] + 2*$bd]
		} else {
			set bd [$object.book cget -bd]
			set reqwidth [winfo reqwidth $object.book]
			set x 0
			foreach w $list {
				set nx [winfo reqwidth $w]
				if {$nx > $x} {
					set x $nx
				}
			}
			set reqwidth [expr $reqwidth + 2*$bd + 1 + $x]
			set reqheight [expr [winfo reqheight $object.book] + 2*$bd]
		}
		[Classy::window $object] configure -width $reqwidth -height $reqheight
	} else {
		grid propagate $object.book $state
	}
}

#doc {NoteBook command redraw} cmd {
#pathname redraw 
#} descr {
#}
Classy::NoteBook method redraw {} {
	private $object current button
	set side [getprivate $object options(-side)]
	set list ""
	foreach item [lsort -dict [winfo children $object]] {
		if [regexp "^$object.tab\[0-9\]+\$" $item] {
			lappend list $item
		}
	}
	place $object.label -x 0 -y 1
	if {"$side" == "top"} {
		set y [expr [winfo reqheight $object.label] - [$object.label cget -bd]]
		set x [winfo reqwidth $object.label]
		if {"$current" != ""} {
			set cw $object.tab$button($current)
		} else {
			set cw ""
		}
		foreach w $list {
			place $w -x $x -y 1 -width [winfo reqwidth $w]
			$w configure -bg [$object cget -bg]
			if {"$cw" == "$w"} {
				set cx $x
			}
			set x [expr $x + [winfo reqwidth $w]+2]
			set ny [expr [winfo reqheight $w] - [$w cget -bd]+1]
			if {$ny > $y} {
				set y $ny
			}
		}
	
		set bd [$object.book cget -bd]
		place $object.book -x 0 -y $y \
			-width [expr [winfo width $object]-2*$bd] \
			-height [expr [winfo height $object] - $y - 2*$bd]
		raise $object.book
		if {"$current" != ""} {
			raise $cw
			$cw configure -bg [$object.book cget -bg]
			set bd [$cw cget -bd]
			set x [expr $cx + $bd]
			set width [expr [winfo reqwidth $cw] - 2*$bd]
			place $object.cover_ -x $x -y $y -width $width -height $bd
			raise $object.cover_
		}
	} else {
		set label [$object.label cget -text]
		if {"$label" != ""} {
			set y [winfo reqheight $object.label]
			set width [winfo reqwidth $object.label]
			set bd [$object.label cget -bd]
		} else {
			set y 0
			set width 0
			set bd 0
		}
		foreach w $list {
			set nwidth [winfo reqwidth $w]
			if {$nwidth > $width} {
				set width $nwidth
			}
			set nbd [$w cget -bd]
			if {$nbd > $bd} {
				set bd $nbd
			}
		}
		if {"$current" != ""} {
			set cw $object.tab$button($current)
		} else {
			set cw ""
		}
		foreach w $list {
			place $w -x 1 -y $y -width $width
			if {"$cw" == "$w"} {
				set cy $y
			}
			set y [expr $y + [winfo reqheight $w]+2]
		}
	
		set bd [$object.book cget -bd]
		set x [expr $width - $bd]
		place $object.book -x $x -y 0 \
			-width [expr [winfo width $object] - $x - 2*$bd] \
			-height [expr [winfo height $object] - 2*$bd]
		raise $object.book
		if {"$current" != ""} {
			raise $cw
			set bd [$cw cget -bd]
			set y [expr $cy + $bd]
			set height [expr [winfo height $cw] - 2*$bd]
			place $object.cover_ -x $x -y $y -width $bd -height $height
			raise $object.cover_
		}
	}
}

Classy::NoteBook method get {} {
	private $object current
	return $current
}
