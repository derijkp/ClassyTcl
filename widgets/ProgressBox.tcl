#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::ProgressBox
# ----------------------------------------------------------------------
#doc ProgressBox title {
#ProgressBox
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
# creates a dialog in which the ProgressBox of some action will be displayed.
# The ProgressBox will be displayed as the fraction of ticks passed (
# ticks are passed by invoking the incr method), compared to the number 
# of ticks to go (-ticks options). The display will be updated every
# -step ticks
#}
#doc {ProgressBox options} h2 {
#	ProgressBox specific options
#}
#doc {ProgressBox command} h2 {
#	ProgressBox specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::ProgressBox {} {}
proc ProgressBox {} {}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass Classy::ProgressBox
Classy::export ProgressBox {}

Classy::ProgressBox classmethod init {args} {
	super -title "ProgressBox"
	message $object.options.message -text "Progress" -justify center
	frame $object.options.frame -relief sunken -height 20
	frame $object.options.frame.prog -relief raised -bg green -width 0 -height 20
	label $object.options.percent -text "0%"

	pack $object.options.message -fill x
	pack $object.options.frame -fill x
	pack $object.options.frame.prog -side left
	pack $object.options.percent -fill x

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

Classy::ProgressBox component message {$object.options.message}
# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {ProgressBox options -ticks} option {-ticks ticks Ticks} descr {
#}
Classy::ProgressBox addoption -ticks {ticks Ticks 100}

#doc {ProgressBox options -step} option {-step step Step} descr {
#}
Classy::ProgressBox addoption -step {step Step 1}

#doc {ProgressBox options -width} option {-width width Width} descr {
#}
Classy::ProgressBox addoption -width {width Width 200}

#doc {ProgressBox options -fg} option {-fg ? ?} descr {
#}
Classy::ProgressBox chainoption -fg {$object.options.frame.prog} -bg

#doc {ProgressBox options -message} option {-message ? ?} descr {
#}
Classy::ProgressBox chainoption -message {$object.options.message} -text

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {ProgressBox command incr} cmd {
#pathname incr ?value?
#} descr {
#}
Classy::ProgressBox method incr {{value 1}} {
	set step [getprivate $object options(-step)]
	set ticks [getprivate $object options(-ticks)]
	private $object current next
	incr current $value
	if {$current<$next} {return}
	incr next $step
	if {$value<0} {set value 0}
	if {$value>$ticks} {set value $ticks}
	set ratio [expr double($current)/$ticks]
	$object.options.percent configure -text "[expr int($ratio*100)]%"
	$object.options.frame.prog configure -width [expr int($ratio*[winfo width $object.options.frame])]
	update idletasks
}

#doc {ProgressBox command set} cmd {
#pathname set value
#} descr {
#}
Classy::ProgressBox method set {value} {
	set ticks [getprivate $object options(-ticks)]
	private $object current
	set current $value
	if {$value<0} {set value 0}
	if {$value>$ticks} {set value $ticks}
	set ratio [expr double($current)/$ticks]
	$object.options.percent configure -text "[expr int($ratio*100)]%"
	$object.options.frame.prog configure -width [expr int($ratio*[winfo width $object.options.frame])]
}

#doc {ProgressBox command get} cmd {
#pathname get 
#} descr {
#}
Classy::ProgressBox method get {} {
	private $object current
	return $current
}
