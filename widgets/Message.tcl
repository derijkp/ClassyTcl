#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::Message
# ----------------------------------------------------------------------
#doc Message title {
#Message
#} index {
# Tk improvements
#} shortdescr {
# slightly improved message widget
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# The ClassyTcl Message has all the options and commands of the Tk Message, but
# it automatically adapts its width.
#}
#doc {Message options} h2 {
#	Message specific options
#}
#doc {Message command} h2 {
#	Message specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Message {} {}
proc Message {} {}
}

bind Classy::Message <Configure> {
	%W redraw
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Message
Classy::export Message {}

Classy::Message classmethod init {args} {
	super init message
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::Message chainoptions {$object}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Message chainallmethods {$object} message

Classy::Message method redraw {} {
	set w [Classy::window $object]
	$w configure -width [expr [winfo width $object] - 2*[$w cget -bd]]
}
