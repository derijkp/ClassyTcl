#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::SelectDialog
# ----------------------------------------------------------------------
#doc SelectDialog title {
#SelectDialog
#} index {
# Dialogs
#} shortdescr {
# make a selection out of a list
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

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass Classy::SelectDialog
Classy::export SelectDialog {}

Classy::SelectDialog classmethod init {args} {
	super init
	$object configure -resize {1 1}
	$object add go "Go" [list $object _command] default
	frame $object.options.frame
	Classy::ListBox $object.options.list -selectmode browse -exportselection no -width 5 -height 5
	pack $object.options.frame -fill both -expand yes
	pack $object.options.list -in $object.options.frame -side left -fill both -expand yes
	# REM Create bindings
	# -------------------
	bind $object.options.list <Enter> "focus $object.options.list"
	bind $object.options.list <<Invoke>> "$object invoke go"
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
Classy::SelectDialog addoption -command {command Command {}} {}
#Classy::SelectDialog chainoption -command {$object.actions.go} -command

#doc {SelectDialog options -command} option {-command ? ?} descr {
#}
Classy::SelectDialog addoption -addvariable {addvariable AddVariable {}} {
	$object configure -addcommand [getprivate $object options(-addcommand)]
}

#doc {SelectDialog options -default} option {-default default Default} descr {
#}
Classy::SelectDialog addoption -default {default Default {}} {
	if [winfo exists $object.options.add] {
		$object.options.add configure -default $value
	}
	return $value
}

#doc {SelectDialog options -addcommand} option {-addcommand addCommand AddCommand} descr {
#}
Classy::SelectDialog addoption -addcommand {addCommand AddCommand {}} {
	private $object options
	catch {destroy $object.actions.add}
	catch {destroy $object.options.add}
	if {"$value" != ""} {
		Classy::Entry $object.options.add -label "Add" -textvariable $options(-addvariable) \
			-command "$object invoke add" -default [getprivate $object options(-default)]
		pack $object.options.add -side bottom -fill x
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
		Classy::Entry $object.options.rename -label "Rename to" \
			-command "$object invoke rename"
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

Classy::SelectDialog method _command {} {
	set command [getprivate $object options(-command)]
	if {"$command" != ""} {
		set value [$object.options.list get active]
		uplevel #0 $command [list $value]
	}
}

Classy::SelectDialog method _add {} {
	set addcommand [getprivate $object options(-addcommand)]
	if {"$addcommand" != ""} {
		set value [$object.options.add get]
		set res [uplevel #0 $addcommand [list $value]]
		if {[llength $res]==2} {
			$object.options.list insert [$object.options.list index [lindex $res 1]] [lindex $res 0]
		} else {
			$object.options.list insert active $value
		}
	}
}

Classy::SelectDialog method _delete {} {
	set deletecommand [getprivate $object options(-deletecommand)]
	if {"$deletecommand" != ""} {
		uplevel #0 $deletecommand [list [$object get]]
		$object.options.list delete active
	}
}

Classy::SelectDialog method _rename {} {
	set renamecommand [getprivate $object options(-renamecommand)]
	if {"$renamecommand" != ""} {
		uplevel #0 $renamecommand [list [$object get]] [list [$object.options.rename get]]
		$object.options.list insert [expr [$object.options.list index active]+1] [$object.options.rename get]
		$object.options.list delete active
	}
}

proc Classy::select {title list} {
	Classy::SelectDialog .classy__.select -title $title \
		-command {set Classy::temp} \
		-closecommand {set Classy::temp ""}
	.classy__.select fill $list
	tkwait window .classy__.select
	return $::Classy::temp
}

