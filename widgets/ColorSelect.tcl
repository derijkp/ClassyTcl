#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# ColorSelect
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::ColorSelect {} {}
proc ColorSelect {} {}
}
catch {Classy::ColorSelect destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::ColorSelect
Classy::export ColorSelect {}

Classy::ColorSelect classmethod init {args} {
	# REM Create object
	# -----------------
	super
	Classy::ColorEntry $object.entry
	Classy::NoteBook $object.chooser
	Classy::ColorSample $object.sample
	Classy::ColorRGB $object.rgb
	Classy::ColorHSV $object.hsv

	$object.chooser manage Sample $object.sample -sticky nwse
	$object.chooser manage RGB $object.rgb  -sticky nwse
	$object.chooser manage HSV $object.hsv -sticky nwse
	$object.chooser select Sample

	pack $object.entry -fill x -side bottom
	pack $object.chooser -fill both -expand yes -side top
	set w [winfo reqwidth $object]
	::$object.chooser configure -width 150 -height 150
	::$object.chooser propagate off

	# REM Initialise variables
	# ------------------------
	private $object var
	set var {}

	# REM Create bindings
	# -------------------
	$object.entry configure -command [varsubst {object} {
		set value [$object.entry get];
		$object.rgb set $value;
		$object.hsv set $value;
		$object _update entry
	}]
	$object.sample configure -command [varsubst {object} {
		set value [$object.sample get];
		$object.entry set $value;
		$object.hsv set $value;
		$object.rgb set $value;
		$object _update sample
	}]
	$object.rgb configure -command [varsubst {object} {
		set value [$object.rgb get];
		$object.entry set $value;
		$object.hsv set $value;
		$object _update rgb
	}]
	$object.hsv configure -command [varsubst {object} {
		set value [$object.hsv get];
		$object.entry set $value;
		$object.rgb set $value;
		$object _update hsv
	}]

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::ColorSelect chainoptions {$object}
Classy::ColorSelect chainoption -label {$object.chooser} -label
Classy::ColorSelect addoption -command {command Command {}}


# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::ColorSelect method set {value} {
	$object.entry set $value
	$object.rgb set $value;
	$object.hsv set $value;
}

Classy::ColorSelect method get {} {
	return [$object.entry get]
}

Classy::ColorSelect method select {type} {
	$object.chooser select $type
}

Classy::ColorSelect method _update {from} {
	uplevel #0 [getprivate $object options(-command)]
}


