#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::ColorSample
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::ColorSample {} {}
proc ColorSample {} {}
}
catch {Classy::ColorSample destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::ColorSample
Classy::export ColorSample {}

Classy::ColorSample classmethod init {args} {
	# REM Create object
	# -----------------
	super
	set Classycolors [option get $object colorList ColorList]
	set row 0
	set len 0
	foreach rowcolors $Classycolors {
		set col 0
		foreach color $rowcolors {
			label $object.cell$row,$col -anchor c -relief raised \
				-bg $color -width 5 -height 5
			bind $object.cell$row,$col <<Action>> "$object set $color"
			grid $object.cell$row,$col -row $row -column $col -sticky nwse
			incr col
		}
		if {$col>$len} {set len $col}
		grid rowconfigure $object $row -weight 1
		incr row
	}
	if [info exists color] {unset color}
	for {set col 0} {$col<$len} {incr col} {
		grid columnconfigure $object $col -weight 1
	}

	# REM Initialise variables and options
	# ------------------------------------
	private $object color
	set color white

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::ColorSample addoption -command {command Command {}}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::ColorSample method set {value} {
	private $object color
	set color $value
	uplevel #0 [getprivate $object options(-command)]
}

Classy::ColorSample method get {} {
	private $object color
	return $color
}

