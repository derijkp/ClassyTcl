namespace eval ::Classy::WindowBuilder {}
namespace eval ::Classy::WindowBuilder::start_Classy {}
namespace eval ::Classy::WindowBuilder::stop_Classy {}
namespace eval ::Classy::WindowBuilder::edit_Classy {}
namespace eval ::Classy::WindowBuilder::generate_Classy {}

#
# Toplevel
#

proc ::Classy::WindowBuilder::start_Toplevel {object base} {
	private $object data
	$object startedit [winfo children $base]
	set data(bind,$base) [bindtags $base]
	bindtags $base Classy::WindowBuilder_$object
	$object select $base
}

proc ::Classy::WindowBuilder::stop_Toplevel {object base} {
	private $object data
	$object stopedit [winfo children $base]
	if [info exists data(bind,$base)] {
		bindtags $base $data(bind,$base)
		unset data(bind,$base)
	}
}

proc ::Classy::WindowBuilder::generate_Toplevel {object base} {
	private $object current data
	set body ""
	set outw [$object outw $base]
	append body "\ttoplevel $outw [$object getoptions $base]\n"
	append body "\twm title $outw [wm title $base]\n"
	append body [$object generate [winfo children $base]]
	append body [$object gridconf $base]
	append body "\n"
	return $body
}

proc ::Classy::WindowBuilder::edit_Toplevel {object w} {
	set c [$object current]
	eval destroy [winfo children $w]
	Classy::Entry $w.title -label title \
		-command "wm title $c \[$w.title get\]" -labelwidth 15
	$w.title set [wm title $c]
	grid $w.title -sticky we
	set ::Classy::WindowBuilder::error {}
	label $w.error -textvariable ::Classy::WindowBuilder::error
	grid $w.error -sticky we
	grid columnconfigure $w 0 -weight 1
	grid rowconfigure $w 100 -weight 1
}

#
# Classy::Dialog
#

proc ::Classy::WindowBuilder::start_Classy::Dialog {object base} {
	private $object data
	set buttons [lremove [winfo children $base.actions] $base.actions.close]
	$object startedit $buttons
	foreach b $buttons {
		set data(class,$b) Classy::DialogButton
	}
	set data(bind,$base.actions.close) [bindtags $base.actions.close]
	bindtags $base.actions.close Classy::none
	$object startedit [winfo children $base.options]
	set data(redir,$base.actions) $base
	foreach w [list $base $base.actions $base.options] {
		set data(bind,$w) [bindtags $w]
		bindtags $w Classy::WindowBuilder_$object
	}
	$object select $base.options
}

proc ::Classy::WindowBuilder::stop_Classy::Dialog {object base} {
	private $object data
	$object stopedit [winfo children $base.actions]
	$object stopedit [winfo children $base.options]
	$object stopedit $base.options
	$object stopedit $base.actions
	if [info exists data(bind,$base)] {
		bindtags $base $data(bind,$base)
		unset data(bind,$base)
	}
}

proc ::Classy::WindowBuilder::generate_Classy::Dialog {object base} {
	private $object current data
	set outw [$object outw $base]
	set body ""
	append body "\tClassy::Dialog $outw [$object getoptions $base]\n"
	append body [$object generate [winfo children $base.options]]
	append body [$object gridconf $base.options]
	append body "\n"
	foreach b [lremove [$base button] close] {
		catch {append body "\t$outw add $b [$base button $b]\n"}
	}
	return $body
}

proc ::Classy::WindowBuilder::Dialog_addbutton {object base} {
	private $object data
	set list [::$base button]
	set num 1
	while 1 {
		if {[lsearch $list b$num] == -1} break
		incr num
	}
	::$base add b$num "button $num" {}
	set w $base.actions.b$num
	set data(class,$w) Classy::DialogButton
	set data(bind,$w) [bindtags $w]
	bindtags $w Classy::WindowBuilder_$object
}

