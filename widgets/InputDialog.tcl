#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::InputDialog
# ----------------------------------------------------------------------
#doc InputDialog title {
#InputDialog
#} index {
# Dialogs
#} shortdescr {
# Dialog with one entry
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
# creates a Dialog with an Entry widget.
#}
#doc {InputDialog options} h2 {
#	InputDialog specific options
#}
#doc {InputDialog command} h2 {
#	InputDialog specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::InputDialog {} {}
proc InputDialog {} {}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass Classy::InputDialog
Classy::export InputDialog {}

Classy::InputDialog classmethod init {args} {
	super init
	Classy::Entry $object.options.entry -label File
	grid $object.options.entry -sticky we
	grid columnconfigure $object.options 0 -weight 10
	$object add go "Go" [list $object _command] default
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	focus $object.options.entry.entry
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------


#doc {FileSelect options -command} option {-command command Command} descr {
#}
Classy::InputDialog addoption	-command [list command Command {}] {}

#doc {InputDialog options -default} option {-default default Default} descr {
#}
Classy::InputDialog chainoption -default {$object.options.entry} -default

#doc {InputDialog options -buttontext} option {-buttontext buttonText Text} descr {
#}
Classy::InputDialog chainoption -buttontext {$object.actions.go} -text

#doc {InputDialog options -label} option {-label label Label} descr {
#}
Classy::InputDialog chainoption -label {$object.options.entry} -label

#doc {InputDialog options -textvariable} option {-textvariable textVariable variable} descr {
#}
Classy::InputDialog chainoption -textvariable {$object.options.entry} -textvariable

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {InputDialog command get} cmd {
#pathname get 
#} descr {
#}
Classy::InputDialog method get {} {
	return [$object.options.entry get]
}

#doc {InputDialog command set} cmd {
#pathname set value
#} descr {
#}
Classy::InputDialog method set {value} {
	$object.options.entry set $value
}

Classy::InputDialog method _command {} {
	set command [getprivate $object options(-command)]
	if {"$command" != ""} {
		uplevel #0 $command [list [$object get]]
	}
}

