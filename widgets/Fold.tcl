#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::Fold
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Fold {} {}
proc Fold {} {}
}
catch {Classy::Fold destroy}

option add *Classy::Fold.relief flat widgetDefault
option add *Classy::Fold.knob.relief flat widgetDefault
option add *Classy::Fold.title.relief flat widgetDefault
option add *Classy::Fold.title.anchor w widgetDefault
option add *Classy::Fold.spacer.width 10 widgetDefault

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Fold
Classy::export Fold {}

Classy::Fold classmethod init {args} {
	# REM Create object
	# -----------------
	super
	button $object.knob -bitmap @[Classy::geticon foldclosed] -command [list $object open]
	button $object.title -text "" -command {}
	frame $object.spacer
	frame $object.content
	grid $object.knob $object.title - -sticky nwse
	grid columnconfigure $object 2 -weight 1
	grid rowconfigure $object 1 -weight 1

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}
Classy::Fold component content {$object.content}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::Fold addoption -closecommand {closeCommand Command {}}
Classy::Fold addoption -opencommand {openCommand Command {}}
Classy::Fold addoption -title {title Title {}} {
	$object.title configure -text $value
}
Classy::Fold chainoption -command {$object.title} -command
Classy::Fold chainoption -space {$object.spacer} -width

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Fold method open {} {
	private $object options
	$object.knob configure -bitmap @[Classy::geticon foldopen] -command [list $object close]
	grid $object.spacer -column 1 -row 1 -sticky nwse
	grid $object.content -column 2 -row 1 -sticky nwse
	uplevel #0 $options(-opencommand)
}

Classy::Fold method close {} {
	private $object options
	$object.knob configure -bitmap @[Classy::geticon foldclosed] -command [list $object open]
	grid forget $object.spacer
	grid forget $object.content
	uplevel #0 $options(-closecommand)
}
