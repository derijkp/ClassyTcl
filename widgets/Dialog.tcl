#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Dialog
# ----------------------------------------------------------------------
#doc Dialog title {
#Dialog
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# Dialog produces "intelligent" dialog. They have a simple option to
#make tehm resizable or not. They automatically assume a reasonable
#minimum size based on their content (The dialog will be placed on the
#screen and its size calculated at the first idle moment after dialog 
#creation. The dialog will place itself so that the mouse pointer is 
#is positioned over it, without being place partly out of the screen.
#If it is resized, it remembers its size for the next display.
#<p>
#By default, the dialog has a "Close" button that destroys the dialog
#on invocation. Other buttons can be added easily using the add method.
#Invoking a command by clicking on a button (or using a key shortcut)
#will close the dialog, unless the button is persistent, or was 
#invoked using the Adjust mouse button.
#The dialog has one component named options, which is a frame in
#which optionmenus, entries, etc. can be placed. 
#}
#doc {Dialog options} h2 {
#	Dialog specific options
#}
#doc {Dialog command} h2 {
#	Dialog specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Dialog {} {}
proc Dialog {} {}
}

option add *Classy::Dialog.options.relief raised widgetDefault
option add *Classy::Dialog.options.highlightThickness 0 widgetDefault
option add *Classy::Dialog.actions.relief raised widgetDefault
option add *Classy::Dialog.actions.highlightThickness 0 widgetDefault

