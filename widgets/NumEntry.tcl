#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::NumEntry
# ----------------------------------------------------------------------
#doc NumEntry title {
#NumEntry
#} index {
# Tk improvements
#} shortdescr {
# <a gref="Entry.html">Classy::Entry</a> limited to numbers, and with up and down buttons
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# provides nearly the same options and methods as Entry,
# but constrains the value to different types of numbers,
# and has increment and decrement buttons.
#}
#doc {NumEntry options} h2 {
#	NumEntry specific options
#}
#doc {NumEntry command} h2 {
#	NumEntry specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::NumEntry {} {}
proc NumEntry {} {}
}

option add *Classy::NumEntry.highlightThickness 0 widgetDefault
option add *Classy::NumEntry*Frame.highlightThickness 0 widgetDefault
option add *Classy::NumEntry*Frame.borderWidth 0 widgetDefault
option add *Classy::NumEntry.entry.relief sunken widgetDefault
option add *Classy::NumEntry.label.anchor w widgetDefault
option add *Classy::NumEntry.entry.width 5 widgetDefault

# ------------------------------------------------------------------
#  Creation
# ------------------------------------------------------------------

Classy::Entry subclass Classy::NumEntry
Classy::export NumEntry {}

Classy::NumEntry classmethod init {args} {
	super init
	bindtags $object [lreplace [bindtags $object] 2 0 Classy::Entry]
	bindtags $object.entry [lreplace [bindtags $object.entry] 3 0 Classy::Entry]
	frame $object.controls
	button $object.controls.incr -image [Classy::geticon incr.xbm]
	button $object.controls.decr -image [Classy::geticon decr.xbm]
	pack $object.controls.incr -side top
	pack $object.controls.decr -side bottom
	pack $object.controls -in $object.frame.entry -after $object.entry -side left

	# REM Initialise options and variables
	# ------------------------------------
	private $object repeating previous
	set previous {}
	set repeating off

	# REM Configure initial arguments
	# -------------------------------
	$object configure -increment 1
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Options
# ------------------------------------------------------------------


#doc {NumEntry options -increment} option {-increment increment Increment} descr {
#}
Classy::NumEntry addoption -increment {increment Increment 1} {
	$object.controls.incr configure -command "$object incr $value"
	$object.controls.decr configure -command "$object incr -$value"
	bind $object.entry <<Up>> "$object incr $value; update idletasks"
	bind $object.entry <<Down>> "$object incr -$value; update idletasks"
	return $value
}

#doc {NumEntry options -min} option {-min min Min} descr {
#}
Classy::NumEntry addoption -min {min Min {}}

#doc {NumEntry options -max} option {-max max Max} descr {
#}
Classy::NumEntry addoption -max {max Max {}}

#doc {NumEntry options -constraint} option {-constraint constraint Constraint} descr {
#}
Classy::NumEntry addoption -constraint {constraint Constraint {^(-?)[0-9]*(\.?)[0-9]([Ee][-+])?[0-9]*(\.?)[0-9]*$}} {
	if [string match $value int] {
		set value {^(-?)[0-9]*$}
	} elseif [string match $value float] {
		set value {^(-?)[0-9]*(\.?)[0-9]*$}
	} else {
		set value {^(-?)[0-9]*(\.?)[0-9]([Ee][-+][0-9]*(\.?)[0-9]*)?$}
	}
	return $value
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------


#doc {NumEntry command incr} cmd {
#pathname incr number
#} descr {
# increment the current value of the entry with $number. $number does not
# have to be an integer
#}
Classy::NumEntry method incr {number} {
	$object set [expr [$object get]+$number]
}


#doc {NumEntry command constrain} cmd {
#pathname constrain ?warn?
#} descr {
# check whether the value matches the regular expression given by the -constraint option
#}
Classy::NumEntry method constrain {} {
	private $object options previous previouscol
	set warn $options(-warn)
	set constraint $options(-constraint)
	set min [getprivate $object options(-min)]
	set max [getprivate $object options(-max)]
	set value [$object get]
	set error 0
	if {"$constraint" != ""} {
		if ![regexp $constraint $value] {
			set error 1
		}
	}
	if {"$value"=="-"} {
		if {("$min"!="")&&($min>=0)} {
			set error 1
		}
	} elseif {"$value"!=""} {
		if {("$min"!="")&&($value<$min)} {
			set error 1
		}
		if {("$max"!="")&&($value>$max)} {
			set error 1
		}
	}
	if $error {
		if {$warn==0} {
			$object nocmdset $previous
		} elseif ![info exists previouscol] {
			set previouscol [$object.entry cget -fg]
			$object.entry configure -fg red
		}
	} else {
		if [info exists previouscol] {
			$object.entry configure -fg $previouscol
			unset previouscol
		}
		set previous [$object get]
	}
}	

