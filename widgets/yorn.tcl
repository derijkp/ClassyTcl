#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::yorn
# ----------------------------------------------------------------------
#doc yorn title {
#yorn
#} index {
# Dialogs
#} shortdescr {
# select yes or no
#}
# These will be added to tclIndex by Classy::auto_mkindex
#auto_index yorn
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
	Classy::yornDialog .classy__.yorn -yescommand {set ::Classy::yorn 1} \
		  -nocommand {set ::Classy::yorn 0} \
		  -closecommand {set ::Classy::yorn close} \
		  -title "YorN" -message $message -keepgeometry no
	if ![true $opt(-close)] {
		destroy .classy__.yorn.actions.close
		bind .classy__.yorn <Escape> {.classy__.yorn invoke no}
	}
	if [info exists opt(-help)] {.classy__.yorn configure -help $opt(-help)}
	update idletasks
	grab set .classy__.yorn
	tkwait window .classy__.yorn
	update idletasks
	return $::Classy::yorn
}

Classy::export yorn {}

