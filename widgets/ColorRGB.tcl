#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::ColorRGB
# ----------------------------------------------------------------------
#doc ColorRGB title {
#ColorRGB
#} index {
# Selectors
#} shortdescr {
# RGB color selection widget
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# select a color by setting red green and blue values
#}
#doc {ColorRGB options} h2 {
#	ColorRGB specific options
#}
#doc {ColorRGB command} h2 {
#	ColorRGB specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::ColorRGB {} {}
proc ColorRGB {} {}
}

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


#doc {ColorRGB options -command} option {-command command Command} descr {
# command to be executed when the color is changed
#}
Classy::ColorRGB addoption -command {command Command {}}

# ------------------------------------------------------------------
#  Methods
# -------------------------------------------------------------------


#doc {ColorRGB command nocmdset} cmd {
#pathname nocmdset value
#} descr {
# set current color to $value, without executing command
#}
Classy::ColorRGB method nocmdset {value} {
	private $object nocmd
	set rgb [winfo rgb $object $value]
	set nocmd 1
	$object.red.val set [expr 0.00389105*[lindex $rgb 0]]
	$object.green.val set [expr 0.00389105*[lindex $rgb 1]]
	$object.blue.val set [expr 0.00389105*[lindex $rgb 2]]
	update idletasks
	unset nocmd
}

#doc {ColorRGB command set} cmd {
#pathname set value
#} descr {
# set current color to $value
#}
Classy::ColorRGB method set {value} {
	$object nocmdset $value
	set command [getprivate $object options(-command)]
	if {"$command" != ""} {
		uplevel #0 $command [list [$object get]]
	}
}

#doc {ColorRGB command get} cmd {
#pathname get 
#} descr {
# get the current color
#}
Classy::ColorRGB method get {} {
	return [format "#%02x%02x%02x" \
		[$object.red.val get] [$object.green.val get] [$object.blue.val get]]
}

#doc {ColorRGB command getRGB} cmd {
#pathname getRGB 
#} descr {
# get the current color as a list of red, green and blue
#}
Classy::ColorRGB method getRGB {} {
	return "[$object.red.val get] [$object.green.val get] [$object.blue.val get]"
}

Classy::ColorRGB method _update {args} {
	private $object nocmd
	set color [$object get]
	$object.red.val configure -troughcolor $color
	$object.green.val configure -troughcolor $color
	$object.blue.val configure -troughcolor $color
	if ![info exists nocmd] {
		set command [getprivate $object options(-command)]
		if {"$command" != ""} {
			uplevel #0 $command [list [$object get]]
		}
	}
}
