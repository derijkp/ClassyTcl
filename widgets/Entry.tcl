#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::Entry
# ----------------------------------------------------------------------
#doc Entry title {
#Entry
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# The ClassyTcl entry has all the options and commands of the Tk entry, but
# with a few extras
#<ul>
#<li>optional label
#<li>constraints
#<li>a <a href="DefaultMenu.html">DefaultMenu</a> can be added to
# store and reselecte values easily. These default values are stored
# by the <a href="Default.html">Default</a> system as type app.
#</ul>
#}
#doc {Entry options} h2 {
#	Entry specific options
#}
#doc {Entry command} h2 {
#	Entry specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Entry {} {}
proc Entry {} {}
}

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
	Classy::todo $object _redrawentry
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::Entry chainoptions {$object.entry}

#doc {Entry options -orient} option {-orient orient Orient} descr {
# determines the position of the label relative to the entry: horizontal or vertical
#}
Classy::Entry addoption -orient {orient Orient horizontal} {
	Classy::todo $object _redrawentry
}


#doc {Entry options -default} option {-default default Default} descr {
# If not empty, a <a href="DefaultMenu.html">DefaultMenu</a> will be 
# added to store and reselecte values of the entry easily. These 
# default values are stored by the <a href="Defaults.html">Defaults</a> system 
# as type app. The default option gives the key for getting and 
# setting values.
#}
Classy::Entry addoption -default {default Default {}} {
	set w $object.defaults
	if {("$value"=="")&&([winfo exists $w])} {
		destroy $w
	} elseif ![winfo exists $w] {
		Classy::DefaultMenu $w -key $value \
			-command "$object set \[$w get\]" \
			-getcommand "$object get"
		pack $object.defaults -in $object.frame.entry -side right
	} else {
		$w configure -key $value
	}
	return $value
}


#doc {Entry options -label} option {-label label Label} descr {
# text to be displayed in the entry label. If this is empty, no label will bne displayed.
#}
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

#doc {Entry options -command} option {-command command Command} descr {
# associate a command with the entry. This
# command will be executed when the Action key is pressed in the entry.
#}
Classy::Entry addoption -command {command Command {}}

#doc {Entry options -constraint} option {-constraint constraint Constraint} descr {
# the value in the entry must match the regular expression given here.
# No constraint is applied when it is set to the empty string.
#}
Classy::Entry addoption -constraint {constraint Constraint {}}

#doc {Entry options -labelwidth} option {-labelwidth labelWidth LabelWidth} descr {
# width of the label
#}
Classy::Entry addoption -labelwidth {labelWidth LabelWidth {}} {
	Classy::todo $object _redrawentry
}


# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Entry chainallmethods {$object.entry} entry

#doc {Entry command nocmdset} cmd {
#pathname nocmdset value
#} descr {
# set the entry to value without invoking the command associated with the entry
#}
Classy::Entry method nocmdset {val} {
	private $object previous
	$object.entry delete 0 end
	$object.entry insert 0 $val
	$object constrain
	$object.entry xview end
}

#doc {Entry command set} cmd {
#pathname set value
#} descr {
# set the entry to value.
#}
Classy::Entry method set {val} {
	$object nocmdset $val
	uplevel #0 [getprivate $object options(-command)]
}

#doc {Entry command get} cmd {
#pathname get 
#} descr {
# get the current contents of the entry
#}
Classy::Entry method get {} {
	return [$object.entry get]
}

#doc {Entry command command} cmd {
#pathname command 
#} descr {
# invoke the command associated with the entry
#}
Classy::Entry method command {} {
	set command [getprivate $object options(-command)]
	if {"$command"==""} {
		return 0
	}
	uplevel #0 $command
	return 1
}	

#doc {Entry command constrain} cmd {
#pathname constrain ?warn?
#} descr {
# check whether the value matches the regular expression given by the -constraint option
# The optional parameter warn can be either 1 or 0. If it is 0, the entry will
# never contain a value not matching the constraint. It warn is 1, it is possible
# to enter a value not matching the constraint, but there will be visual warning.
#}
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

Classy::Entry method _redrawentry {} {
	private $object options
	if {"$options(-labelwidth)" != ""} {
		catch {$object.label configure -width $options(-labelwidth)}
	}
	if [string match "hor*" "$options(-orient)"] {
		if [winfo exists $object.label] {pack $object.label -side left}
		pack $object.frame -side left -expand yes -fill x
		return horizontal
	} else {
		if [winfo exists $object.label] {pack $object.label -side top -fill x}
		pack $object.frame -side bottom -expand yes -fill x
		return vertical
	}
}

