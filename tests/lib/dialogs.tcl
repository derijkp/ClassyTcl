proc function {a b args} {
	return "$a $b $args"
}

#
# comments
#

Classy::Dialog subclass try
try method init args {
	if {"$args" == "___Classy::Builder__create"} {return $object}
	super init
	# Create windows
	entry $object.options.o1 -textvariable ::Dialog::value(.try.work.options.o1) -validate none
	grid $object.options.o1 -row 2 -column 0 -sticky nesw
	label $object.options.o3 -text [list label \[ it] ;#f -text {[list label \[ it]}
	grid $object.options.o3 -row 3 -column 0 -sticky nesw


	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}}

# something else

proc plainf {a b args} {
	return "$a $b $args"
}

Classy::Dialog subclass t
t method init args {
	if {"$args" == "___Classy::Builder__create"} {return $object}
	super init
	# Create windows
	bind $object <Key-Escape> {.try.dedit.work invoke close}
	label $object.options.o1 \
		-text label
	grid $object.options.o1 -row 1 -column 1 -sticky nesw
	button $object.options.o2 \
		-text button
	grid $object.options.o2 -row 0 -column 1 -sticky nesw
	entry $object.options.o3 \
		-textvariable ::Classy::value(.try.dedit.work.options.o3) \
		-validate none
	grid $object.options.o3 -row 2 -column 1 -sticky new
	frame $object.options.o4  \
		-borderwidth 2 \
		-relief groove
	grid $object.options.o4 -row 1 -column 0 -rowspan 2 -sticky nesw
	button $object.options.o4.o1 \
		-text button
	grid $object.options.o4.o1 -row 0 -column 0 -sticky nesw
	label $object.options.o4.o2 \
		-text label
	grid $object.options.o4.o2 -row 1 -column 0 -sticky nesw
	Classy::NumEntry $object.options.numentry1 \
		-validate none
	grid $object.options.numentry1 -row 0 -column 0 -sticky nesw
	bind $object.options.numentry1 <FocusIn> {focus .try.dedit.work.options.numentry1.entry}
	Classy::OptionBox $object.options.optionbox1  \
		-label try \
		-orient vertical

	$object.options.optionbox1 add test .try.dedit.work.options.optionbox1.box.b2
	$object.options.optionbox1 add option .try.dedit.work.options.optionbox1.box.b3
	button $object.options.button1 \
		-command {set font [Classy::getfont]} \
		-text {Select font}
	grid $object.options.button1 -row 3 -column 1 -sticky nesw
	button $object.options.button2 \
		-command {set color [Classy::getcolor]} \
		-text {Select color}
	grid $object.options.button2 -row 4 -column 1 -sticky new
	grid rowconfigure $object.options 4 -weight 1


	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}}

                    

Classy::Toplevel subclass geom
geom method init args {
	if {"$args" == "___Classy::Builder__create"} {return $object}
	super init
	# Create windows
	button $object.o1 \
		-text {button 1}
	grid $object.o1 -row 0 -column 0 -sticky esw
	entry $object.o2
	grid $object.o2 -row 1 -column 0 -sticky esw
	frame $object.frame 
	grid $object.frame -row 0 -column 1 -rowspan 5 -sticky nesw
	scrollbar $object.frame.o6 \
		-orient horizontal
	grid $object.frame.o6 -row 3 -column 0 -sticky nesw
	scrollbar $object.frame.o5
	grid $object.frame.o5 -row 0 -column 1 -sticky nesw
	listbox $object.frame.listbox 
	grid $object.frame.listbox -row 0 -column 0 -sticky nesw
	$object.frame.listbox insert end 
	label $object.label1 \
		-text label
	grid $object.label1 -row 2 -column 0 -sticky new
	Classy::DynaMenu attachmainmenu Classy::Test $object
	Classy::DynaMenu attachmainmenu Classy::Test $object
	Classy::DynaMenu attachmainmenu Classy::Test $object
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 2 -weight 1


	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}}

Classy::Toplevel subclass draw
draw method init args {
	if {"$args" == "___Classy::Builder__create"} {return $object}
	super init
	# Create windows
	button $object.o2 \
		-command {$windw.c delete all} \
		-text clear
	grid $object.o2 -row 1 -column 0 -sticky w
	canvas $object.c \
		-height 207 \
		-width 295
	grid $object.c -row 0 -column 0 -sticky nesw
	bind $object.c <<Action>> {#binding
%W create oval [expr %x-3] [expr %y-3] [expr %x+3] [expr %y+3]}
	bind $object.c <<Action-Motion>> {#binding
%W create oval [expr %x-3] [expr %y-3] [expr %x+3] [expr %y+3]}
	bind $object.c <<Adjust>> [varsubst object {#binding
%W create text %x %y -text $object}]


#ClassyTcl init
set try 1

	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}}

                    
proc ttt tt {} {puts okok}

