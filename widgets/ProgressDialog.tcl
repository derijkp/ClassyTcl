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
# of ticks to go (-ticks options).
#}
#doc {ProgressDialog options} h2 {
#	ProgressDialog specific options
#}
#doc {ProgressDialog command} h2 {
#	ProgressDialog specific methods
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass Classy::ProgressDialog

Classy::ProgressDialog method init {args} {
	private $object clicks refresh
	super init -title "ProgressDialog"
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
	set clicks [clock clicks]
	set refresh [expr {50*$::Classy::clickspms}]
	update idletasks
}

Classy::ProgressDialog component message {$object.options.message}
# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {ProgressDialog options -ticks} option {-ticks ticks Ticks} descr {
#}
Classy::ProgressDialog addoption -ticks {ticks Ticks 100}

#doc {ProgressDialog options -width} option {-width width Width} descr {
#}
Classy::ProgressDialog addoption -width {width Width 200}

#doc {ProgressDialog options -fg} option {-fg ? ?} descr {
#}
Classy::ProgressDialog chainoption -fg {$object.options.frame.prog} -bg

#doc {ProgressDialog options -message} option {-message ? ?} descr {
#}
Classy::ProgressDialog chainoption -message {$object.options.message} -text

#doc {ProgressDialog options -refresh} option {-refresh refresh Refresh} descr {
#}
Classy::ProgressDialog addoption -refresh {refresh Refresh 50} {
	private $object refresh
	set refresh [expr {$value*$::Classy::clickspms}]
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {ProgressDialog command incr} cmd {
#pathname incr ?value?
#} descr {
#}
Classy::ProgressDialog method incr {{value 1}} {
	private $object current clicks
	incr current $value
	if {[clock clicks] < $clicks} return
	$object redraw
	update
	private $object refresh
	set clicks [expr {[clock clicks] + $refresh}]
}

#doc {ProgressDialog command set} cmd {
#pathname set value
#} descr {
#}
Classy::ProgressDialog method set {value} {
	private $object current
	set current $value
	$object redraw
	update
}

#doc {ProgressDialog command get} cmd {
#pathname get 
#} descr {
#}
Classy::ProgressDialog method get {} {
	private $object current
	return $current
}

#doc {Progress command redraw} cmd {
#pathname redraw
#} descr {
# redraw progress bar
#}
Classy::ProgressDialog method redraw {} {
	private $object w current options
	set ticks $options(-ticks)
	if {$ticks == 0} {set ticks 1}
	if {$current<0} {set current 0}
	if {$current>$ticks} {set current $ticks}
	set ratio [expr double($current)/$ticks]
	$object.options.percent configure -text "[expr int($ratio*100)]%"
	$object.options.frame.prog configure -width [expr int($ratio*[winfo width $object.options.frame])]
	update idletasks
}
