namespace eval ::Classy::WindowBuilder {}
namespace eval ::Classy::WindowBuilder::start_Classy {}
namespace eval ::Classy::WindowBuilder::stop_Classy {}
namespace eval ::Classy::WindowBuilder::edit_Classy {}
namespace eval ::Classy::WindowBuilder::generate_Classy {}
namespace eval ::Classy::WindowBuilder::attr_Classy {}
namespace eval ::Classy::WindowBuilder::add_Classy {}
namespace eval ::Classy::WindowBuilder::delete_Classy {}

lappend auto_path [file join $class::dir widgets Builder]
array set ::Classy::WindowBuilder::parents {
	Toplevel 1 Frame 1 Classy::Toplevel 1
}

array set ::Classy::WindowBuilder::options {
	-activeborderwidth {Sizes int}
	-anchor {Display anchor}
	-bitmap {Display bitmap}
	-borderwidth {Display int}
	-cursor {Display cursor}
	-exportselection bool
	-font {Display font}
	-highlightthickness {Sizes int}
	-image {Display image}
	-insertborderwidth {Sizes int}
	-insertofftime int
	-insertontime int
	-insertwidth {Sizes int}
	-jump bool
	-justify {Display justify}
	-orient {Display orient}
	-padx {Sizes int}
	-pady {Sizes int}
	-relief {Display relief}
	-repeatdelay int
	-repeatinterval int
	-selectborderwidth {Sizes int}
	-setgrid bool
	-takefocus int
	-text {Display text}
	-textvariable {Code string}
	-underline int
	-wraplength {Sizes int}
	-height {Sizes int}
	-width {Sizes int}
	-offset {Sizes string}
	-label {Display text}
	-keepgeometry {Display line}
	-title {Display line}
	-value {Code line}
	-list {Code text}
	-xscrollcommand {Code text}
	-yscrollcommand {Code text}
	-xlabelcommand {Code text}
	-ylabelcommand {Code text}
	-getcommand {Code text}
	-setcommand {Code text}
	-command {Code text}
	-destroycommand {Code text}
	-closecommand {Code text}
	-opencommand {Code text}
	-endnodecommand {Code text}
	-getimage {Code text}
	-gettext {Code text}
	-getdata {Code text}
	-variable {Code line}
	-selectimage {Display image}
	-indicatoron {Display bool}
	-activebackground {Colors color}
	-activeforeground {Colors color}
	-background {Colors color}
	-disabledforeground {Colors color}
	-foreground {Colors color}
	-highlightbackground {Colors color}
	-highlightcolor {Colors color}
	-insertbackground {Colors color}
	-selectbackground {Colors color}
	-selectforeground {Colors color}
	-selectcolor {Colors color}
	-troughcolor {Colors color}
	-menu {Display menu}
	command text
	content text
}
set ::Classy::WindowBuilder::options(common) {
	-textvariable -text -command -justify -image -orient -variable 
	-label -title -destroycommand -closecommand -value -menu
}

proc ::Classy::WindowBuilder::attredit_line {object v option title {wide 0}} {
	set value [$object attribute get $option]
	Classy::Entry $v.value -width 2 -label "$title"	-orient stacked \
		-command [varsubst {object v option} {
			$object attribute setf? $option [$v.value get]
		}] -textvariable [privatevar $object attredit($v)]
	if $wide {$v.value configure -orient horizontal -labelwidth $wide}
	grid $v.value -row 2 -column 0 -sticky we
	grid columnconfigure $v 0 -weight 1
	$v.value nocmdset $value
	grid rowconfigure $v 3 -weight 1
}

proc ::Classy::WindowBuilder::attredit_int {object v option title {wide 0}} {
	set value [$object attribute get $option]
	Classy::NumEntry $v.value -width 2 -label "$title"	-orient stacked \
		-command [varsubst {object v option} {
			$object attribute setf? $option [$v.value get]
		}]
	if $wide {$v.value configure -orient horizontal -labelwidth $wide}
	grid $v.value -row 2 -column 0 -sticky we
	grid columnconfigure $v 0 -weight 1
	$v.value nocmdset $value
	grid rowconfigure $v 3 -weight 1
}

