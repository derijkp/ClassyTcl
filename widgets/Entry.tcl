#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::Entry
# ----------------------------------------------------------------------
#doc Entry title {
#Entry
#} index {
# Tk improvements
#} shortdescr {
#entry with label, constraints, command, defaultmenu
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# The ClassyTcl entry has all the options and commands of the Tk entry, but
# with a few extras
#<ul>
#<li>optional label
#<li>invoke command upon pressing Enter
#<li>constraints
#<li>validate command (executed upon each change)
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

option add *Classy::Entry.highlightThickness 0 widgetDefault
option add *Classy::Entry*Frame.highlightThickness 0 widgetDefault
option add *Classy::Entry*Frame.borderWidth 0 widgetDefault
option add *Classy::Entry.entry.relief sunken widgetDefault
option add *Classy::Entry.label.anchor w widgetDefault
option add *Classy::Entry.entry.width 5 widgetDefault

bind Classy::Entry <Key-Return> {
	%W constrain
	if [%W command] break
}

bind Classy::Entry <<Empty>> {
	%W nocmdset ""
}
bind Classy::Entry <<Default>> {
	if [winfo exists %W.defaults] {%W.defaults menu}
}
bind Classy::Entry <<Drop>> {
	%W insert insert [DragDrop get]
}
bind Classy::Entry <<Drag-Motion>> {
	tkEntryButton1 %W %x
}
bind Classy::Entry <<MXPaste>> {%W paste;break}
bind Classy::Entry <Any-KeyRelease> {%W constrain}
bind Classy::Entry <Any-ButtonRelease> {%W constrain}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Entry
Classy::Entry method init {args} {
	# REM Create object
	# -----------------
	set w [super init]
	$w configure -highlightthickness 0
	frame $object.frame
	frame $object.frame.entry
	pack $object.frame -expand yes -fill x -side left
	pack $object.frame.entry -expand yes -fill x -side left
	bindtags $object [lreplace [bindtags $object] 2 0 Entry]
	entry $object.entry
	$object _rebind $object.entry
	bind $object <FocusIn> [list focus $object.entry]
	pack $object.entry -in $object.frame.entry -side left -expand yes -fill x
	# REM Create bindings
	# -------------------
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
Classy::Entry chainoptions {::Classy::rebind::$object.entry}
Classy::Entry chainoption -background {$object} -background {::Classy::rebind::$object.entry} -background
Classy::Entry chainoption -highlightbackground {$object} -highlightbackground {::Classy::rebind::$object.entry} -highlightbackground
Classy::Entry chainoption -highlightcolor {$object} -highlightcolor {::Classy::rebind::$object.entry} -highlightcolor

#doc {Entry options -orient} option {-orient orient Orient} descr {
# determines the position of the label relative to the entry: horizontal or vertical
#}
Classy::Entry addoption -orient {orient Orient horizontal} {
	set value [Classy::orient $value]
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
			-command "$object set" \
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
	catch {destroy $object.label}
	if {"$value" != ""} {
		label $object.label -bg $options(-labelbg)
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

#doc {Entry options -labelbg} option {-labelbg labelBg LabelBg} descr {
# background color of label
#}
Classy::Entry addoption -labelbg {labelBg LabelBg gray} {
	$object.label configure -bg $value
}

#doc {Entry options -command} option {-command command Command} descr {
# associate a command with the entry. When the Action key (usually Enter) is pressed 
# in the entry, the widget will invoke a Tcl command by concatenating the given 
# command and the value in the entry widget. The command will be executed in global
# scope. If you want to use temporary variables without poluting the global namesspace,
# the <a href="convenience.html">Extral invoke</a> command might interest you.
#}
Classy::Entry addoption -command {command Command {}}

#doc {Entry options -constraint} option {-constraint constraint Constraint} descr {
# the value in the entry must match the regular expression given here.
# No constraint is applied when it is set to the empty string.
#}
Classy::Entry addoption -constraint {constraint Constraint {}}

#doc {Entry options -validate} option {-validate validate Validate} descr {
# This is a more general method to do validation of the entered value.
# the command given in the validate option will be invoked with two parameters:
# the old and the new value. The command must return 0 if the new value is ok, and
# 1 if the new value is not ok.
#}
Classy::Entry addoption -validate {validate Validate {}}

#doc {Entry options -labelwidth} option {-labelwidth labelWidth LabelWidth} descr {
# width of the label
#}
Classy::Entry addoption -labelwidth {labelWidth LabelWidth {}} {
	Classy::todo $object _redrawentry
}

#doc {Entry options -warn} option {-warn warn Warn} descr {
# The option -warn can be true or false. If it is false (or 0), the entry will
# never contain a value not matching the constraint. It warn is true, it is possible
# to enter a value not matching the constraint, but there will be visual warning.
#}
Classy::Entry addoption -warn {warn warn 1} {
	set value [true $value]
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Entry chainallmethods {::Classy::rebind::$object.entry} entry

#doc {Entry command nocmdset} cmd {
#pathname nocmdset value
#} descr {
# set the entry to value without invoking the command associated with the entry
#}
Classy::Entry method nocmdset {val} {
	private $object previous
	::Classy::rebind::$object.entry delete 0 end
	::Classy::rebind::$object.entry insert 0 $val
	::Classy::rebind::$object.entry xview end
}

#doc {Entry command set} cmd {
#pathname set value
#} descr {
# set the entry to value.
#}
Classy::Entry method set {val} {
	$object nocmdset $val
	$object constrain
	$object command
}

#doc {Entry command get} cmd {
#pathname get 
#} descr {
# get the current contents of the entry
#}
Classy::Entry method get {} {
	return [::Classy::rebind::$object.entry get]
}

#doc {Entry command command} cmd {
#pathname command 
#} descr {
# invoke the command associated with the entry
#}
Classy::Entry method command {} {
	set command [getprivate $object options(-command)]
	if {"$command" != ""} {
		uplevel #0 $command [list [::Classy::rebind::$object.entry get]]
		return 1
	} else {
		return 0
	}
}	

#doc {Entry command constrain} cmd {
#pathname constrain ?warn?
#} descr {
# check whether the value matches the regular expression given by the -constraint option
#}
Classy::Entry method constrain {} {
	private $object options previous previouscol
	set warn $options(-warn)
	set new [$object get]
	set ok 1
	if [llength $options(-validate)] {
		if [catch {uplevel #0 $options(-validate)} ok] {
			set error $ok
			set ok 0
		}
		if ![string length $ok] {set ok 1}
		if [true $ok] {set ok 1}
		if {$ok == 2} {
			set warn 1
			set ok 0
		}
	}
	if {$ok == 1} {
		set constraint $options(-constraint)
		if [string length $constraint] {
			set ok [regexp $constraint $new]
		}
	}
	if $ok {
		set previous $new
		if [info exists previouscol] {
			::Classy::rebind::$object.entry configure -fg $previouscol
			unset previouscol
		}
	} else {
		if {$warn==0} {
			$object nocmdset $previous
		} elseif ![info exists previouscol] {
			set previouscol [::Classy::rebind::$object.entry cget -fg]
			::Classy::rebind::$object.entry configure -fg red
		}
		if [info exists error] {error $error}
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

Classy::Entry method paste {} {
	::Classy::rebind::$object.entry insert insert [selection get -displayof $object]
}

Classy::Entry method previous {} {
	return [getprivate $object previous]
}
