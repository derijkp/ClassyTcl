#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Balloon
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Balloon {} {}
proc Balloon {} {}
}
catch {Classy::Balloon destroy}

option add *Balloon.font {Helvetica 6 normal} widgetDefault
option add *Balloon.text.background yellow widgetDefault
option add *Balloon.background black widgetDefault
option add *Balloon.borderWidth 0 widgetDefault

bind all <Enter> {set Balloon__current %W;Balloon schedule %W}
bind all <Leave> {if [info exists Balloon__current] {unset Balloon__current};Balloon revoke}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Class subclass Classy::Balloon
Classy::export Balloon {}

if [winfo exists .classy::balloon] {destroy .classy::balloon}
toplevel .classy::balloon -class Balloon
wm withdraw .classy::balloon
label .classy::balloon.text
pack .classy::balloon.text -fill x -expand no -padx 1 -pady 1
wm overrideredirect .classy::balloon 1

# REM Initialise variables and options
# ------------------------------------
::Classy::Balloon private time 500

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Balloon classmethod destroy {} {
	destroy .classy::balloon
	bind all <Enter> {}
	bind all <Leave> {}
}

Classy::Balloon method add {widget text} {
	private $object help
	if {"$text"==""} {
		if [info exists help($widget)] {
			unset help($widget)
		}
	} else {
		set help($widget) $text
	}
}

Classy::Balloon method display {widget} {
	private $object help
	if ![info exists help($widget)] return
	.classy::balloon.text configure -text $help($widget)
	wm geometry .classy::balloon +[winfo rootx $widget]+[expr [winfo rooty $widget]+[winfo height $widget]]
	update idle
	wm deiconify .classy::balloon
	raise .classy::balloon
}

Classy::Balloon method schedule {widget} {
	private $object time
	private $object id
	set id [after $time "$object display $widget"]
}

Classy::Balloon method revoke {} {
	private $object id
	if [info exists id] {
		after cancel $id
		unset id
	}
	wm withdraw .classy::balloon
}
