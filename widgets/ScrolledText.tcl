#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::ScrolledText
# ----------------------------------------------------------------------
#doc ScrolledText title {
#ScrolledText
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# creates a Classy::Text with automatic scrollbars.
#}
#doc {ScrolledText command} h2 {
#	ScrolledText specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::ScrolledText {} {}
proc ScrolledText {} {}
}

option add *Classy::ScrolledText.highlightThickness 0 widgetDefault

bind Classy::ScrolledText <Configure> {Classy::todo %W redraw}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------
Widget subclass Classy::ScrolledText
Classy::export ScrolledText {}

Classy::ScrolledText classmethod init {args} {
	# REM Create object
	# -----------------
	super
	Classy::Text $object.text -wrap none \
		-xscrollcommand "$object xset" \
		-yscrollcommand "$object yset"
	scrollbar $object.xscroll -command "$object.text xview" -orient horizontal
	scrollbar $object.yscroll -command "$object.text yview" -orient vertical
	bindtags $object [lreplace [bindtags $object] 2 0 Classy::Text]
	::class::rebind $object.text $object
	::class::refocus $object $object.text
	grid $object.text -column 0 -row 0 -sticky nwse
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 0 -weight 1

	private $object redraw
	set redraw 0
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	Classy::todo $object redraw
	return $object
}

# ------------------------------------------------------------------
#  Widget destroy
# ------------------------------------------------------------------

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::ScrolledText chainoptions {$object.text}
Classy::ScrolledText chainoption -background {$object} -background {$object.text} -background
Classy::ScrolledText chainoption -highlightbackground {$object} -highlightbackground {$object.text} -highlightbackground
Classy::ScrolledText chainoption -highlightcolor {$object} -highlightcolor {$object.text} -highlightcolor

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::ScrolledText chainallmethods {$object.text} Classy::Text

#doc {ScrolledText command redraw} cmd {
#pathname redraw 
#} descr {
#}
Classy::ScrolledText method redraw {} {
	private $object redraw
	set redraw 1
	update idletasks
	if {"[$object.xscroll get]" != "0.0 1.0"} {
		grid $object.xscroll -row 1 -column 0 -sticky we
	} else {
		grid forget $object.xscroll
	}
	if {"[$object.yscroll get]" != "0.0 1.0"} {
		grid $object.yscroll -row 0 -column 1 -sticky ns
	} else {
		grid forget $object.yscroll
	}
	update idletasks
	set redraw 0
}

Classy::ScrolledText method xset {args} {
	private $object redraw
	eval $object.xscroll set $args
	if !$redraw {Classy::todo $object redraw}
}

Classy::ScrolledText method yset {args} {
	private $object redraw
	eval $object.yscroll set $args
	if !$redraw {Classy::todo $object redraw}
}
