#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::MultiListbox
# ----------------------------------------------------------------------
#doc MultiListbox title {
#MultiListbox
#} index {
# Tk improvements
#} shortdescr {
# listbox with more than one line long entries
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# creates a listbox in which an entries occupy more than one line
#}
#doc {MultiListbox options} h2 {
#	MultiListbox specific options
#}
#doc {MultiListbox command} h2 {
#	MultiListbox specific methods
#}
# These will be added to tclIndex by Classy::auto_mkindex
#auto_index MultiListbox

bind Classy::MultiListbox <<Action>> {%W select [%W nearest %y]}
bind Classy::MultiListbox <<Action-Motion>> {%W select [%W nearest %y]}
bind Classy::MultiListbox <<MExecute>> {%W command}
bind Classy::MultiListbox <<Return>> {%W command}
bind Classy::MultiListbox <<Up>> {
	set sel [%W curselection]
	incr sel -1
	%W select $sel
}
bind Classy::MultiListbox <<Down>> {
	set sel [%W curselection]
	incr sel 1
	%W select $sel
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::MultiListbox
Classy::export MultiListbox {}

Classy::MultiListbox method init {args} {
	# REM Create object
	# -----------------
	super init
	listbox $object.list -yscroll "$object.vbar set" -exportselection no -selectmode browse
	::Classy::rebind $object.list $object
	::Classy::refocus $object $object.list
	bindtags $object.list "$object.list Classy::MultiListbox . all"
	scrollbar $object.vbar -orient vertical -command "$object.list yview" -takefocus 0
	pack $object.vbar -side right -fill y
	pack $object.list -side right -fill both -expand yes

	# REM Initialise variables and options
	# ------------------------------------
	private $object var
	set var {}

	# REM Create bindings
	# -------------------

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {MultiListbox options -number} option {-number number Number} descr {
#}
Classy::MultiListbox addoption -number {number Number 1}

#doc {MultiListbox options -command} option {-command command Command} descr {
#}
Classy::MultiListbox addoption -command {command Command {}}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {MultiListbox command nearest} cmd {
#pathname nearest y
#} descr {
#}
Classy::MultiListbox method nearest {y} {
	return [expr [$object.list nearest $y] / [getprivate $object options(-number)]]
}

#doc {MultiListbox command select} cmd {
#pathname select item
#} descr {
#}
Classy::MultiListbox method select {item} {
	set number [getprivate $object options(-number)]
	if {$item<0} {set item 0}
	set max [expr [$object.list size] / $number]
	if {$item>=$max} {set item [expr $max -1]}

	set pos [expr $item * $number]
	$object.list select clear 0 end
	$object.list selection set $pos [expr $pos+$number-1]
}

#doc {MultiListbox command command} cmd {
#pathname command 
#} descr {
#}
Classy::MultiListbox method command {} {
	private $object options
	if {"$options(-command)" != ""} {
		uplevel #0 $options(-command) [list [$object get]]
	}
}

#doc {MultiListbox command get} cmd {
#pathname get 
#} descr {
#}
Classy::MultiListbox method get {} {
	set cursel [$object.list curselection]
	set result ""
	foreach pos $cursel {
		append result "[$object.list get $pos]\n"
	}
	return [string trimright $result "\n"]
}

#doc {MultiListbox command curselection} cmd {
#pathname curselection 
#} descr {
#}
Classy::MultiListbox method curselection {} {
	return [expr [lindex [$object.list curselection] 0] / [getprivate $object options(-number)]]
}

#doc {MultiListbox command add} cmd {
#pathname add ?element? ?element ...?
#} descr {
#}
Classy::MultiListbox method add {args} {
	eval $object.list insert end $args
}

#doc {MultiListbox command clear} cmd {
#pathname clear 
#} descr {
#}
Classy::MultiListbox method clear {} {
	eval $object.list delete 0 end
}


