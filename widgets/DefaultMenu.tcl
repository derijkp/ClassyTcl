#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::DefaultMenu
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::DefaultMenu {} {}
proc DefaultMenu {} {}
}
catch {Classy::DefaultMenu destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::DefaultMenu
Classy::export DefaultMenu {}

Classy::DefaultMenu classmethod init {args} {
	super button $object -relief raised -bitmap @[::Classy::geticon cbxarrow] -takefocus 0
	bind $object <<ButtonPress-Action>> "$object menu"
	bind $object <Any-ButtonRelease> "$object _action"

	# REM Evaluate arguments
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::DefaultMenu addoption -command {command Command {}}
Classy::DefaultMenu addoption -getcommand {getCommand GetCommand {}}
Classy::DefaultMenu addoption -reference {reference Reference {}}


# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::DefaultMenu chainallmethods {$object} button

Classy::DefaultMenu method get {} {
	.classy__defaultmenu get
}

Classy::DefaultMenu method _init {} {
	set w .classy__defaultmenu
	catch {destroy $w}
	if ![winfo exists $w] {
		Classy::SelectDialog $w -cache 1 -title "Select Value" \
			-command "#" -addcommand "#" -deletecommand "#"
	}
	after cancel "$w place"
#	$w place
	wm withdraw $w
}

Classy::DefaultMenu method _action {} {
	private $object posted
	set w .classy__defaultmenu
	if {"$posted"=="$w.options.list"} {
		$w invoke go
		$object removemenu
	} elseif {"$posted"=="$w.actions.close"} {
		$w invoke close
	} elseif {"$posted"=="$w.actions.add"} {
		$w invoke add
	}
}

Classy::DefaultMenu method menu {} {
	private $object posted focus add options
	set w .classy__defaultmenu
	if ![winfo exists $w] {$object _init}

	set focus [focus -displayof $object]
	set w .classy__defaultmenu
	$w configure -command "$options(-command)\n$object removemenu" \
		-addvariable [privatevar $object add] \
		-addcommand "$object add \[setglobal [privatevar $object add]\]" \
		-deletecommand "$object remove \[$w get\]" \
		-closecommand "$object removemenu"
	$w fill [Classy::Default get app $options(-reference)]
	set add [eval $options(-getcommand)]

	set posted 0
	.classy__defaultmenu.options.list activate 0
	bind $object <Motion> "$object _motion %X %Y"
	focus .classy__defaultmenu.options.list
	after idle "$object place"
}

Classy::DefaultMenu method add {val} {
	Classy::Default add app [getprivate $object options(-reference)] $val
	return [list $val 0]
}

Classy::DefaultMenu method remove {val} {
	Classy::Default remove app [getprivate $object options(-reference)] $val
}

Classy::DefaultMenu method _motion {X Y} {
	private $object posted
	set posted [winfo containing $X $Y]
	if {"$posted"==".classy__defaultmenu.options.list"} {
		set x [expr $X-[winfo rootx .classy__defaultmenu.options]]
		set y [expr $Y-[winfo rooty .classy__defaultmenu.options]]
		set index [.classy__defaultmenu index @$x,$y]
		.classy__defaultmenu activate $index
	}
}

Classy::DefaultMenu method removemenu {} {
	private $object focus
	focus $focus
	wm withdraw .classy__defaultmenu
	bind $object <Motion> {}
	.classy__defaultmenu hide
	Classy::Default set geometry $object [Classy::Default get geometry .classy__defaultmenu]
}

Classy::DefaultMenu method place {} {
	update idletasks
	set w [winfo reqwidth .classy__defaultmenu]
	set h [winfo reqheight .classy__defaultmenu]
	wm minsize .classy__defaultmenu $w $h
	set geom [Classy::Default get geometry $object]
	if [regexp {^([0-9]+)x([0-9]+)} $geom temp xs ys] {
		if {$xs>$w} {set w $xs}
		if {$ys>$h} {set h $ys}
	}
	wm geometry .classy__defaultmenu ${w}x${h}

	# position
	set maxx [expr [winfo vrootwidth .classy__defaultmenu]-$w]
	set maxy [expr [winfo vrootheight .classy__defaultmenu]-$h]
	set x [expr [winfo rootx $object]+[winfo width $object]-[winfo width .classy__defaultmenu]]
	set y [winfo rooty $object]
	if {$x<0} {set x 0}
	if {$y<0} {set y 0}
	if {$x>$maxx} {set x $maxx}
	if {$y>$maxy} {set y $maxy}
	wm geometry .classy__defaultmenu +$x+$y
	wm deiconify .classy__defaultmenu
	raise .classy__defaultmenu
}

