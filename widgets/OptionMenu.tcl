#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::OptionMenu
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::OptionMenu {} {}
proc OptionMenu {} {}
}
catch {Classy::OptionMenu destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::OptionMenu
Classy::export OptionMenu {}

Classy::OptionMenu classmethod init {args} {
	super menubutton $object -text "" -menu $object.menu -indicatoron 1 \
		 -textvariable [privatevar $object textvariable] -relief raised -anchor c
	menu $object.menu -tearoff no
	
	# REM Create bindings
	# -------------------
	bind $object <<Action>> {
		if {$tkPriv(inMenubutton) != ""} {
			tkMbPost $tkPriv(inMenubutton) %X %Y
		}
	}

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::OptionMenu addoption -command {command Command {}}
Classy::OptionMenu addoption -list {list List {}} {
	$object.menu delete 0 end
	foreach val $value {
		$object.menu add command -label $val -command [varsubst {object val} {
			set [$object cget -textvariable] $val
			$object command
		}]
	}
	return $value
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::OptionMenu chainallmethods {$object} menubutton

Classy::OptionMenu method get {} {
	return [[Classy::widget $object] cget -text]
}

Classy::OptionMenu method command {} {
	uplevel #0 [getprivate $object options(-command)]
}

Classy::OptionMenu method set {value} {
	set list [getprivate $object options(-list)]
	if {[lsearch $list $value]!=-1} {
		set [[Classy::widget $object] cget -textvariable] $value
	}
}

