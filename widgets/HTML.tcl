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
# creates a HTML display widget. 
#The HTML class is based on the <a href="http://www.hwaci.com/sw/tkhtml/">html widget by 
#D. Richard Hipp</a>. It understands HTML 3.2. Forms support is
#not incorporated yet. The HTML class adds things such as asyncronous transfers and history.
#If the compiled html widget is not found, ClassyTcl reverts to the Tcl-only html 
#library by Stephen Uhler</a> that understands HTML 2.0. 
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
	if ![llength [info commands html]] {
		catch {load $::class::tkhtmllib}
	}
	if [llength [info commands html]] {
		Classy::HTML private type tkhtml
		set ::class::tkhtmllib 1
	} else {
		Classy::HTML private type htmllib
		set ::class::tkhtmllib 0
	}
} else {
	Classy::HTML private type htmllib
	set ::class::tkhtmllib 0
}

if $::class::tkhtmllib {
	source [file join $::class::dir widgets HTML-tkhtml.tcl]
} else {
	source [file join $::class::dir widgets HTML-htmllib.tcl]
}