proc ::Classy::WindowBuilder::edit_Classy::Dialog {object w} {
	set c [$object current]
	eval destroy [winfo children $w]
	set row 0
	foreach item {title closecommand autoraise keepgeometry} {
		Classy::Entry $w.$item -label $item \
			-command "$object setoption -$item \[$w.$item get\]" -labelwidth 15
		$w.$item set [$object getoption -$item]
		grid $w.$item -row $row -sticky we
		incr row
	}
	set ::Classy::WindowBuilder::error {}
	label $w.error -textvariable ::Classy::WindowBuilder::error
	grid $w.error -row [incr row] -sticky we
	button $w.addb -text "Add Button" -command [list ::Classy::WindowBuilder::Dialog_addbutton $object $c]
	grid $w.addb -row [incr row] -sticky we
	grid columnconfigure $w 0 -weight 1
	grid rowconfigure $w 100 -weight 1
}

proc ::Classy::WindowBuilder::edit_Classy::DialogButton {object w} {
	set c [$object current]
	eval destroy [winfo children $w]
	set row 0
	foreach item {text default} {
		Classy::Entry $w.$item -label $item \
			-command "$object setoption -$item \[$w.$item get\]" -labelwidth 15
		$w.$item set [$object getoption -$item]
		grid $w.$item - -row $row -sticky we
		incr row
	}
	set ::Classy::WindowBuilder::error {}
	label $w.error -textvariable ::Classy::WindowBuilder::error
	button $w.setcommand -text "Set Command" \
		-command "$object setoption -command \[string trimright \[$w.command get 1.0 end\]\]"
	Classy::Text $w.command -width 10 -height 5 -xscrollcommand [list $w.hscroll set] -yscrollcommand [list $w.vscroll set]
	$w.command insert end [$object getoption -command]
	scrollbar $w.vscroll -command [list $w.command yview]
	scrollbar $w.hscroll -orient horizontal -command [list $w.command xview]
	grid $w.error - -row [incr row] -sticky we
	grid $w.setcommand - -row [incr row] -sticky we
	grid $w.command $w.vscroll -row [incr row] -sticky nswe
	grid $w.hscroll -row [incr row] -sticky we
	grid columnconfigure $w 0 -weight 1
	grid columnconfigure $w 1 -weight 0
	grid rowconfigure $w 3 -weight 0
	grid rowconfigure $w 4 -weight 0
	grid rowconfigure $w 5 -weight 1
	grid rowconfigure $w 100 -weight 0
}

#
# Frame
#

proc ::Classy::WindowBuilder::start_Frame {object base} {
	private $object data
	$object startedit [winfo children $base]
	if ![info exists data(bind,$base)] {
		set data(bind,$base) [bindtags $base]
		bindtags $base Classy::WindowBuilder_$object
	}
	$object select $base
}

proc ::Classy::WindowBuilder::stop_Frame {object base} {
	private $object data
	$object stopedit [winfo children $base]
	if [info exists data(bind,$base)] {
		bindtags $base $data(bind,$base)
		unset data(bind,$base)
	}
}

proc ::Classy::WindowBuilder::generate_Frame {object base} {
	set body ""
	append body "\tframe $base [$object getoptions $base]\n"
	append body "\t[$object gridwconf $base\n"
	append body [$object generate [winfo children $base]]
	append body [$object gridconf $base]
	return $body
}

#
# Button
#

proc ::Classy::WindowBuilder::edit_Button {object w} {
	set c [$object current]
	eval destroy [winfo children $w]
	::Classy::WindowBuilder::entry $w text Text
	::Classy::WindowBuilder::entry $w image Image
	::Classy::WindowBuilder::entry $w justify Justify
	set ::Classy::WindowBuilder::error {}
	label $w.error -textvariable ::Classy::WindowBuilder::error
	grid $w.error -row [incr row] -sticky we
	button $w.setcmd -text "Set Command" -command "$object setoption -command \[string trimleft \[string trimright \[$w.cmd get 1.0 end\]\]\]"
	grid $w.setcmd -row [incr row] -sticky we
	Classy::Text $w.cmd
	grid $w.cmd -row [incr row] -sticky we
	$w.cmd insert end [$object getoption -command]
	grid columnconfigure $w 0 -weight 1
	grid rowconfigure $w $row -weight 1
}

