#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::Progress
# ----------------------------------------------------------------------
#doc Progress title {
#Progress
#} index {
# New widgets
#} shortdescr {
# show progress of some process
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# creates a widget in which the progress of some action will be displayed.
# The progress will be displayed as the fraction of ticks passed (
# ticks are passed by invoking the incr method), compared to the number 
# of ticks to go (-ticks options). The display will be updated every
# -step ticks
#}
#doc {Progress options} h2 {
#	Progress specific options
#}
#doc {Progress command} h2 {
#	Progress specific methods
#}

bind Classy::Progress <Configure> {Classy::todo %W _redraw}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Progress

Classy::Progress method init {args} {
	private $object w
	set w [super init canvas]
	$w configure -width 100 -height 16 -relief sunken
	$w create rectangle 0 0 0 16 -fill green -tags bar
	$w create text 50 8 -text 0% -anchor c -tags percentage

	# REM Initialise variables and options
	# ------------------------------------
	private $object current next
	set current 0
	set next 0

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	update idletasks
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::Progress chainoptions {$object}

#doc {Progress options -ticks} option {-ticks ticks Ticks} descr {
#}
Classy::Progress addoption -ticks {ticks Ticks 100}

#doc {Progress options -step} option {-step step Step} descr {
#}
Classy::Progress addoption -step {step Step 1}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {Progress command incr} cmd {
#pathname incr ?value?
#} descr {
#}
Classy::Progress method incr {{value 1}} {
	private $object current next options
	set step $options(-step)
	incr current $value
	if {$current<$next} {return}
	incr next $step
	$object _redraw
	update idletasks
}

#doc {Progress command set} cmd {
#pathname set value
#} descr {
#}
Classy::Progress method set {value} {
	private $object current next options
	set step $options(-step)
	set current $value
	set next [expr {$value+$step}]
	$object _redraw
	update idletasks
}

#doc {Progress command get} cmd {
#pathname get 
#} descr {
#}
Classy::Progress method get {} {
	private $object current
	return $current
}

#doc {Progress command percentconfigure} cmd {
#pathname percentconfigure ?option? ?value? ...
#} descr {
# change the properties of the text displaying the percentage
#}
Classy::Progress method percentconfigure {args} {
	private $object w
	eval $w itemconfigure percentage $args
}

#doc {Progress command barconfigure} cmd {
#pathname barconfigure ?option? ?value? ...
#} descr {
# change the properties of the bar
#}
Classy::Progress method barconfigure {args} {
	private $object w
	eval $w itemconfigure bar $args
}

Classy::Progress method _redraw {} {
	private $object w current options
	set ticks $options(-ticks)
	if {$ticks == 0} {set ticks 1}
	if {$current<0} {set current 0}
	if {$current>$ticks} {set current $ticks}
	set ratio [expr double($current)/$ticks]
	set width [winfo width $object]
	set height [winfo height $object]
	$w coords bar 0 0 [expr {int($ratio*$width)}] $height
	$w coords percentage [expr {$width/2.0}] [expr {$height/2.0}]
	$w itemconfigure percentage -text "[expr int($ratio*100)]%"
}
