#
# Initialisation of the ClassyWidgets
# ----------------------------------- Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# ---------------------------------------------------------------
package require Extral 1.1
# $Format: "package require Class 0.$ProjectMajorVersion$"$
package require Class 0.3
package provide ClassyTcl $::class::version

lappend auto_path [file join ${::class::dir} widgets] [file join ${::class::dir} dialogs]
namespace eval ::Classy {}

#----------------------------------------------------------------------
# Find the appdir.
#----------------------------------------------------------------------
if {"$tcl_platform(platform)"=="unix"} {
	if {"$::Classy::script"==""} {set ::Classy::script "wish"}
	if {"[file pathtype $::Classy::script]"!="absolute"} {set ::Classy::script [file join [pwd] $::Classy::script]}
	while 1 {
		if [catch {set link [file readlink $::Classy::script]}] break
		if {"[file pathtype $link]"=="absolute"} {
			set ::Classy::script $link
		} else {
			set ::Classy::script [file join [file dirname $::Classy::script] $link]
		}
	}
}
set Classy::appdir [file dir $::Classy::script]

if {"$tcl_platform(platform)"=="windows"} {
	load [file join $::class::dir classywin.dll]
}
# ----------------------------------------------------------------------
# Change the destroy command
# ----------------------------------------------------------------------
namespace eval ::Tk {}
if {"[info commands ::Tk::destroy]" == ""} {
	rename destroy ::Tk::destroy
}

proc destroy {args} {
	foreach w $args {
		if {"$w" == "."} {
			exit
		}
		if {"$w" == ".classy__"} continue
		if {"[info commands ::class::Tk_$w]" != ""} {
			catch {$w destroy}
		}
		foreach c [info commands ::class::Tk_$w.*] {
			regexp {^::class::Tk_(.*)$} $c temp child
			catch {$child destroy}
		}
		Classy::destroyrebind $w
	}
	eval ::Tk::destroy [list_remove $args .classy__]
}

if {"[info commands send]" == ""} {
	proc send {args} {
	while 1 {
		set arg [list_shift args]
		if ![regexp ^- $arg] break
		if {"$arg" == "--"} {
			list_shift args
			break
		}
		if {[llength $args] == 0} {return -code error "wrong # args: must be \"send ?options? appname args\""}
	}
   	eval uplevel #0 $args
   }
}

proc Classy::chainw {w cw} {
	catch {rename ::Tk::$w {}}
	rename $w ::Tk::$w
	proc ::$w args [varsubst {w cw} {
		set error [catch {uplevel ::Tk::$w $args} result]
		if {($error == 1)&&([string match {bad option *} $result])} {
			set error2 [catch {uplevel ::$cw $args} result2]
			if {($error2 == 1)&&([string match {bad option *} $result2])} {
				return -code $error $result
			} else {
				return -code $error2 $result2
			}
			
		} else {
			return -code $error $result
		}
	}]
}

#----------------------------------------------------------------------
# Initialise
#----------------------------------------------------------------------
frame .classy__
entry .classy__.dummy
button .classy__.dummyb

invoke {} {
	catch {destroy .classy__.dummyt}
	toplevel .classy__.dummyt
	wm positionfrom .classy__.dummyt program
	wm geometry .classy__.dummyt -10000-10000
	update idletasks
	set keep [winfo geometry .classy__.dummyt]
	destroy .classy__.dummyt
	foreach {w h x y} [split $keep x+] break
	set Classy::bx [expr {$x+10000+$w-[winfo vrootwidth .]}]
	set Classy::by [expr {$y+10000+$h-[winfo vrootheight .]}]
}

source [file join $::class::dir lib Widget.tcl]
source [file join [set ::class::dir] lib tools.tcl]
source [file join [set ::class::dir] lib conf.tcl]
option add *ColorList {{blue cyan green yellow orange red magenta} {blue3 cyan3 green3 yellow3 orange3 red3 magenta3} {black gray20 gray40 gray50 gray60 gray80 white}} widgetDefault

Classy::initconf
if {[option get . patchTk PatchTk]==1} {
	source [file join [set ::class::dir] patches patchtk.tcl]
	source [file join [set ::class::dir] patches miscpatches.tcl]
}

source [file join [set ::class::dir] lib rebind.tcl]

# ----------------------------------------------------------------------
# Change the bgerror command
# ----------------------------------------------------------------------

source [file join $::class::dir lib error.tcl]

# ----------------------------------------------------------------------
# class to command table (used in Builder and Config)
# ----------------------------------------------------------------------
array set ::Classy::cmds {
	Classy::Topframe frame
}

atexit add {
	catch {eval destroy [winfo children .]}
}

invoke {} {
	set clicks [clock clicks]
	after 1
	set ::Classy::clickspms [expr {[clock clicks]-$clicks}]
}
