#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::ProgressDialog
# ----------------------------------------------------------------------
#doc ProgressDialog title {
#ProgressDialog
#} index {
# Dialogs
#} shortdescr {
# show progress of some proces in a dialog
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
# creates a dialog in which the ProgressDialog of some action will be displayed.
# The ProgressDialog will be displayed as the fraction of ticks passed (
# ticks are passed by invoking the incr method), compared to the number 
# of ticks to go (-ticks options). The display will be updated every
# -step ticks
#}
#doc {ProgressDialog options} h2 {
#	ProgressDialog specific options
#}
#doc {ProgressDialog command} h2 {
#	ProgressDialog specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::ProgressDialog {} {}
proc ProgressDialog {} {}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass Classy::ProgressDialog
Classy::export ProgressDialog {}

Classy::ProgressDialog classmethod init {args} {
	super -title "ProgressDialog"
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

Classy::ProgressDialog component message {$object.options.message}
# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {ProgressDialog options -ticks} option {-ticks ticks Ticks} descr {
#}
Classy::ProgressDialog addoption -ticks {ticks Ticks 100}

#doc {ProgressDialog options -step} option {-step step Step} descr {
#}
Classy::ProgressDialog addoption -step {step Step 1}

#doc {ProgressDialog options -width} option {-width width Width} descr {
#}
Classy::ProgressDialog addoption -width {width Width 200}

#doc {ProgressDialog options -fg} option {-fg ? ?} descr {
#}
Classy::ProgressDialog chainoption -fg {$object.options.frame.prog} -bg

#doc {ProgressDialog options -message} option {-message ? ?} descr {
#}
Classy::ProgressDialog chainoption -message {$object.options.message} -text

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {ProgressDialog command incr} cmd {
#pathname incr ?value?
#} descr {
#}
Classy::ProgressDialog method incr {{value 1}} {
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

#doc {ProgressDialog command set} cmd {
#pathname set value
#} descr {
#}
Classy::ProgressDialog method set {value} {
	set ticks [getprivate $object options(-ticks)]
	private $object current
	set current $value
	if {$value<0} {set value 0}
	if {$value>$ticks} {set value $ticks}
	set ratio [expr double($current)/$ticks]
	$object.options.percent configure -text "[expr int($ratio*100)]%"
	$object.options.frame.prog configure -width [expr int($ratio*[winfo width $object.options.frame])]
}

#doc {ProgressDialog command get} cmd {
#pathname get 
#} descr {
#}
Classy::ProgressDialog method get {} {
	private $object current
	return $current
}