proc ::Classy::WindowBuilder::attredit_text {object v option title {wide 0}} {
	set value [$object attribute get $option]
	button $v.change -text "$title" -command [varsubst {object v option title} {
		$object attribute setf? $option [string trimright [$v.value get 1.0 end]]
		$v.change configure -text "$title"
		$v.value textchanged 0
	}]
	Classy::Text $v.value -width 5 -height 2
	grid $v.change -row 2 -column 0 -sticky we
	grid $v.value -row 3 -column 0 -sticky nswe
	grid columnconfigure $v 0 -weight 1
	grid rowconfigure $v 3 -weight 1
	$v.value insert end $value
	$v.value textchanged 0
	$v.value configure -changedcommand [varsubst {v title} {
		$v.change configure -text "Change $title *"
	}]
}

proc ::Classy::WindowBuilder::attredit_color {object v option title {wide 0}} {
	attredit_line $object $v $option $title $wide
	$v.value configure -label "$title color"
	button $v.select -text "Select color" -command "$v.value set \[Classy::getcolor -initialcolor \[$v.value get\]\]"
	if $wide {
		grid $v.select -row 2 -column 1 -sticky nwe
	} else {
		grid $v.select -row 3 -column 0 -sticky nwe
		grid rowconfigure $v 3 -weight 0
		grid rowconfigure $v 4 -weight 1
	}
}

proc ::Classy::WindowBuilder::attredit_font {object v option title {wide 0}} {
	attredit_line $object $v $option $title $wide
	$v.value configure -label "$title font"
	button $v.select -text "Select font" -command "$v.value set \[Classy::getfont -font \[$v.value get\]\]"
	if $wide {
		grid $v.select -row 2 -column 1 -sticky nwe
	} else {
		grid $v.select -row 3 -column 0 -sticky nwe
		grid rowconfigure $v 3 -weight 0
		grid rowconfigure $v 4 -weight 1
	}
}

proc ::Classy::WindowBuilder::attredit_justify {object v option title {wide 0}} {
	attredit_line $object $v $option $title $wide
	frame $v.select
	set column 0
	foreach {type icon} {left justify_left.gif center justify_center.gif right justify_right.gif} {
		radiobutton $v.select.$type -indicatoron 0 -text $type \
			-image [Classy::geticon Builder/$icon] \
			-command  "$v.value set $type" -value $type \
			-variable [privatevar $object attredit($v)]
		grid $v.select.$type -row 0 -column $column
		incr column
	}
	if $wide {
		grid $v.select -row 2 -column 1 -sticky nwe
	} else {
		grid $v.select -row 3 -column 0 -sticky nwe
		grid rowconfigure $v 3 -weight 0
		grid rowconfigure $v 4 -weight 1
	}
}

proc ::Classy::WindowBuilder::attredit_bool {object v option title {wide 0}} {
	attredit_line $object $v $option $title $wide
	frame $v.select
	set column 0
	foreach {type icon} {1 true.gif 0 false.gif} {
		radiobutton $v.select.$type -indicatoron 0 -text $type \
			-image [Classy::geticon Builder/$icon] \
			-command  "$v.value set $type" -value $type \
			-variable [privatevar $object attredit($v)]
		grid $v.select.$type -row 0 -column $column
		incr column
	}
	if $wide {
		grid $v.select -row 2 -column 1 -sticky nwe
	} else {
		grid $v.select -row 3 -column 0 -sticky nwe
		grid rowconfigure $v 3 -weight 0
		grid rowconfigure $v 4 -weight 1
	}
}

proc ::Classy::WindowBuilder::attredit_orient {object v option title {wide 0}} {
	attredit_line $object $v $option $title $wide
	frame $v.select
	set column 0
	foreach {type icon} {horizontal orient_horizontal.gif vertical orient_vertical.gif} {
		radiobutton $v.select.$type -indicatoron 0 -text $type \
			-image [Classy::geticon Builder/$icon] \
			-command  "$v.value set $type" -value $type \
			-variable [privatevar $object attredit($v)]
		grid $v.select.$type -row 0 -column $column
		incr column
	}
	if $wide {
		grid $v.select -row 2 -column 1 -sticky nwe
	} else {
		grid $v.select -row 3 -column 0 -sticky nwe
		grid rowconfigure $v 3 -weight 0
		grid rowconfigure $v 4 -weight 1
	}
}

