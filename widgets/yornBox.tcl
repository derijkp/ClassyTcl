#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# yornBox
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::yornBox {} {}
proc yornBox {} {}
}
catch {Classy::yornBox destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass Classy::yornBox
Classy::export yornBox {}

Classy::yornBox classmethod init {args} {
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

Classy::yornBox chainoption -message {$object.options.message} -text
Classy::yornBox chainoption -yescommand {$object.actions.yes} -command
Classy::yornBox chainoption -nocommand {$object.actions.no} -command

proc Classy::yorn {message args} {
	Classy::parseopt $args opt {
		-close {1 0 yes no} no
	} remain
	if {"$remain" != ""} {error "bad options \"$remain\""}
	Classy::yornBox .peos__yorn -yescommand {set ::Classy::yorn 1} \
		  -nocommand {set ::Classy::yorn 0} \
		  -closecommand {set ::Classy::yorn close} \
		  -title "YorN" -message $message -keepgeometry no
	if ![true $opt(-close)] {
		destroy .peos__yorn.actions.close
		bind .peos__yorn <Escape> {.peos__yorn invoke no}
	}
	if [info exists opt(-help)] {.peos__yorn configure -help $opt(-help)}
	grab set .peos__yorn
	tkwait window .peos__yorn
	update idletasks
	return $::Classy::yorn
}


