#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::SelectDialog
# ----------------------------------------------------------------------
#doc SelectDialog title {
#SelectDialog
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
# creates a selection dialog. It allows selection out of a list of
# values. It also optionally allows adding or removing values from 
# the list.
#<p>
# The command<br>
#<b>Classy::select title list</b><br>
# can be used to easily pop op a dialog for simply selecting a value
# out of a list.
#}
#doc {SelectDialog options} h2 {
#	SelectDialog specific options
#}
#doc {SelectDialog command} h2 {
#	SelectDialog specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::SelectDialog {} {}
proc SelectDialog {} {}
}
catch {Classy::SelectDialog destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass Classy::SelectDialog
Classy::export SelectDialog {}

Classy::SelectDialog classmethod init {args} {
	super
	$object configure -resize {1 1}
	$object add go "Go" {} default
	frame $object.options.frame
	listbox $object.options.list -selectmode browse -exportselection no -yscrollcommand "$object.options.yscroll set"
	scrollbar $object.options.yscroll -orient vertical -command "$object.options.list yview" -takefocus 0
	pack $object.options.frame -fill both -expand yes
	pack $object.options.list -in $object.options.frame -side left -fill both -expand yes
	pack $object.options.yscroll -in $object.options.frame -side right -fill y
#	grid $object.options.list -row 0 -column 0 -sticky nwse
#	grid $object.options.yscroll -row 0 -column 1 -sticky ns
#	grid columnconfigure $object.options 0 -weight 1
#	grid columnconfigure $object.options 1 -weight 0
#	grid rowconfigure $object.options 0 -weight 1

	# REM Create bindings
	# -------------------
	bind $object.options.list <Enter> "focus $object.options.list"
	bind $object.options.list <space> "$object invoke go"
	bind $object.options.list <<MExecute>> "$object invoke go Action"
	bind $object.options.list <<MExecuteAjust>> "$object.options.list activate @%x,%y;$object invoke go Adjust"

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	focus $object.options.list
}

Classy::SelectDialog component addentry {$object.options.add}
Classy::SelectDialog component renameentry {$object.options.rename}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {SelectDialog options -command} option {-command ? ?} descr {
#}
Classy::SelectDialog chainoption -command {$object.actions.go} -command

#doc {SelectDialog options -default} option {-default default Default} descr {
#}
Classy::SelectDialog addoption -default {default Default {}} {
	if [winfo exists $object.options.add] {
		$object.options.add configure -default $value
	}
	return $value
}

#doc {SelectDialog options -addvariable} option {-addvariable addVariable AddVariable} descr {
#}
Classy::SelectDialog addoption -addvariable {addVariable AddVariable {}} {
	if [winfo exists $object.options.add] {destroy $object.options.add}
	if {"$value" != ""} {
		Classy::Entry $object.options.add -label "Add" -textvariable $value \
			-command "$object invoke add" -default [getprivate $object options(-default)]
		pack $object.options.add -side bottom -fill x
	}
	return $value
}

#doc {SelectDialog options -addcommand} option {-addcommand addCommand AddCommand} descr {
#}
Classy::SelectDialog addoption -addcommand {addCommand AddCommand {}} {
	catch {destroy $object.actions.add}
	if {"$value" != ""} {
		$object add add "Add" [list $object _add] Insert
	}
	return $value
} 

#doc {SelectDialog options -deletecommand} option {-deletecommand deleteCommand DeleteCommand} descr {
#}
Classy::SelectDialog addoption -deletecommand {deleteCommand DeleteCommand {}} {
	catch {destroy $object.actions.delete}
	if {"$value" != ""} {
		$object add delete "Delete" [list $object _delete] Delete
	}
	return $value
}

#doc {SelectDialog options -renamecommand} option {-renamecommand renameCommand RenameCommand} descr {
#}
Classy::SelectDialog addoption -renamecommand {renameCommand RenameCommand {}} {
	catch {destroy $object.actions.rename}
	catch {destroy $object.options.rename}
	if {"$value" != ""} {
		Classy::Entry $object.options.rename -label "Rename to"
		pack $object.options.rename -side bottom -fill x
		$object add rename "Rename" [list $object _rename]
	}
	return $value
} 

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::SelectDialog chainallmethods {$object.options.list} listbox

#doc {SelectDialog command fill} cmd {
#pathname fill names
#} descr {
#}
Classy::SelectDialog method fill {names} {
	$object.options.list delete 0 end
	eval $object.options.list insert end $names
}

#doc {SelectDialog command get} cmd {
#pathname get 
#} descr {
#}
Classy::SelectDialog method get {} {
	return [$object.options.list get active]
}

#doc {SelectDialog command set} cmd {
#pathname set name
#} descr {
#}
Classy::SelectDialog method set {name} {
	set pos [lsearch -exact [$object.options.list get 0 end] $name]
	if {$pos != -1} {
		$object.options.list activate $pos
		$object.options.list see $pos
	}
}

proc Classy::select {title list} {
	global Classytemp
	Classy::SelectDialog .classy::select -title $title -command {
		set Classytemp [.classy::select get]
	} -closecommand {set Classytemp ""}
	.classy::select fill $list
	tkwait window .classy::select
	return $Classytemp
}

Classy::SelectDialog method _add {} {
	set addcommand [getprivate $object options(-addcommand)]
	if {"$addcommand" != ""} {
		set res [uplevel #0 $addcommand]
		if {[llength $res]==2} {
			$object.options.list insert [$object.options.list index [lindex $res 1]] [lindex $res 0]
		}
	}
}

Classy::SelectDialog method _delete {} {
	set deletecommand [getprivate $object options(-deletecommand)]
	if {"$deletecommand" != ""} {
		uplevel #0 $deletecommand
		$object.options.list delete active
	}
}

Classy::SelectDialog method _rename {} {
	set renamecommand [getprivate $object options(-renamecommand)]
	if {"$renamecommand" != ""} {
		uplevel #0 $renamecommand [$object get] [$object.options.rename get]
		$object.options.list insert [expr [$object.options.list index active]+1] [$object.options.rename get]
		$object.options.list delete active
	}
}