proc ::Classy::WindowBuilder::attredit_relief {object v option title {wide 0}} {
	attredit_line $object $v $option $title $wide
	frame $v.select
	set row 0
	set column 0
	foreach {type icon} {raised relief_raised sunken relief_sunken flat relief_flat ridge relief_ridge solid relief_solid groove relief_groove} {
		radiobutton $v.select.$type -indicatoron 0 -text $type \
			-image [Classy::geticon Builder/$icon] \
			-command  "$v.value set $type" -value $type \
			-variable [privatevar $object attredit($v)]
		grid $v.select.$type -row $row -column $column -sticky we
		incr column
		if {$column == 3} {set column 0;incr row}
	}
	if $wide {
		grid $v.select -row 2 -column 1 -sticky nwe
		grid $v.value -row 2 -column 0 -sticky nwe
	} else {
		grid $v.select -row 3 -column 0 -sticky nwe
		grid rowconfigure $v 3 -weight 0
		grid rowconfigure $v 4 -weight 1
	}
}

proc ::Classy::WindowBuilder::attredit_anchor {object v option title {wide 0}} {
	attredit_line $object $v $option $title $wide
	frame $v.select
	set row 0
	set column 0
	foreach {type icon} {nw anchor_nw n anchor_n ne anchor_ne w anchor_w center anchor_center e anchor_e sw anchor_sw s anchor_s se anchor_se} {
		radiobutton $v.select.$type -indicatoron 0 -text $type \
			-image [Classy::geticon Builder/$icon] \
			-command  "$v.value set $type" -value $type \
			-variable [privatevar $object attredit($v)]
		grid $v.select.$type -row $row -column $column -sticky we
		incr column
		if {$column == 3} {set column 0;incr row}
	}
	$v.select.center configure -text c
	if $wide {
		grid $v.select -row 2 -column 1 -sticky nwe
		grid $v.value -row 2 -column 0 -sticky nwe
	} else {
		grid $v.select -row 3 -column 0 -sticky nwe
		grid rowconfigure $v 3 -weight 0
		grid rowconfigure $v 4 -weight 1
	}
}

proc ::Classy::WindowBuilder::menuset {object} {
	private $object data bindtags current
	set window $data(base)
	eval set base $window
	set menutype $data(opt-mainmenu,$base)
	if {"$menutype" != ""} {
		set cmdws data(opt-menuwin,$base)
		$base configure -menu [eval Classy::DynaMenu menu $menutype [lindex $cmdws 0]]
		set menu ""
		foreach win [winfo children $base] {
			if [regexp ^$base.#classy__#menu_ $win] {
				set menu $win
				break
			}
		}
		set data(menu,$base) $menu
		set data(class,$menu) Classy::DynaMenu
		bindtags $menu Classy::WindowBuilder_$object
		return $menu
	} else {
		$base configure -menu {}
		set data(opt-menuwin,$base) ""
		return ""
	}
}

proc ::Classy::WindowBuilder::attredit_menu {object v option title {wide 0}} {
	private $object current
	set class [$object itemclass $current(w)]
	if {("$class" != "Classy::Toplevel")&&("$class" != "Classy::Dialog")} {
		::Classy::WindowBuilder::attredit_line $object $v $option $title $wide
		return
	}
	Classy::Entry $v.menutype -width 2 -label "Menutype"	-orient stacked \
		-command "::Classy::WindowBuilder::menuset $object" \
		-textvariable [privatevar $object data(opt-mainmenu,$current(w))]
	if $wide {$v.menutype configure -orient horizontal -labelwidth $wide}
	grid $v.menutype -row 2 -column 0 -sticky we
	Classy::Entry $v.cmdw -width 2 -label "Menu window(s)"	-orient stacked \
		-command "::Classy::WindowBuilder::menuset $object" \
		-textvariable [privatevar $object data(opt-menuwin,$current(w))]
	if $wide {$v.cmdw configure -orient horizontal -labelwidth $wide}
	grid $v.cmdw -row 3 -column 0 -sticky we
	grid rowconfigure $v 4 -weight 1
	grid columnconfigure $v 0 -weight 1
}

#
# Def tool
#

proc ::Classy::WindowBuilder::defattredit {object w list wide {fill 1}} {
	private $object attredit
	catch {unset attredit}
	set c [$object current]
	eval destroy [winfo children $w]
	Classy::cleargrid $w
	set row 0
	foreach {option title resize } $list {
		set win $w.w$row
		frame $win
		$object _createattributeedit $win $option $title $wide
		grid $win -sticky nwse -row [incr row] -column 0
		grid rowconfigure $w $row -weight $resize
	}
	grid columnconfigure $w 0 -weight 1
	if $fill {grid rowconfigure $w [incr row] -weight 1}
	return $row
}

