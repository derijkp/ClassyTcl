#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Balloon
# ----------------------------------------------------------------------
#doc Balloon title {
# Balloon
#} index {
# Common tools
#} shortdescr {
# help pops up when staying over a widget
#} descr {
# subclass of <a href="../basic/Class.html">Class</a><br>
# associate help with a widget such as a button. A box with the help text in it
# will popup after staying for some time over the widget without doing anything.
# Balloon is not meant to be instanciated; the command can can rather be used
# directly from the class.
#}

option add *Balloon.font {Helvetica 6 normal} widgetDefault
option add *Balloon.text.background yellow widgetDefault
option add *Balloon.background black widgetDefault
option add *Balloon.borderWidth 0 widgetDefault

bind all <Enter> {Classy::Balloon _schedule %W}
bind all <Leave> {Classy::Balloon revoke}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Class subclass Classy::Balloon

if [winfo exists .classy__.balloon] {destroy .classy__.balloon}
toplevel .classy__.balloon -class Balloon
wm withdraw .classy__.balloon
label .classy__.balloon.text
pack .classy__.balloon.text -fill x -expand no -padx 1 -pady 1
wm overrideredirect .classy__.balloon 1

# REM Initialise variables and options
# ------------------------------------
#doc {Balloon time} cmd {
#Balloon private time ms
#} descr {
# set the time (in miliseconds) to wait before the helptext gets displayed
#}
::Classy::Balloon private time 500

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Balloon classmethod destroy {} {
	destroy .classy__.balloon
	bind all <Enter> {}
	bind all <Leave> {}
}


#doc {Balloon add} cmd {
#Balloon add widget text
#} descr {
# add $text as help to the given widget
#}
Classy::Balloon classmethod add {widget text} {
	private $class help
	if {"$text"==""} {
		if [info exists help($widget)] {
			unset help($widget)
		}
	} else {
		set help($widget) $text
	}
}


#doc {Balloon display} cmd {
#Balloon display widget
#} descr {
# display the helptext associated with $widget
#}
Classy::Balloon classmethod display {widget} {
	private $class help
	if ![winfo exists $widget] return
	if ![info exists help($widget)] return
	if ![winfo exists .classy__.balloon] {
		toplevel .classy__.balloon -class Balloon
		wm withdraw .classy__.balloon
		label .classy__.balloon.text
		pack .classy__.balloon.text -fill x -expand no -padx 1 -pady 1
		wm overrideredirect .classy__.balloon 1
	}
	.classy__.balloon.text configure -text $help($widget)
	wm geometry .classy__.balloon +[winfo rootx $widget]+[expr [winfo rooty $widget]+[winfo height $widget]]
	update idle
	wm deiconify .classy__.balloon
	raise .classy__.balloon
}

#doc {Balloon revoke} cmd {
#Balloon revoke 
#} descr {
# remove the currently displayed helptext
#}
Classy::Balloon classmethod revoke {} {
	private $class id
	if [info exists id] {
		after cancel $id
		unset id
	}
	catch {wm withdraw .classy__.balloon}
}

Classy::Balloon classmethod _schedule {widget} {
	private $class time id
	set id [after $time "$class display $widget"]
}

