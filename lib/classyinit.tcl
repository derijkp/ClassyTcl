#
# Initialisation of the ClassyWidgets
# ----------------------------------- Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# ---------------------------------------------------------------
package require Extral 0.96
package require Class 0.1
lappend auto_path [file join ${::class::dir} widgets]
option add *ColorList {{blue cyan green yellow orange red magenta} {blue3 cyan3 green3 yellow3 orange3 red3 magenta3} {black gray20 gray40 gray50 gray60 gray80 white}} widgetDefault

namespace eval ::Classy {}

#----------------------------------------------------------------------
# Find the appdir.
#----------------------------------------------------------------------
if {"$tcl_platform(platform)"=="unix"} {
	if {"$Classy::script"==""} {set Classy::script tkdcse}
	if {"[file pathtype $Classy::script]"!="absolute"} {set Classy::script [file join [pwd] [string trimleft $Classy::script "./"]]}
	while 1 {
		if [catch {set link [file readlink $Classy::script]}] break
		if {"[file pathtype $link]"=="absolute"} {
			set Classy::script $link
		} else {
			set Classy::script [file join [file dirname $Classy::script] $link]
		}
	}
}
set Classy::appdir [file dir $Classy::script]

source [file join [set ::class::dir] lib conf.tcl]
source [file join [set ::class::dir] lib tools.tcl]
Classy::initconf
if {[option get . patchTk PatchTk]==1} {
	source [file join [set ::class::dir] patches patchtk.tcl]
	source [file join [set ::class::dir] patches miscpatches.tcl]
}
