#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# YornBox
# ----------------------------------------------------------------------
#doc YornBox title {
#YornBox
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
# creates a dialog which presents the user with a yes or no choice.
#}
#doc {YornBox options} h2 {
#	YornBox specific options
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::YornBox {} {}
proc YornBox {} {}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass Classy::YornBox
Classy::export YornBox {}

Classy::YornBox classmethod init {args} {
	super
	message $object.options.message -width 200 -justify center
	pack $object.options.message

	$object add yes "Yes" {set Classyyorn yes} default
	$object add no "No" {set Classyyorn no}
	$object.actions.yes configure -underline 0
	$object persistent remove -all

	bind $object <y> "$object invoke yes"
	bind $object <n> "$object invoke no"

	# REM Configure initial arguments
	# -------------------------------
	$object configure -closecommand "set Classyyorn closed"
	if {"$args" != ""} {eval $object configure $args}
	focus $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------


#doc {YornBox options -message} option {-message ? ?} descr {
#}
Classy::YornBox chainoption -message {$object.options.message} -text

#doc {YornBox options -yescommand} option {-yescommand ? ?} descr {
#}
Classy::YornBox chainoption -yescommand {$object.actions.yes} -command

#doc {YornBox options -nocommand} option {-nocommand ? ?} descr {
#}
Classy::YornBox chainoption -nocommand {$object.actions.no} -command
