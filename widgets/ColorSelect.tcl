#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# ColorSelect
# ----------------------------------------------------------------------
#doc ColorSelect title {
#ColorSelect
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# A colorselector where the user can select a color using
# different methods: sample, HSV, RGB or colorname
#}
#doc {ColorSelect options} h2 {
#	ColorSelect specific options
#} descr {
#}
#doc {ColorSelect command} h2 {
#	ColorSelect specific methods
#} descr {
#}
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

#doc {ColorSelect options -label} option {-label ? ?} descr {
# text on the label of the colorselector
#}
Classy::ColorSelect chainoption -label {$object.chooser} -label

#doc {ColorSelect options -command} option {-command command Command} descr {
# command to be executed when the color is changed
#}
Classy::ColorSelect addoption -command {command Command {}}


# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {ColorSelect command set} cmd {
#pathname set value
#} descr {
# set current color to $value
#}
Classy::ColorSelect method set {value} {
	$object.entry set $value
	$object.rgb set $value;
	$object.hsv set $value;
}

#doc {ColorSelect command get} cmd {
#pathname get 
#} descr {
# set current color
#}
Classy::ColorSelect method get {} {
	return [$object.entry get]
}

#doc {ColorSelect command select} cmd {
#pathname select type
#} descr {
# set the current type of selector
#}
Classy::ColorSelect method select {type} {
	$object.chooser select $type
}

Classy::ColorSelect method _update {from} {
	uplevel #0 [getprivate $object options(-command)]
}
