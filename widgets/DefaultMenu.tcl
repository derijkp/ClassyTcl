#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::DefaultMenu
# ----------------------------------------------------------------------
#doc DefaultMenu title {
#DefaultMenu
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# creates a button which pops up a <a href="SelectDialog.html">selection 
# dialog</a> from which the user can choose between different
# default values, or add new ones.
#}
#doc {DefaultMenu options} h2 {
#	DefaultMenu specific options
#} descr {
#}
#doc {DefaultMenu command} h2 {
#	DefaultMenu specific methods
#} descr {
#}
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

#doc {DefaultMenu options -command} option {-command command Command} descr {
# This command will be executed when the user selects a value from
# the DefaultMenu.
#}
Classy::DefaultMenu addoption -command {command Command {}}

#doc {DefaultMenu options -getcommand} option {-getcommand getCommand GetCommand} descr {
# This command will be executed upon invoking the menu. The return value 
# will be placed in the Add entry. This value can be added easily to
# the list of default values to choose from
#}
Classy::DefaultMenu addoption -getcommand {getCommand GetCommand {}}

#doc {DefaultMenu options -key} option {-key key Key} descr {
# key by which the default system will be queried and changed
#}
Classy::DefaultMenu addoption -key {key Key {}}


# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::DefaultMenu chainallmethods {$object} button


#doc {DefaultMenu command get} cmd {
#pathname get 
#} descr {
# get the currently selected value.
#}
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


#doc {DefaultMenu command menu} cmd {
#pathname menu 
#} descr {
# invoke the DefaultMenu menu
#}
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
	$w fill [Classy::Default get app $options(-key)]
	set add [eval $options(-getcommand)]

	set posted 0
	.classy__defaultmenu.options.list activate 0
	bind $object <Motion> "$object _motion %X %Y"
	focus .classy__defaultmenu.options.list
	after idle "$object place"
}


#doc {DefaultMenu command add} cmd {
#pathname add value
#} descr {
# add $value to the associated defaults list
#}
Classy::DefaultMenu method add {val} {
	Classy::Default add app [getprivate $object options(-key)] $val
	return [list $val 0]
}


#doc {DefaultMenu command remove} cmd {
#pathname remove value
#} descr {
# remove $value from the associated defaults list
#}
Classy::DefaultMenu method remove {val} {
	Classy::Default remove app [getprivate $object options(-key)] $val
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


#doc {DefaultMenu command removemenu} cmd {
#pathname removemenu 
#} descr {
# remove the DefaultMenu menu from the screen
#}
Classy::DefaultMenu method removemenu {} {
	private $object focus
	focus $focus
	wm withdraw .classy__defaultmenu
	bind $object <Motion> {}
	.classy__defaultmenu hide
	Classy::Default set geometry $object [Classy::Default get geometry .classy__defaultmenu]
}


#doc {DefaultMenu command place} cmd {
#pathname place 
#} descr {
#}
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
