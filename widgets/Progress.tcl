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
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Progress {} {}
proc Progress {} {}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Progress
Classy::export Progress {}

Classy::Progress classmethod init {args} {
	super init
	frame $object.frame -relief sunken -height 20
	frame $object.frame.prog -relief raised -bg green -width 0 -height 20
	label $object.frame.percent -text "0%" -anchor c -justify c

	pack $object.frame -fill x
	pack $object.frame.prog -side left
	place $object.frame.percent -relx 0.5 -rely 0.5 -anchor c

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

#doc {Progress options -ticks} option {-ticks ticks Ticks} descr {
#}
Classy::Progress addoption -ticks {ticks Ticks 100}

#doc {Progress options -step} option {-step step Step} descr {
#}
Classy::Progress addoption -step {step Step 1}

#doc {Progress options -width} option {-width width Width} descr {
#}
Classy::Progress addoption -width {width Width 200}

#doc {Progress options -fg} option {-fg ? ?} descr {
#}
Classy::Progress chainoption -fg {$object.frame.prog} -bg

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {Progress command incr} cmd {
#pathname incr ?value?
#} descr {
#}
Classy::Progress method incr {{value 1}} {
	set step [getprivate $object options(-step)]
	set ticks [getprivate $object options(-ticks)]
	private $object current next
	incr current $value
	if {$current<$next} {return}
	incr next $step
	if {$value<0} {set value 0}
	if {$value>$ticks} {set value $ticks}
	set ratio [expr double($current)/$ticks]
	$object.frame.percent configure -text "[expr int($ratio*100)]%"
	$object.frame.prog configure -width [expr int($ratio*[winfo width $object.frame])]
	update idletasks
}

#doc {Progress command set} cmd {
#pathname set value
#} descr {
#}
Classy::Progress method set {value} {
	set ticks [getprivate $object options(-ticks)]
	private $object current
	set current $value
	if {$value<0} {set value 0}
	if {$value>$ticks} {set value $ticks}
	set ratio [expr double($current)/$ticks]
	$object.frame.percent configure -text "[expr int($ratio*100)]%"
	$object.frame.prog configure -width [expr int($ratio*[winfo width $object.frame])]
}

#doc {Progress command get} cmd {
#pathname get 
#} descr {
#}
Classy::Progress method get {} {
	private $object current
	return $current
}


