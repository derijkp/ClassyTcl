#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::ColorEntry
# ----------------------------------------------------------------------
#doc ColorEntry title {
#ColorEntry
#} descr {
# subclass of <a href="Entry.html">Entry</a><br>
# has the same options and methods as <a href="Entry.html">Entry</a>,
# but has a display to show the color in the entry when the Enter key
# is pressed.
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::ColorEntry {} {}
proc ColorEntry {} {}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Entry subclass Classy::ColorEntry
Classy::export ColorEntry {}

Classy::ColorEntry classmethod init {args} {
	super
	frame $object.sample -relief raised -width 25 -borderwidth 2
	pack $object.sample -side left -expand yes -fill both

#	bind $object <KeyRelease-Return> [varsubst object {}]

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::ColorEntry method set {val} {
	$object.entry delete 0 end
	$object.entry insert 0 $val
	$object.sample configure -background $val
}

Classy::ColorEntry method command {} {
	set command [getprivate $object options(-command)]
	$object.sample configure -background [$object get]
	if {"$command"==""} {
		return 0
	}
	uplevel #0 $command
	return 1
}	

