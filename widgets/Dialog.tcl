#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Dialog
# ----------------------------------------------------------------------
#doc Dialog title {
#Dialog
#} index {
# Dialogs
#} shortdescr {
# dialog with intelligent placing, easy adding of buttons, ...
#} descr {
# subclass of <a href="../basic/Toplevel.html">Toplevel</a><br>
# Dialog produces "intelligent" dialog. They have a simple option to
#make them resizable or not. They automatically assume a reasonable
#minimum size based on their content (The dialog will be placed on the
#screen and its size calculated at the first idle moment after dialog 
#creation. The dialog will place itself so that the mouse pointer is 
#is positioned over it, without being placed partly out of the screen.
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

Classy::Toplevel subclass Classy::Dialog

Classy::export Dialog {}

Classy::Dialog classmethod init {args} {
	# REM Create object
	# -----------------
	super
	Classy::Dialog private options(-title) {title Title "Dialog"}
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

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {Dialog command add} cmd {
#pathname add button text command ?default?
#} descr {
# add a button with name $button to the dialog. The button will display
# the $text. When it is invoked, $command will be executed.
# If the word default is added, the button will be displayed differently
# and invoked by default (eg. when pressing Enter).
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
		lappend persistent $button
	}
	return $object.actions.$button
}

#doc {Dialog command remove} cmd {
#pathname delete button
#} descr {
# remove the button with name $button to the dialog.
#}
Classy::Dialog method delete {button} {
	private $object shortcuts persistent
	destroy $object.actions.$button
	catch {set persistent [lremove $persistent $button]}
}

#doc {Dialog command rename} cmd {
#pathname rename button newname
#} descr {
# rename the button with name $button to the dialog to $newname.
#}
Classy::Dialog method rename {button newname} {
	private $object shortcuts persistent
	set w $object.actions.$button
	set conf [$object button $button]
	eval {$object add $newname} $conf
	pack $object.actions.$newname -before $w
	$object delete $button
	catch {set persistent [lremove $persistent $button]}
}

#doc {Dialog command button} cmd {
#pathname button ?button?
#} descr {
# returns a list of buttons; if button is given, returns the parameters given to this button.
#}
Classy::Dialog method button {{button {}}} {
	if {"$button" == ""} {
		set result ""
		foreach b [winfo children $object.actions] {
			regsub ^$object\\.actions\\. $b {} b
			lappend result $b
		}
		return $result
	} else {
		set result [list [$object.actions.$button cget -text] [$object.actions.$button cget -command]]
		if {"[$object.actions.$button cget -default]" == "active"} {
			lappend result default
		}
		return $result
	}
}

#doc {Dialog command persistent} cmd {
#pathname persistent ?option button ...?
#} descr {
#Without arguments, the method returns a list of all persistent buttons
#Option can be:
#<ul>
#<li><b>set</b>: make only the given buttons persistent
#<li><b>add</b>: make the given buttons persistent
#<li><b>remove</b>: make the given buttons not persistent
#</ul>
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
	$object.actions.$item invoke
	if {("$item"!="help")&&("$button"!="Adjust")} {
		if [info exists persistent] {
			if {[lsearch -exact $persistent $item]==-1} {
				Classy::todo $object close
			}
		} else {
			Classy::todo $object close
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

