#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::ColorRGB
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::ColorRGB {} {}
proc ColorRGB {} {}
}
catch {Classy::ColorRGB destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::ColorRGB
Classy::export ColorRGB {}

Classy::ColorRGB classmethod init {args} {
	# REM Create object
	# -----------------
	super
	foreach color {red green blue} {
		frame $object.$color 
		pack $object.$color -fill y -side left
		label $object.$color.label -anchor c -relief flat\
			-text [string toupper [string index $color 0]][string range $color 1 end]
		pack $object.$color.label -side top
		scale $object.$color.val -orient vertical -from 255 -to 0 \
			-fg $color -relief flat
		pack $object.$color.val -fill y -expand yes -side bottom
	}

	# REM Create bindings
	# -------------------
	foreach color {red green blue} {
		$object.$color.val configure -command "$object _update"
	}

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::ColorRGB chainoptions {$object}

Classy::ColorRGB addoption -command {command Command {}}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::ColorRGB method set {value} {
	private $object nocmd
	set rgb [winfo rgb $object $value]
	set nocmd 1
	$object.red.val set [expr 0.00389105*[lindex $rgb 0]]
	$object.green.val set [expr 0.00389105*[lindex $rgb 1]]
	$object.blue.val set [expr 0.00389105*[lindex $rgb 2]]
	unset nocmd
	$object _update
	update idletasks
}

Classy::ColorRGB method get {} {
	return [format "#%02x%02x%02x" \
		[$object.red.val get] [$object.green.val get] [$object.blue.val get]]
}

Classy::ColorRGB method getRGB {} {
	return "[$object.red.val get] [$object.green.val get] [$object.blue.val get]"
}

Classy::ColorRGB method _update {args} {
	set color [$object get]
	$object.red.val configure -troughcolor $color
	$object.green.val configure -troughcolor $color
	$object.blue.val configure -troughcolor $color
	private $object nocmd
	if ![info exists nocmd] {
		eval [getprivate $object options(-command)]
	}
}
