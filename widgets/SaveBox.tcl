#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::SaveBox
# ----------------------------------------------------------------------
#doc SaveBox title {
#SaveBox
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
#<b>experimental work</b>
#}
#doc {SaveBox options} h2 {
#	SaveBox specific options
#}
#doc {SaveBox command} h2 {
#	SaveBox specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::SaveBox {} {}
proc SaveBox {} {}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

if 1 {
proc Classy::SaveBox {args} {
	eval Classy::FileSelect $args
}

} else {
# experimental: this is NOT working
# ---------------------------------------------------------------------------
Classy::Dialog subclass Classy::SaveBox

Classy::SaveBox classmethod init {args} {
	super
	global iconpool
	label $object.options.icon -image $iconpool(file:__xxx)
	Classy::Entry $object.options.entry -label File -command [varsubst object {
		global iconpool
		regexp {\.([^.]*)$} [$object get] temp ext
		if [info exists iconpool(file:$ext)] {
			$object.options.icon configure -image $iconpool(file:$ext)
		} else {
			$object.options.icon configure -image $iconpool(file:__xxx)
		}
	}]
	frame $object.options.extra

	pack $object.options.icon -padx 5 -pady 5
	pack $object.options.entry -fill x -expand yes
	pack $object.options.extra -fill x -expand yes
	$object add save "Save" {} default

	# REM Initialise options and variables
	# ------------------------------------

	# REM Configure initial arguments
	# -------------------------------
	$object configure -closecommand "destroy $object"

	if {"$args" != ""} {eval $object configure $args}

	bind $object.options.icon <<Action-Motion>> "DragDrop start %W $object"
	focus $object.options.entry.entry
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::SaveBox addoption -transfercommand {}

#doc {SaveBox options -default} option {-default ? ?} descr {
#}
Classy::SaveBox chainoption -default {$object.options.entry} -default

#doc {SaveBox options -buttontext} option {-buttontext ? ?} descr {
#}
Classy::SaveBox chainoption -buttontext {$object.actions.save} -text

#doc {SaveBox options -textvariable} option {-textvariable ? ?} descr {
#}
Classy::SaveBox chainoption -textvariable {$object.options.entry} -textvariable

#doc {SaveBox options -command} option {-command ? ?} descr {
#}
Classy::SaveBox chainoption -command {$object.actions.save} -command

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {SaveBox command get} cmd {
#pathname get 
#} descr {
#}
Classy::SaveBox method get {} {
	return [$object.options.entry get]
}

#doc {SaveBox command set} cmd {
#pathname set value
#} descr {
#}
Classy::SaveBox method set {value} {
	$object.options.entry set $value
}
}

#doc {SaveBox command startdrag} cmd {
#pathname startdrag 
#} descr {
#}
Classy::SaveBox method startdrag {} {
	set transfercommand [getprivate $object options(-transfercommand)]
	set file [$object.options.entry get]
	d&d__startdrag [$object.options.icon cget -image] $object.options.icon "\
			savebox \{$object $file\} \
			mem_indirect [list [concat $object [eval $transfercommand]]]"
}
