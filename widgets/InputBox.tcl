#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::InputBox
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::InputBox {} {}
proc InputBox {} {}
}
catch {Classy::InputBox destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass Classy::InputBox
Classy::export InputBox {}

Classy::InputBox classmethod init {args} {
	super
	Classy::Entry $object.options.entry -label File
	grid $object.options.entry -sticky we
	grid columnconfigure $object.options 1 -weight 10
	$object add action "Go" {} default

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	focus $object.options.entry.entry
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::InputBox chainoption -default {$object.options.entry} -default
Classy::InputBox chainoption -buttontext {$object.actions.action} -text
Classy::InputBox chainoption -label {$object.options.entry} -label
Classy::InputBox chainoption -command {$object.actions.action} -command
Classy::InputBox chainoption -textvariable {$object.options.entry} -textvariable

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::InputBox method get {} {
	return [$object.options.entry get]
}

Classy::InputBox method set {value} {
	$object.options.entry set $value
}




