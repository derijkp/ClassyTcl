#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::FileEntry
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::FileEntry {} {}
proc FileEntry {} {}
}
catch {Classy::FileEntry destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Entry subclass Classy::FileEntry
Classy::export FileEntry {}

Classy::FileEntry classmethod init {args} {
	super
	button $object.browse -text "Browse" -command [varsubst object {
		set ::Classy::current [$object get]
		set ::Classy::current [::Classy::selectfile -title "[$object cget -label]" \
			-initialdir [file dirname $::Classy::current] -filter *[file extension $::Classy::current] \
			]
		if {"$Classycurrent"!=""} {$object set $Classycurrent}
	}]
	pack $object.browse -in $object.frame -side left

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