#
# Classy::Entry
#

proc ::Classy::WindowBuilder::start_Classy::Entry {object base} {
	private $object data
	set data(redir,$base.entry) $base
	set data(redir,$base.frame) $base
	foreach w [list $base $base.entry $base.frame] {
		set data(bind,$w) [bindtags $w]
		bindtags $w Classy::WindowBuilder_$object
	}
}

#
# Label
#

proc ::Classy::WindowBuilder::edit_Label {object w} {
	::Classy::WindowBuilder::entry $w image Image
	::Classy::WindowBuilder::entry $w text Text
	::Classy::WindowBuilder::entry $w justify Justify
	set ::Classy::WindowBuilder::error {}
	label $w.error -textvariable ::Classy::WindowBuilder::error
	grid $w.error -row $row -sticky we
	grid columnconfigure $w 0 -weight 1
	grid rowconfigure $w 100 -weight 1
}

#
# Entry
#
proc ::Classy::WindowBuilder::entry {w item label {labelwidth 10}} {
	upvar row row
	upvar object object
	private $object data
	set c [$object current]
	if ![info exists row] {set row 0}
	upvar object object
	set var [privatevar $object data]
	Classy::Entry $w.$item -label $label -labelwidth $labelwidth \
		-command [varsubst {object item w c var} {
			if [set ${var}(f,$item,$c)] {
				$object setfoption -$item [$w.$item get]
			} else {
				$object setoption -$item [$w.$item get]
			}
		}]
	checkbutton $w.$item.f -text function -variable ${var}(f,$item,$c)
	if [info exists data(opt-$item,$c)] {set ${var}(f,$item,$c) 1} else {set ${var}(f,$item,$c) 0}
	pack forget $w.$item.frame
	pack $w.$item.f -side left -expand no
	pack $w.$item.frame -side left -fill x -expand yes
	$w.$item nocmdset [$object getoption -$item]
	grid $w.$item -row $row -sticky we
	incr row
}

proc ::Classy::WindowBuilder::edit_Entry {object w} {
	::Classy::WindowBuilder::entry $w textvariable Textvariable
	set ::Classy::WindowBuilder::error {}
	label $w.error -textvariable ::Classy::WindowBuilder::error
	grid $w.error -row $row -sticky we
	grid columnconfigure $w 0 -weight 1
	grid rowconfigure $w 100 -weight 1
}

#
# OptionBox
#

proc ::Classy::WindowBuilder::edit_Classy::OptionBox {object w} {
	Classy::Entry $w.label -label Label \
		-command "$object current configure -label \[$w.label get\]" -labelwidth 10
	$w.label insert end [$object currentcget -label]
	Classy::OptionBox $w.orient -label "Orientation"
	$w.orient add vertical "Vertical" -command "$object current configure -orient \[$w.orient get\]"
	$w.orient add horizontal "Horizontal" -command "$object current configure -orient \[$w.orient get\]"
	$w.orient set [$object current cget -orient]
	button $w.add -text "Add Field" -command "$object current add \[$w.addvalue get\] \[$w.addtext get\]"
	Classy::Entry $w.addvalue -label Value
	Classy::Entry $w.addtext -label Text
	grid $w.label -sticky we -columnspan 3
	grid $w.orient -sticky we -columnspan 3
	grid $w.add $w.addvalue $w.addtext -sticky we
	grid columnconfigure $w 0 -weight 1
	grid rowconfigure $w 100 -weight 1
}

