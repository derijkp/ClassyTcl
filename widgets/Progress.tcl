#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::Progress
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Progress {} {}
proc Progress {} {}
}
catch {Classy::Progress destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass Classy::Progress
Classy::export Progress {}

Classy::Progress classmethod init {args} {
	super -title "Progress"
#	wm title $object "Progress"
#	wm resizable $object 0 0
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

Classy::Progress component message {$object.options.message}
# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::Progress addoption -ticks {ticks Ticks 100}
Classy::Progress addoption -step {step Step 1}
Classy::Progress addoption -width {width Width 200}
Classy::Progress chainoption -fg {$object.options.frame.prog} -bg
Classy::Progress chainoption -message {$object.options.message} -text

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#Classy::Progress chainallmethods {$object} toplevel

Classy::Progress method set {value} {
	set ticks [getprivate $object options(-ticks)]
	private $object current
	set current $value
	if {$value<0} {set value 0}
	if {$value>$ticks} {set value $ticks}
	set ratio [expr double($current)/$ticks]
	$object.options.percent configure -text "[expr int($ratio*100)]%"
	$object.options.frame.prog configure -width [expr int($ratio*[winfo width $object.options.frame])]
}

Classy::Progress method get {} {
	private $object current
	return $current
}

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
	$object.options.percent configure -text "[expr int($ratio*100)]%"
	$object.options.frame.prog configure -width [expr int($ratio*[winfo width $object.options.frame])]
	update idletasks
}
