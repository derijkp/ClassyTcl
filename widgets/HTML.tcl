#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# HTML
# ----------------------------------------------------------------------
#doc HTML title {
#HTML
#} index {
# New widgets
#} shortdescr {
# displays HTML
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# creates a HTML display widget. The widget is based on the
# html_library by Stephan Uhler, with a few modifications.
#}
#doc {HTML options} h2 {
#	HTML specific options
#}
#doc {HTML command} h2 {
#	HTML specific methods
#}

Widget subclass Classy::HTML

set ::class::tkhtmllib [file join $::class::dir tkhtml tkhtml-$tcl_platform(os)-$tcl_platform(machine)[info sharedlibextension]]
if [file exists $::class::tkhtmllib] {
	Classy::HTML private type tkhtml
	source [file join $::class::dir widgets HTML-tkhtml.tcl]
} else {
	Classy::HTML private type htmllib
	set ::class::tkhtmllib 0
	source [file join $::class::dir widgets HTML-htmllib.tcl]
}
