#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::OptionBox
# ----------------------------------------------------------------------
#doc OptionBox title {
#OptionBox
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# creates an optionbox, a widget in which the user can select between
# different values using radiobuttons.
#}
#doc {OptionBox options} h2 {
#	OptionBox specific options
#}
#doc {OptionBox command} h2 {
#	OptionBox specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::OptionBox {} {}
proc OptionBox {} {}
}
catch {Classy::OptionBox destroy}

option add *Classy::OptionBox.relief raised widgetDefault
#option add *Classy::OptionBox.label.background $PeosOption(dark_bg) widgetDefault
#option add *Classy::OptionBox.label.anchor w widgetDefault
option add *Classy::OptionBox.label.relief flat widgetDefault
option add *Classy::OptionBox.box.relief flat widgetDefault
option add *Classy::OptionBox.box.highlightThickness 0 widgetDefault

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::OptionBox
Classy::export OptionBox {}

Classy::OptionBox classmethod init {args} {
	super frame $object -highlightthickness 0 -class Classy::OptionBox
	label $object.label -text ""
	frame $object.box
	pack $object.label -side left
	pack $object.box -side right -fill x -expand yes
	
	# REM Initialise variables
	# ------------------------
	private $object var
	set var {}
	
	setprivate $object options(-variable) [privatevar $object var]

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {OptionBox options -label} option {-label label Label} descr {
#}
Classy::OptionBox addoption -label {label Label {}} {
	$object.label configure -text $value
}

#doc {OptionBox options -orient} option {-orient orient Orient} descr {
# must be vertical or horizontal
#}
Classy::OptionBox addoption -orient {orient Orient horizontal} {
	if {"$value" == "vertical"} {
		set children [winfo children $object.box]
		pack $object.label -side top -fill x -expand yes
		pack $object.box -side bottom -fill x -expand yes
		foreach child $children {
			pack $child -side top -fill x -expand yes
		}
	} elseif {"$value" == "stacked"} {
		set children [winfo children $object.box]
		pack $object.label -side top -fill both
		pack $object.box -side right -fill x -expand yes
		foreach child $children {
			pack $child -side left -fill x -expand yes
		}
	} else {
		set children [winfo children $object.box]
		pack $object.label -side left -fill both
		pack $object.box -side right -fill x -expand yes
		foreach child $children {
			pack $child -side left -fill x -expand yes
		}
	}
}

#doc {OptionBox options -variable} option {-variable variable Variable} descr {
#}
Classy::OptionBox addoption -variable {variable Variable {}} {
	if {"$value" == ""} {
		set newval [privatevar $object var]
	} else {
		set newval $value
	}
	foreach radiobtn [winfo children $object.box] {
		$radiobtn configure -variable $newval
	}
	
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {OptionBox command add} cmd {
#pathname add item text ?option value ...?
#} descr {
#}
Classy::OptionBox method add {item text args} {
	radiobutton $object.box.b$item -relief flat -anchor w\
		-variable [getprivate $object options(-variable)] -text $text -value $item
	if {"[getprivate $object options(-orient)]" == "vertical"} {
		pack $object.box.b$item -side top -fill x -expand yes
	} else {
		pack $object.box.b$item -side left -fill x -expand yes
	}
	if {"$args" != ""} {eval $object.box.b$item configure $args}
	return $object.box.b$item
}

#doc {OptionBox command set} cmd {
#pathname set item
#} descr {
#}
Classy::OptionBox method set {item} {
	$object.box.b$item select
}

#doc {OptionBox command get} cmd {
#pathname get 
#} descr {
#}
Classy::OptionBox method get {} {
	return [uplevel #0 set [getprivate $object options(-variable)]]
}

#doc {OptionBox command items} cmd {
#pathname items 
#} descr {
#}
Classy::OptionBox method items {} {
	set list [winfo children $object.box]
	regsub -all $object.box.b $list {} list
	return $list
}
