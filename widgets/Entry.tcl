#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::Entry
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Entry {} {}
proc Entry {} {}
}
catch {Classy::Entry destroy}

option add *Classy::Entry.highlightThickness 0 widgetDefault
option add *Classy::Entry*Frame.highlightThickness 0 widgetDefault
option add *Classy::Entry*Frame.borderWidth 0 widgetDefault
option add *Classy::Entry.entry.relief sunken widgetDefault
option add *Classy::Entry.label.anchor w widgetDefault

bind Classy::Entry <Key-Return> {
	[winfo parent %W] constrain warn
	if [[winfo parent %W] command] break
}

bind Classy::Entry <<Empty>> {
	[winfo parent %W] nocmdset ""
}
bind Classy::Entry <<Default>> {
	set w [winfo parent %W]
	if [winfo exists $w.defaults] {$w.defaults menu}
}


# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Entry
Classy::export Entry {}

Classy::Entry classmethod init {args} {
	# REM Create object
	# -----------------
	super
	frame $object.frame
	frame $object.frame.entry
	pack $object.frame -expand yes -fill x -side left
	pack $object.frame.entry -expand yes -fill x -side left
	entry $object.entry
	pack $object.entry -in $object.frame.entry -side left -expand yes -fill x

	# REM Create bindings
	# -------------------
	bindtags $object.entry [concat Classy::Entry [bindtags $object.entry]]
	bind $object <FocusIn> "focus $object.entry"
	bind $object.entry <Any-KeyRelease> [list $object constrain warn]

	# REM Initialise variables
	# ------------------------
	setprivate $object previous {}

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::Entry chainoptions {$object.entry}

Classy::Entry addoption -orient {orient Orient horizontal} {
	if [string match "hor*" "$value"] {
		if [winfo exists $object.label] {pack $object.label -side left}
		pack $object.frame -side left -expand yes -fill x
		return horizontal
	} else {
		if [winfo exists $object.label] {pack $object.label -side top -fill x}
		pack $object.frame -side bottom -expand yes -fill x
		return vertical
	}
}

Classy::Entry addoption -default {default Default {}} {
	set w $object.defaults
	if {("$value"=="")&&([winfo exists $w])} {
		destroy $w
	} elseif ![winfo exists $w] {
		Classy::DefaultMenu $w -reference $value \
			-command "$object set \[$w get\]" \
			-getcommand "$object get"
		pack $object.defaults -in $object.frame.entry -side right
	} else {
		$w configure -reference $value
	}
	return $value
}

Classy::Entry addoption -label {label Label {}} {
	private $object options
#puts "set to $value"
	catch {destroy $object.label}
	if {"$value" != ""} {
		label $object.label
		pack $object.label -before $object.frame -side left
		$object.label configure -text $value
		if {"$options(-orient)"!="horizontal"} {
			pack $object.label -side top -fill x
			pack $object.frame -side bottom -expand yes -fill x
		}
	} else {
		catch {destroy $object.label}
	}
	return $value
}
Classy::Entry addoption -command {command Command {}}
Classy::Entry addoption -constraint {constraint Constraint {}}


# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Entry chainallmethods {$object.entry} entry

Classy::Entry method nocmdset {val} {
	private $object previous
	$object.entry delete 0 end
	$object.entry insert 0 $val
	$object constrain
	$object.entry xview end
}

Classy::Entry method set {val} {
	$object nocmdset $val
	uplevel #0 [getprivate $object options(-command)]
}

Classy::Entry method get {} {
	return [$object.entry get]
}

Classy::Entry method command {} {
	set command [getprivate $object options(-command)]
	if {"$command"==""} {
		return 0
	}
	uplevel #0 $command
	return 1
}	

Classy::Entry method constrain {{warn 0}} {
	set constraint [getprivate $object options(-constraint)]
	if {"$constraint" == ""} {
		return
	}
	private $object previous previouscol
	if [regexp $constraint [$object get]] {
		set previous [$object get]
		if [info exists previouscol] {
			$object.entry configure -fg $previouscol
			unset previouscol
		}
	} else {
		if {$warn==0} {
			$object nocmdset $previous
		} elseif ![info exists previouscol] {
			set previouscol [$object.entry cget -fg]
			$object.entry configure -fg red
		}
	}
}	

