#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::InputBox
# ----------------------------------------------------------------------
#doc InputBox title {
#InputBox
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
# creates a Dialog with an Entry widget.
#}
#doc {InputBox options} h2 {
#	InputBox specific options
#}
#doc {InputBox command} h2 {
#	InputBox specific methods
#}
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


#doc {InputBox options -default} option {-default ? ?} descr {
#}
Classy::InputBox chainoption -default {$object.options.entry} -default

#doc {InputBox options -buttontext} option {-buttontext ? ?} descr {
#}
Classy::InputBox chainoption -buttontext {$object.actions.action} -text

#doc {InputBox options -label} option {-label ? ?} descr {
#}
Classy::InputBox chainoption -label {$object.options.entry} -label

#doc {InputBox options -command} option {-command ? ?} descr {
#}
Classy::InputBox chainoption -command {$object.actions.action} -command

#doc {InputBox options -textvariable} option {-textvariable ? ?} descr {
#}
Classy::InputBox chainoption -textvariable {$object.options.entry} -textvariable

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {InputBox command get} cmd {
#pathname get 
#} descr {
#}
Classy::InputBox method get {} {
	return [$object.options.entry get]
}

#doc {InputBox command set} cmd {
#pathname set value
#} descr {
#}
Classy::InputBox method set {value} {
	$object.options.entry set $value
}
