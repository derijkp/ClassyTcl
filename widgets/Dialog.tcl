#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Dialog
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Dialog {} {}
proc Dialog {} {}
}
catch {Classy::Dialog destroy}

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
bind Classy::DialogButton <space> {
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

Classy::Dialog chainoption -closecommand {$object.actions.close} -command
Classy::Dialog addoption -keepgeometry {keepGeometry KeepGeometry yes}
Classy::Dialog addoption -cache {cache Cache 0} {
	set value [true $value]
}
Classy::Dialog addoption -title {dialog Dialog "Dialog"} {
	wm title $object $value
	return $value
}
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
Classy::Dialog addoption -resize {resize Resize {1 1}} {
	set x [lindex $value 0]
	set y [lindex $value 1]
	if {$x>1} {set x 1}
	if {$y>1} {set y 1}
	wm resizable $object $x $y
	return $value
}
Classy::Dialog addoption -autoraise {autoRaise AutoRaise 0} {
	if $value {
		raise $object
	}
	return $value
}

# ------------------------------------------------------------------
#  destructor
# ------------------------------------------------------------------

Classy::Dialog classmethod destroy {} {
	rename ::Classy::DialogButtonInvoke {}
	rename ::Classy::DialogButtonUp {}
	rename ::Classy::DialogButtonDown {}
}

Classy::Dialog method destroy {} {
	if [true [getprivate $object options(-keepgeometry)]] {
		Classy::Default set geometry $object [winfo geometry $object]
	}
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

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

Classy::Dialog method close {} {
	if [winfo exists $object] {
		if ![getprivate $object options(-cache)] {
			catch {destroy $object}
		} else {
			$object hide
		}
	}
}

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

Classy::Dialog method hide {} {
	Classy::Default set geometry $object [winfo geometry $object]
	wm withdraw $object
}

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

