#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::yorn
# ----------------------------------------------------------------------
#doc yorn title {
#yorn
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::yorn {} {}
proc yorn {} {}
}
#doc {yorn yorn} cmd {
#yorn message ?option value ...?
#} descr {
# displays $message with a choice of yes or no (or close).
# returns 1 if the the user answers yes, 0 if the user answers no
# and close if the user clicked the close button.
#<dl>
#<dt>-close<dd>must be 1 or 0
#</dl>
#}
proc Classy::yorn {message args} {
	Classy::parseopt $args opt {
		-close {1 0 yes no true false} no
	} remain
	if {"$remain" != ""} {error "bad options \"$remain\""}
	Classy::YornBox .peos__yorn -yescommand {set ::Classy::yorn 1} \
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

Classy::export yorn {}