#bind Classy::DialogButton <FocusIn> {}
bind Classy::DialogButton <Enter> {
	tkButtonEnter %W
}
bind Classy::DialogButton <Leave> {
	tkButtonLeave %W
}
bind Classy::DialogButton <<Action>> {
	Classy::DialogButtonDown %W
}
bind Classy::DialogButton <<Adjust>> {
	Classy::DialogButtonDown %W
}
bind Classy::DialogButton <<ButtonRelease-Action>> {
	Classy::DialogButtonUp %W Action
}
bind Classy::DialogButton <<ButtonRelease-Adjust>> {
	Classy::DialogButtonUp %W Adjust
}
bind Classy::DialogButton <<Invoke>> {
	Classy::DialogButtonInvoke %W
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Dialog

Classy::export Dialog {}

Classy::Dialog classmethod init {args} {
	# REM Create object
	# -----------------
	super toplevel
#	wm geometry $object +1000000+1000000
	wm positionfrom $object program
	wm withdraw $object
	wm group $object .
	wm protocol $object WM_DELETE_WINDOW [list catch [list $object destroy]]
	frame $object.options
	frame $object.actions
	button $object.actions.close -text "Close"
	bindtags $object.actions.close [lregsub Button [bindtags $object.actions.close] Classy::DialogButton]
	pack $object.actions.close -side right -expand yes -padx 5 -pady 10
	grid $object.options -sticky nwse
	grid $object.actions -sticky we
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 0 -weight 1
	grid rowconfigure $object 1 -minsize [winfo reqheight $object.actions]

	# REM Create bindings
	# -------------------
	bind $object <Escape> "$object invoke close"

	# REM Initialise variables
	# ------------------------
	setprivate $object shortcuts ""

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	Classy::todo $object place
}

Classy::Dialog component options {$object.options}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
# REM Adding options


#doc {Dialog options -closecommand} option {-closecommand ? ?} descr {
#commands invoked when invoking the "Close" button
#}
Classy::Dialog chainoption -closecommand {$object.actions.close} -command

#doc {Dialog options -keepgeometry} option {-keepgeometry keepGeometry KeepGeometry} descr {
#remember size of dialog for next creation
#}
Classy::Dialog addoption -keepgeometry {keepGeometry KeepGeometry yes}

#doc {Dialog options -cache} option {-cache cache Cache} descr {
#hide the dialog instead of destroying it when it is closed
#}
Classy::Dialog addoption -cache {cache Cache 0} {
	set value [true $value]
}

#doc {Dialog options -title} option {-title dialog Dialog} descr {
#}
Classy::Dialog addoption -title {dialog Dialog "Dialog"} {
	wm title $object $value
	return $value
}

#doc {Dialog options -help} option {-help help Help} descr {
# add a help button. A file with the name helpvalue.html will
# be shown in a help window whein the button is invoked
#}
Classy::Dialog addoption -help {help Help {}} {
	if [string match $value ""] {
		catch {destroy $object.actions.help}
	} else {
		catch {button $object.actions.help -text "Help" -underline 0 }
		$object.actions.help configure -command "help $value"
		pack $object.actions.help -side right -expand yes -padx 5 -pady 10
		bind $object <<Help>> "$object invoke help"
		bind $object <Control-h> "$object invoke help"
	}
	return $value
}

#doc {Dialog options -resize} option {-resize resize Resize} descr {
#list of 2 values determining whether the dialog is resizable in x
#and y direction
#}
Classy::Dialog addoption -resize {resize Resize {1 1}} {
	set x [lindex $value 0]
	set y [lindex $value 1]
	if {$x>1} {set x 1}
	if {$y>1} {set y 1}
	wm resizable $object $x $y
	return $value
}

#doc {Dialog options -autoraise} option {-autoraise autoRaise AutoRaise} descr {
#}
Classy::Dialog addoption -autoraise {autoRaise AutoRaise 0} {
	if $value {
		raise $object
	}
	return $value
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {Dialog command add} cmd {
#pathname add button text command ?default?
#} descr {
# add a button with name $button to the dialog. The button will display
# the $text. When it is invoked, $command will be executed.
# If the word default is added, the button will be displayed differently
# and invoked by default (eg. when presseng Enter).
#}
Classy::Dialog method add {button text command args} {
	if {"$args" == "default"} {
		button $object.actions.$button -default active -text $text -command $command
		bindtags $object.actions.$button [lregsub Button [bindtags $object.actions.$button] Classy::DialogButton]
		pack $object.actions.$button -side left -expand yes
		bind $object <KeyPress-Return> "$object invoke $button"
	} else {
		private $object shortcuts persistent
		button $object.actions.$button -text $text -command $command
		bindtags $object.actions.$button [lregsub Button [bindtags $object.actions.$button] Classy::DialogButton]
		pack $object.actions.$button -side left -expand yes -padx 5 -pady 10
		set text [string tolower $text]
		set pos 0
		set len [string length $text]
		while {[lsearch $shortcuts [string index $text $pos]]!=-1} {
		incr pos
			if {$pos==$len} return
		}
		if {"$args" != ""} {
			bind $object $args "$object invoke $button"
		}
		bind $object <Control-[string index $text $pos]> "$object invoke $button"
		bind $object <Alt-[string index $text $pos]> "$object invoke $button Adjust"
		$object.actions.$button configure -underline $pos
		lappend shortcuts [string index $text $pos]
#		if {"$args" != ""} {
#			bind $object <KeyPress-$args> "$object invoke $button"
#		}
		lappend persistent $button
	}
	return $object.actions.$button
}

#doc {Dialog command persistent} cmd {
#pathname persistent ?option button ...?
#} descr {
#Without arguments, the method returns a list of all persistent buttons
#Option can be:
#<dl>
#<dt>set<dt>make only the given buttons persistent
#<dt>add<dt>make the given buttons persistent
#<dt>remove<dt>make the given buttons not persistent
#</dl>
#}
Classy::Dialog method persistent {{option {}} args} {
	private $object persistent
	if ![info exists persistent] {set persistent ""}
	if {"$option"==""} {
		return $persistent
	}
	if {"[lindex $args 0]"=="-all"} {
		set all [winfo children $object.actions]
		set all [lremove $all $object.actions.default $object.actions.close $object.actions.help]
		set args [lregsub {^.*\.} $all {}]
	}
	switch $option {
		set {
			set persistent $args
		}
		add {
			eval laddnew persistent $args
		}
		remove {
			set persistent [llremove $persistent $args]
		}
		default {
			error "bad option \"$option\": must be set, add or remove"
		}
	}
	return $persistent
}

#doc {Dialog command invoke} cmd {
#pathname invoke button ?Action/Adjust?
#} descr {
#}
Classy::Dialog method invoke {item {button Action}} {
	private $object persistent
	set autoraise [getprivate $object options(-autoraise)]
	if {("$item"!="help")&&("$button"!="Adjust")} {
		if [info exists persistent] {
			if {[lsearch -exact $persistent $item]==-1} {
				Classy::todo $object close
			}
		} else {
			Classy::todo $object close
		}
	}

	$object.actions.$item invoke
	if {"$item"!="help"} {
		if [info exists autoraise] {
			if $autoraise [list after 100 "raise $object"]
		}
	}
}

#doc {Dialog command close} cmd {
#pathname close 
#} descr {
#}
Classy::Dialog method close {} {
	if [winfo exists $object] {
		if ![getprivate $object options(-cache)] {
			catch {destroy $object}
		} else {
			$object hide
		}
	}
}

#doc {Dialog command hide} cmd {
#pathname hide 
#} descr {
#hide the dialog
#}
Classy::Dialog method hide {} {
	Classy::Default set geometry $object [winfo geometry $object]
	wm withdraw $object
}

#doc {Dialog command place} cmd {
#pathname place 
#} descr {
#display the dialog in a proper position, size, ...
#}
Classy::Dialog method place {} {
	set resize [getprivate $object options(-resize)]
	update idletasks
	set keeppos 0
	set w [winfo reqwidth $object]
	set h [winfo reqheight $object]
	set x [lindex $resize 0]
	set y [lindex $resize 1]
	if {$x>=1} {set rx 1} else {set rx 0}
	if {$y>=1} {set ry 1} else {set ry 0}
	if {$x<=1} {set x $w}
	if {$y<=1} {set y $h}
	wm minsize $object $x $y
	set keepgeometry [getprivate $object options(-keepgeometry)]
	if [true $keepgeometry] {
		set geom [Classy::Default get geometry $object]
		if [regexp {^([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)} $geom temp xs ys prevx prevy] {
			if {$xs>$w} {set w $xs}
			if {$ys>$h} {set h $ys}
			set temp [expr [winfo pointerx .]-$prevx]
			if {($temp>0)&&($temp<$w)} {
				set temp [expr [winfo pointery .]-$prevy]
				if {($temp>0)&&($temp<$h)} {
					set keeppos 1
					set x $prevx
					set y $prevy
				}
			}
		}
	}
	wm resizable $object $rx $ry

	# position
	if !$keeppos {
		set maxx [expr [winfo vrootwidth $object]-$w]
		set maxy [expr [winfo vrootheight $object]-$h]
		set x [expr [winfo pointerx .]-$w/2]
		set y [expr [winfo pointery .]-$h/2]
		if {$x>$maxx} {set x $maxx}
		if {$y>$maxy} {set y $maxy}
		if {$x<0} {set x 0}
		if {$y<0} {set y 0}
	}
	wm geometry $object +1000000+1000000
	wm deiconify $object
	raise $object
	if [true $keepgeometry] {
		wm geometry $object ${w}x${h}+$x+$y
	} else {
		wm geometry $object +$x+$y
	}
}

# patches from the original code in button.tcl

proc Classy::DialogButtonDown w {
	global tkPriv
	set tkPriv(relief) [lindex [$w config -relief] 4]
	if {[$w cget -state] != "disabled"} {
		set tkPriv(buttonWindow) $w
		$w config -relief sunken
	}
}

proc Classy::DialogButtonUp {w button} {
	global tkPriv
	if {$w == $tkPriv(buttonWindow)} {
		set tkPriv(buttonWindow) ""
		$w config -relief $tkPriv(relief)
		if {($w == $tkPriv(window))
				&& ([$w cget -state] != "disabled")} {
			regexp {\.([^.]*)$} $w temp leaf
			uplevel #0 [list [winfo toplevel $w] invoke $leaf $button]
		}
	}
}

proc Classy::DialogButtonInvoke w {
	if {[$w cget -state] != "disabled"} {
		set oldRelief [$w cget -relief]
		set oldState [$w cget -state]
		$w configure -state normal -relief sunken
		update idletasks
		after 100
		$w configure -state $oldState -relief $oldRelief
		regexp {\.([^.]*)$} $w temp leaf
		uplevel #0 [list [winfo toplevel $w] invoke $leaf]
	}
}

# ------------------------------------------------------------------
#  destructor
# ------------------------------------------------------------------

Classy::Dialog classmethod destroy {} {
	rename ::Classy::DialogButtonInvoke {}
	rename ::Classy::DialogButtonUp {}
	rename ::Classy::DialogButtonDown {}
}

#doc {Dialog command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::Dialog method destroy {} {
	if [true [getprivate $object options(-keepgeometry)]] {
		Classy::Default set geometry $object [winfo geometry $object]
	}
}

