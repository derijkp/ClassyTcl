#
# ####  #####  ####   #### 
# #   # #     #    # # 
# ####  ####  #    #  #### 
# #     #     #    #      # 
# #     #####  ####   ####  Peter De Rijk
#
# Classy::NumEntry
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::NumEntry {} {}
proc NumEntry {} {}
}
catch {Classy::NumEntry destroy}

# ------------------------------------------------------------------
#  Creation
# ------------------------------------------------------------------

Entry subclass Classy::NumEntry
Classy::export NumEntry {}

Classy::NumEntry classmethod init {args} {
	super
	frame $object.controls
	button $object.controls.incr -bitmap @[Classy::geticon incr]
	button $object.controls.decr -bitmap @[Classy::geticon decr]
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

Classy::NumEntry addoption -increment {increment Increment 1} {
	$object.controls.incr configure -command "$object incr $value"
	$object.controls.decr configure -command "$object incr -$value"
	bind $object.entry <<Up>> "$object incr $value; update idletasks"
	bind $object.entry <<Down>> "$object incr -$value; update idletasks"
	return $value
}
Classy::NumEntry addoption -min {min Min {}}
Classy::NumEntry addoption -max {max Max {}}
Classy::NumEntry addoption -constraint {constraint Constraint ^(-?)[0-9]*(\.?)[0-9]*$} {
	if [string match $value int] {
		set value {^(-?)[0-9]*$}
	} elseif [string match $value float] {
		set value {^(-?)[0-9]*(\.?)[0-9]*$}
	} else {
		set value {^(-?)[0-9]*(\.?)[0-9]*$}
	}
	return $value
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::NumEntry method incr {number} {
	$object set [expr [$object get]+$number]
}

Classy::NumEntry method constrain {{warn 0}} {
	set constraint [getprivate $object options(-constraint)]
	set min [getprivate $object options(-min)]
	set max [getprivate $object options(-max)]
	private $object previous previouscol
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

