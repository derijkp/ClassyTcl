#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::FileEntry
# ----------------------------------------------------------------------
#doc FileEntry title {
#FileEntry
#} index {
# Tk improvements
#} shortdescr {
# <a gref="Entry.html">Classy::Entry</a> with file browse button
#} descr {
# subclass of <a href="Entry.html">Entry</a><br>
# provides nearly the same options and methods as Entry,
# bit has a "Browse" button which upon invocation will open a
# file selection dialog. When a file is selected in this dialog, it 
# will be inserted in the entry.
#}
# These will be added to tclIndex by Classy::auto_mkindex
#auto_index FileEntry

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Entry subclass Classy::FileEntry
Classy::export FileEntry {}

Classy::FileEntry classmethod init {args} {
	super init
	button $object.browse -text "Browse" -command [varsubst object {
		set ::Classy::current [$object get]
		set ::Classy::current [::Classy::selectfile -title "[$object cget -label]" \
			-initialdir [file dirname $::Classy::current] -filter *[file extension $::Classy::current] \
			]
		if {"$::Classy::current"!=""} {$object set $::Classy::current}
	}]
	pack $object.browse -in $object.frame -side left

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}


