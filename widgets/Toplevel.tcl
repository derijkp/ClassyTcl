#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Toplevel
# ----------------------------------------------------------------------
#doc Toplevel title {
#Toplevel
#} index {
# Tk improvements
#} shortdescr {
# toplevel with geometry management and destroy command
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# Toplevel produces "intelligent" toplevels. They have a simple option to
#make them resizable or not. They automatically assume a reasonable
#minimum size based on their content (The Toplevel will be placed on the
#screen and its size calculated at the first idle moment after Toplevel 
#creation. The Toplevel will place itself so that the mouse pointer is 
#is positioned over it, without being place partly out of the screen.
#If it is resized, it can remember its size for the next display.
#}
#doc {Toplevel options} h2 {
#	Toplevel specific options
#}
#doc {Toplevel command} h2 {
#	Toplevel specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Toplevel {} {}
proc Toplevel {} {}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Toplevel

Classy::export Toplevel {}

Classy::Toplevel classmethod init {args} {
	# REM Create object
	# -----------------
	super init toplevel
#	wm geometry $object +1000000+1000000
	wm positionfrom $object program
	wm withdraw $object
	wm group $object .
	wm protocol $object WM_DELETE_WINDOW [list catch [list $object destroy]]
	# REM Create bindings
	# -------------------
	# REM Initialise variables
	# ------------------------
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	Classy::todo $object place
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
# REM Adding options

#doc {Toplevel options -destroycommand} option {-destroycommand ? ?} descr {
#commands invoked when destroying the toplevel
#}
Classy::Toplevel addoption -destroycommand {destroyCommand DestroyCommand {}}

#doc {Toplevel options -keepgeometry} option {-keepgeometry keepGeometry KeepGeometry} descr {
#remember size of Toplevel for next creation
#}
Classy::Toplevel addoption -keepgeometry {keepGeometry KeepGeometry 1} {
	if {"$value" != "all"} {
		set value [true $value]
	}
}

#doc {Toplevel options -cache} option {-cache cache Cache} descr {
#hide the Toplevel instead of destroying it when it is closed
#}
Classy::Toplevel addoption -cache {cache Cache 0} {
	set value [true $value]
}

#doc {Toplevel options -title} option {-title Title Title} descr {
#}
Classy::Toplevel addoption -title {title Title "Toplevel"} {
	wm title $object $value
	return $value
}

#doc {Toplevel options -resize} option {-resize resize Resize} descr {
#list of 2 values determining whether the Toplevel is resizable in x
#and y direction. If they are 0, the window is not resizable in that direction.
#When 1 it is resizable, with the requested size being the minimum size.
#When more than 2, the window is resizable, with the minimum size being 
#the value given
#}
Classy::Toplevel addoption -resize {resize Resize {1 1}} {
	set x [lindex $value 0]
	set y [lindex $value 1]
	set minw [winfo reqwidth $object]
	set minh [winfo reqheight $object]
	if {$x>1} {set minw $x ; set x 1}
	if {$y>1} {set minh $y ; set y 1}
	wm resizable $object $x $y
	wm minsize $object $minw $minh
	Classy::todo $object place
	return $value
}

#doc {Toplevel options -autoraise} option {-autoraise autoRaise AutoRaise} descr {
#}
Classy::Toplevel addoption -autoraise {autoRaise AutoRaise 0} {
	if $value {
		raise $object
	}
	return $value
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {Toplevel command hide} cmd {
#pathname hide 
#} descr {
#hide the Toplevel
#}
Classy::Toplevel method hide {} {
	Classy::Default set geometry $object [winfo geometry $object]
	wm withdraw $object
}

#doc {Toplevel command place} cmd {
#pathname place 
#} descr {
#display the Toplevel in a proper position, size, ...
#}
Classy::Toplevel method place {} {
	private $object options
	set resize $options(-resize)
	update idletasks
	set keeppos 0
	set grid [wm grid $object]
	if {"$grid" == ""} {
		set minw [winfo reqwidth $object]
		set minh [winfo reqheight $object]
	} else {
		set minw [lindex $grid 0]
		set minh [lindex $grid 1]
	}
	set w $minw
	set h $minh
	set rx [lindex $resize 0]
	set ry [lindex $resize 1]
	if {$rx>1} {set minw $rx ; set rx 1}
	if {$ry>1} {set minh $ry ; set ry 1}
	wm resizable $object $rx $ry
	wm minsize $object $minw $minh
	set keepgeometry [getprivate $object options(-keepgeometry)]
	if {("$keepgeometry" == "all")||$keepgeometry} {
		set geom [Classy::Default get geometry $object]
		if [regexp {^([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)} $geom temp xs ys prevx prevy] {
			if {$xs>$minw} {set w $xs}
			if {$ys>$minh} {set h $ys}
			if {"$keepgeometry" != "all"} {
				set temp [expr [winfo pointerx .]-$prevx]
				if {($temp>0)&&($temp<$w)} {
					set temp [expr [winfo pointery .]-$prevy]
					if {($temp>0)&&($temp<$h)} {
						set keeppos 1
						set x $prevx
						set y $prevy
					}
				}
			} else {
				set keeppos 1
				set x $prevx
				set y $prevy
			}
		}
	}
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
	update idletasks
	if {"$::tcl_platform(platform)" != "windows"} {
		wm deiconify $object
		raise $object
		wm geometry $object ${w}x${h}+$x+$y
	} else {
		wm geometry $object ${w}x${h}+$x+$y
		raise $object
		wm deiconify $object
		wm geometry $object ${w}x${h}+$x+$y
	}
}

# ------------------------------------------------------------------
#  destructor
# ------------------------------------------------------------------

#doc {Toplevel command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::Toplevel method destroy {} {
	private $object options
	if {"[wm grid $object]" == ""} {
		set geom [winfo geometry $object]
	} else {
		set geom [wm geometry $object]
	}
	Classy::Default set geometry $object $geom
	uplevel #0 $options(-destroycommand)
}


