#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::TreeWidget
# ----------------------------------------------------------------------
#doc TreeWidget title {
#TreeWidget
#} index {
# New widgets
#} shortdescr {
# a tree widget
#} descr {
# subclass of <a href="../basic/widget.html">Widget</a>
# The tree widget is a canvas widget with an associated <a href="../widget/Tree.html">Tree 
# widget</a>.
#}
#doc {TreeWidget options} h2 {
#	TreeWidget specific options
#}
#doc {TreeWidget command} h2 {
#	TreeWidget specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::TreeWidget {} {}
proc TreeWidget {} {}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::TreeWidget
Classy::export TreeWidget {}

bind Classy::TreeWidget <Configure> {%W redraw}
bind Classy::TreeWidget <<Action>> {%W _action %x %y}
bind Classy::TreeWidget <<MExecute>> {%W _execute %x %y}

Classy::TreeWidget classmethod init {args} {
	# REM Create object
	# -----------------
	super init
	canvas $object.c -xscrollcommand [list $object.hbar set] -yscrollcommand [list $object.vbar set]
	::class::rebind $object.c $object
	::class::refocus $object $object.c
	scrollbar $object.vbar -command [list $object.c yview] -orient vertical
	scrollbar $object.hbar -command [list $object.c xview] -orient horizontal
	Classy::Tree $object.tree
	$object.tree configure -canvas $object.c
	grid $object.c $object.vbar -row 0 -sticky nwse
	grid columnconfigure $object 0 -weight 1
	grid columnconfigure $object 1 -weight 0
	grid rowconfigure $object 0 -weight 1
	grid rowconfigure $object 1 -weight 0

	# REM Create bindings
	# -------------------

	# REM Initialise variables
	# ------------------------

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

Classy::TreeWidget component canvas {$object.c}

# ------------------------------------------------------------------
#  Destroy
# ------------------------------------------------------------------

Classy::TreeWidget method destroy {} {
	$object.tree destroy
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#Classy::TreeWidget chainoptions {$object.c}

foreach option {
	background cursor height highlightbackground highlightcolor highlightthickness
	insertbackground insertborderwidth insertofftime insertontime inertwidth
	offset relief selectborderwidth selectforeground selectbackground
	state takefocus width
} {
	Classy::TreeWidget chainoption -$option {$object.c} -$option
}

Classy::TreeWidget addoption -foreground {foreground Foreground {}} {
	if {"$value" == ""} {
		set col [Classy::realcolor [Classy::optionget $object.c foreground Foreground Foreground]]
	} else {
		set col $value
	}
	$object.tree configure -foreground $col
}

Classy::TreeWidget addoption -rootimage {rootImage RootImage {}} {
	$object.tree configure -rootimage $value
}
Classy::TreeWidget addoption -roottext {rootText RootText {}} {
	$object.tree configure -roottext $value
}
foreach {option def} {font {} startx 10 starty 10 padx 10 pady 2 padtext 4} {
	Classy::TreeWidget addoption -$option [list $option [string toupper [string index $option 0]][string range $option 1 end] $def] \
		"\$object.tree configure -$option \$value"
}

Classy::TreeWidget addoption -opencommand {openCommand OpenCommand {}} {
}

Classy::TreeWidget addoption -closecommand {closeCommand CloseCommand {}} {
}

Classy::TreeWidget addoption -endnodecommand {endnodeCommand EndnodeCommand {}} {
}

Classy::TreeWidget addoption -executecommand {executeCommand ExecuteCommand {}} {
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::TreeWidget chainallmethods {$object.c} canvas
Classy::TreeWidget chainallmethods {$object.tree} Classy::Tree

Classy::TreeWidget method redraw {} {
	$object.tree _redraw
	$object _handlebars
}

Classy::TreeWidget method _handlebars {} {
	update idletasks
	set bbox [$object.c bbox all]
	set w [lindex $bbox 2]
	set h [lindex $bbox 3]
	if {$w > [winfo width $object.c]} {
		grid $object.hbar -row 1 -column 0 -sticky we
	} else {
		grid forget $object.hbar
	}
	if {$h > [winfo height $object.c]} {
		grid $object.vbar -row 0 -column 1 -sticky ns
	} else {
		grid forget $object.vbar
	}
	$object.c configure -scrollregion [list 0 0 $w $h]
}

Classy::TreeWidget method _action {x y} {
	private $object options
	set node [$object.tree node $x $y]
	if {"$node" == ""} {
		if {"$options(-endnodecommand)" == ""} return
		uplevel #0 $options(-endnodecommand) [list $node]
		return
	}
	switch [$object.tree type $node] {
		end {
			if {"$options(-endnodecommand)" == ""} return
			uplevel #0 $options(-endnodecommand) [list $node]
		}
		open {
			if {"$options(-closecommand)" != ""} {
				uplevel #0 $options(-closecommand) [list $node]
			}
			# $object clearnode $node
		}
		closed {
			if {"$options(-opencommand)" == ""} return
			uplevel #0 $options(-opencommand) [list $node]
		}
	}
	$object _handlebars
}

Classy::TreeWidget method _execute {x y} {
	private $object options
	set node [$object.tree node $x $y]
	if {"$node" == ""} return
	if {"$options(-executecommand)" == ""} return
	uplevel #0 $options(-executecommand) [list $node]
	$object _handlebars
}


