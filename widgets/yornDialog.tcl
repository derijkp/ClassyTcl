#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# yornDialog
# ----------------------------------------------------------------------
#doc yornDialog title {
#yornDialog
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
# creates a dialog which presents the user with a yes or no choice.
#} index {
# Dialogs
#} shortdescr {
# yes or no dialog: used by the command Classy::yorn
#}
#doc {yornDialog options} h2 {
#	yornDialog specific options
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::yornDialog {} {}
proc yornDialog {} {}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass Classy::yornDialog
Classy::export yornDialog {}

Classy::yornDialog classmethod init {args} {
	super init
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


#doc {yornDialog options -message} option {-message ? ?} descr {
#}
Classy::yornDialog chainoption -message {$object.options.message} -text

#doc {yornDialog options -yescommand} option {-yescommand ? ?} descr {
#}
Classy::yornDialog chainoption -yescommand {$object.actions.yes} -command

#doc {yornDialog options -nocommand} option {-nocommand ? ?} descr {
#}
Classy::yornDialog chainoption -nocommand {$object.actions.no} -command

