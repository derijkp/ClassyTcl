#
# Initialisation of the ClassyWidgets
# ----------------------------------- Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# ---------------------------------------------------------------
package require Extral 1.23
lappend auto_path [file join ${::class::dir} widgets]
option add *ColorList {{blue cyan green yellow orange red magenta} {blue3 cyan3 green3 yellow3 orange3 red3 magenta3} {black gray20 gray40 gray50 gray60 gray80 white}} widgetDefault

proc classyinit {appname {appdir {}}} {
	tk appname $appname
	set Classy::appdir $appdir
	source [file join [set ::class::dir] lib conf.tcl]
	source [file join [set ::class::dir] lib tools.tcl]
	Classy::initconf
}

namespace eval ::Classy {}
