#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::Test
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc Classy::Test {} {}
proc Test {} {}
}
catch {Classy::Test destroy}

option add *Classy::Test.highlightThickness 0 widgetDefault
option add *Classy::Test*Frame.highlightThickness 0 widgetDefault
option add *Classy::Test.entry.relief sunken widgetDefault
option add *Classy::Test.label.anchor w widgetDefault

bind Classy::Test <action> {
	actions
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Test
Classy::export Test {}

Classy::Test classmethod init {args} {
	# REM Create object
	# -----------------
	super frame $object
	entry $object.entry
	pack $object.entry -side left -expand yes -fill x

	# REM Create object bindings
	# -------------------
	bind $object <FocusIn> "focus $object.entry"

	# REM Initialise variables
	# ------------------------
	setprivate $object previous {}

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::Test chainoptions {$object.entry}

Classy::Test addoption -orient {orient Orient horizontal} {
	code
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Test chainallmethods {$object.entry} entry

Classy::Test method test {val} {
	private $object previous
	code
}

Classy::Test method _hidden {args} {
	code
}


