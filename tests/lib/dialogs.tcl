proc function {a b args} {
	return "$a $b $args"
}

#
# comments
#

proc try args {# ClassyTcl generated Dialog
	if [regexp {^\.} $args] {
		set window [lpop args]
	} else {
		set window .newd
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Dialog $window 
	entry $window.options.o1 -textvariable ::Dialog::value(.try.work.options.o1) -validate none
	grid $window.options.o1 -row 2 -column 0 -sticky nesw
	label $window.options.o3 -text [list label \[ it] ;#f -text {[list label \[ it]}
	grid $window.options.o3 -row 3 -column 0 -sticky nesw

}

# something else





proc plainf {a b args} {
	return "$a $b $args"
}


proc t args {# ClassyTcl generated Dialog
	if [regexp {^\.} $args] {
		set window [lpop args]
	} else {
		set window .newd
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Dialog $window  \
		-keepgeometry 0 \
		-title Toplevel
	bind $window <Key-Escape> {.try.dedit.work invoke close}
	label $window.options.o1 \
		-text label
	grid $window.options.o1 -row 1 -column 1 -sticky nesw
	button $window.options.o2 \
		-text button
	grid $window.options.o2 -row 0 -column 1 -sticky nesw
	entry $window.options.o3 \
		-textvariable ::Classy::value(.try.dedit.work.options.o3) \
		-validate none
	grid $window.options.o3 -row 2 -column 1 -sticky new
	frame $window.options.o4  \
		-borderwidth 2 \
		-relief groove
	grid $window.options.o4 -row 1 -column 0 -rowspan 2 -sticky nesw
	button $window.options.o4.o1 \
		-text button
	grid $window.options.o4.o1 -row 0 -column 0 -sticky nesw
	label $window.options.o4.o2 \
		-text label
	grid $window.options.o4.o2 -row 1 -column 0 -sticky nesw
	Classy::NumEntry $window.options.numentry1 \
		-validate none
	grid $window.options.numentry1 -row 0 -column 0 -sticky nesw
	bind $window.options.numentry1 <FocusIn> {focus .try.dedit.work.options.numentry1.entry}
	Classy::OptionBox $window.options.optionbox1  \
		-label try \
		-orient vertical

	$window.options.optionbox1 add test .try.dedit.work.options.optionbox1.box.b2
	$window.options.optionbox1 add option .try.dedit.work.options.optionbox1.box.b3
	button $window.options.button1 \
		-command {set font [Classy::getfont]} \
		-text {Select font}
	grid $window.options.button1 -row 3 -column 1 -sticky nesw
	button $window.options.button2 \
		-command {set color [Classy::getcolor]} \
		-text {Select color}
	grid $window.options.button2 -row 4 -column 1 -sticky new
	grid rowconfigure $window.options 4 -weight 1

}

proc geom args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lpop args]
	} else {
		set window .geom
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Toplevel $window  \
		-keepgeometry all \
		-title {.try.dedit.work work}
	button $window.o1 \
		-text {button 1}
	grid $window.o1 -row 0 -column 0 -sticky esw
	entry $window.o2 \
		-validate none
	grid $window.o2 -row 1 -column 0 -sticky esw
	frame $window.frame 
	grid $window.frame -row 0 -column 1 -rowspan 5 -sticky nesw
	scrollbar $window.frame.o6 \
		-orient horizontal
	grid $window.frame.o6 -row 3 -column 0 -sticky nesw
	scrollbar $window.frame.o5
	grid $window.frame.o5 -row 0 -column 1 -sticky nesw
	listbox $window.frame.listbox \
		-offset 0,0
	grid $window.frame.listbox -row 0 -column 0 -sticky nesw
	label $window.label1 \
		-text label
	grid $window.label1 -row 2 -column 0 -sticky new
	grid columnconfigure $window 0 -weight 1
	grid rowconfigure $window 2 -weight 1

}

proc draw args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lpop args]
	} else {
		set window .draw
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Toplevel $window -title "$window work" -keepgeometry all
	button $window.o2 \
		-command {$windw.c delete all} \
		-text clear
	grid $window.o2 -row 1 -column 0 -sticky w
	canvas $window.c \
		-height 207 \
		-width 295
	grid $window.c -row 0 -column 0 -sticky nesw
	bind $window.c <<Action>> {#binding
%W create oval [expr %x-3] [expr %y-3] [expr %x+3] [expr %y+3]}
	bind $window.c <<Action-Motion>> {#binding
%W create oval [expr %x-3] [expr %y-3] [expr %x+3] [expr %y+3]}
	bind $window.c <<Adjust>> [varsubst window {#binding
%W create text %x %y -text $window}]


#ClassyTcl init
set try 1
}











