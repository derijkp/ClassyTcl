#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::ListBox
# ----------------------------------------------------------------------
#doc ListBox title {
#ListBox
#} index {
# Tk improvements
#} shortdescr {
# listbox with auto scroll bars, and other extras
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# creates a listbox with automatic scrollbars, and some handy extra options.
#}
#doc {ListBox command} h2 {
#	ListBox specific methods
#}
# These will be added to tclIndex by Classy::auto_mkindex
#auto_index ListBox

bind Classy::ListBox <Configure> {Classy::todo %W redraw}
bind Classy::ListBox <Visibility> {Classy::todo %W redraw}
bind Classy::ListBox <<MExecute>> {%W command}
bind Classy::ListBox <<Invoke>> {%W command}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------
Widget subclass Classy::ListBox
Classy::export ListBox {}

Classy::ListBox classmethod init {args} {
	# REM Create object
	# -----------------
	super init
	listbox $object.list -xscrollcommand "$object.xscroll set" -yscrollcommand "$object.yscroll set" \
		-highlightthickness 0
	scrollbar $object.xscroll -command "$object.list xview" -orient horizontal
	scrollbar $object.yscroll -command "$object.list yview" -orient vertical
	$object.xscroll set 0.0 1.0
	$object.yscroll set 0.0 1.0
	bindtags $object [lreplace [bindtags $object] 2 0 Listbox]
	::class::rebind $object.list $object
	::class::refocus $object $object.list
	grid $object.list -column 0 -row 0 -sticky nwse
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 0 -weight 1
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	Classy::todo $object redraw
	return $object
}

# ------------------------------------------------------------------
#  Widget destroy
# ------------------------------------------------------------------

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::ListBox chainoptions {$object.list}
Classy::ListBox chainoption -background {$object} -background {$object.list} -background
Classy::ListBox chainoption -highlightbackground {$object} -highlightbackground {$object.list} -highlightbackground
Classy::ListBox chainoption -highlightcolor {$object} -highlightcolor {$object.list} -highlightcolor

#doc {Editor options -content} option {-content content Content} descr {
#}
Classy::ListBox addoption -content {content Content {}} {
	$object.list delete 0 end
	foreach el $value {
		$object.list insert end $el
	}
	Classy::todo $object redraw
}

#doc {Editor options -command} option {-command command Command} descr {
#}
Classy::ListBox addoption -command {command Command {}} {
}

#doc {Editor options -browsecommand} option {-browsecommand browseCommand BrowseCommand} descr {
#}
Classy::ListBox addoption -browsecommand {browseCommand BrowseCommand {}} {
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::ListBox chainallmethods {$object.list} listbox

#doc {ListBox command get} cmd {
#pathname get ?first? ?last?
#} descr {
#}
Classy::ListBox method get {args} {
	set len [llength $args]
	if {$len == 0} {
		set list ""
		foreach pos [$object.list curselection] {
			lappend list [$object.list get $pos]
		}
		return $list
	} elseif {$len == 1} {
		return [$object.list get [lindex $args 0]]
	} elseif {$len == 2} {
		return [$object.list get [lindex $args 0] [lindex $args 1]]
	} else {
		return -code error "wrong # args: should be \"$object get ?first? ?last?\""
	}
}

#doc {ListBox command set} cmd {
#pathname set ?el? ...
#} descr {
#}
Classy::ListBox method set {args} {
	$object selection clear 0 end
	set c [$object cget -content]
	foreach el $args {
		set pos [lsearch $c $el]
		if {$pos == -1} {error "element \"$el\" not in listbox"}
		$object.list selection set $pos
	}
}

#doc {ListBox command redraw} cmd {
#pathname redraw 
#} descr {
#}
Classy::ListBox method redraw {} {
	update idletasks
	if {"[$object.xscroll get]" != "0.0 1.0"} {
		grid $object.xscroll -row 1 -column 0 -sticky we
	} else {
		grid forget $object.xscroll
	}
	if {"[$object.yscroll get]" != "0.0 1.0"} {
		grid $object.yscroll -row 0 -column 1 -sticky ns
	} else {
		grid forget $object.yscroll
	}
}

Classy::ListBox method activate {args} {
	private $object options
	if [catch {eval $object.list activate $args}] {
		set c [$object cget -content]
		set pos [lsearch $c [lindex $args 0]]
		$object.list activate $pos
	} else {
		set args [$object.list get $args]
	}
	if {"$options(-browsecommand)" != ""} {
		uplevel #0 $options(-browsecommand) [list $args]
	}
}

Classy::ListBox method insert {args} {
	uplevel #0 $object.list insert $args
	Classy::todo $object redraw
}

Classy::ListBox method delete {args} {
	uplevel #0 $object.list delete $args
	Classy::todo $object redraw
}

Classy::ListBox method command {} {
	set command [getprivate $object options(-command)]
	if {"$command" != ""} {	
		uplevel #0 $command [list [$object get]]
	}
}


