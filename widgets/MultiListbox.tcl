#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::MultiListbox
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::MultiListbox {} {}
proc MultiListbox {} {}
}
catch {Classy::MultiListbox destroy}

bind Classy::MultiListbox <<Action>> {set w [winfo parent %W];$w select [$w nearest %y]}
bind Classy::MultiListbox <<Action-Motion>> {set w [winfo parent %W];$w select [$w nearest %y]}
bind Classy::MultiListbox <<MExecute>> {[winfo parent %W] command}
bind Classy::MultiListbox <Return> {[winfo parent %W] command}
bind Classy::MultiListbox <<Up>> {
	set w [winfo parent %W]
	set sel [$w curselection]
	incr sel -1
	$w select $sel
}
bind Classy::MultiListbox <<Down>> {
	set w [winfo parent %W]
	set sel [$w curselection]
	incr sel 1
	$w select $sel
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::MultiListbox
Classy::export MultiListbox {}

Classy::MultiListbox classmethod init {args} {
	# REM Create object
	# -----------------
	super
	listbox $object.list -yscroll "$object.vbar set" -exportselection no -selectmode browse
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
Classy::MultiListbox addoption -number {number Number 1}
Classy::MultiListbox addoption -command {command Command {}}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::MultiListbox method nearest {y} {
	return [expr [$object.list nearest $y] / [getprivate $object options(-number)]]
}

Classy::MultiListbox method select {item} {
	set number [getprivate $object options(-number)]
	if {$item<0} {set item 0}
	set max [expr [$object.list size] / $number]
	if {$item>=$max} {set item [expr $max -1]}

	set pos [expr $item * $number]
	$object.list select clear 0 end
	$object.list selection set $pos [expr $pos+$number-1]
}

Classy::MultiListbox method command {} {
	public $object command
	return [uplevel #0 $command]
}

Classy::MultiListbox method get {} {
	set cursel [$object.list curselection]
	set result ""
	foreach pos $cursel {
		append result "[$object.list get $pos]\n"
	}
	return [string trimright $result "\n"]
}

Classy::MultiListbox method curselection {} {
	return [expr [lindex [$object.list curselection] 0] / [getprivate $object options(-number)]]
}

Classy::MultiListbox method add {args} {
	eval $object.list insert end $args
}

Classy::MultiListbox method clear {} {
	eval $object.list delete 0 end
}

