#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::Selector
# ----------------------------------------------------------------------
#doc Selector title {
#Selector
#} index {
# Selectors
#} shortdescr {
# select relief, justify, ...
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# creates an selector, a widget to select relief, justify, etc.
#}
#doc {Selector options} h2 {
#	Selector specific options
#}
#doc {Selector command} h2 {
#	Selector specific methods
#}

catch {auto_load Classy::ScrolledText}
option add *Classy::Selector.highlightThickness 0 widgetDefault

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Selector

Classy::Selector method init {args} {
	super init
	
	# REM Initialise variables
	# ------------------------
	private $object var num
	set num 1
	set var [privatevar $object value]
	upvar $var v
	set v {}
	
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {Selector options -type} option {-type type Type} descr {
#}
Classy::Selector addoption -type {type Type {}} {
	set list {int line text color font key mouse menu anchor justify bool orient relief select sticky}
	if {[lsearch $list [lindex $value 0]] == -1} {return -code error "Unknown type \"$value\""}
	Classy::todo $object draw
}

#doc {Selector options -variable} option {-variable variable Variable} descr {
#}
Classy::Selector addoption -variable {variable Variable {}} {
	private $object var
	if ![string length $value] {
		set var [privatevar $object value]
	} else {
		set var ::[string trimleft $value :]
	}
	upvar #0 $var var
	if ![info exists var] {set var {}}
	Classy::todo $object redraw
	catch {$object _textchanged 0}
}

#doc {Selector options -orient} option {-orient orient Orient} descr {
#}
Classy::Selector addoption -orient {orient Orient horizontal} {
	Classy::todo $object draw
}

#doc {Selector options -command} option {-command command Command} descr {
#}
Classy::Selector addoption -command {command Command {}} {
}

#doc {Entry options -label} option {-label label Label} descr {
#}
Classy::Selector addoption -label {label Label {}} {
	Classy::todo $object redraw
}

#doc {Entry options -labelwidth} option {-labelwidth labelWidth LabelWidth} descr {
# width of the label
#}
Classy::Selector addoption -labelwidth {labelWidth LabelWidth {}} {
	Classy::todo $object redraw
}

#doc {Selector options -state} option {-state state State} descr {
#}
Classy::Selector addoption -state {state State normal} {
	Classy::todo $object redraw
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {Selector command set} cmd {
#pathname set item
#} descr {
#}
Classy::Selector method set {value} {
	private $object options var
	upvar #0 $var v
	catch {Classy::handletodo $object}
	set v $value
	if [string_equal $options(-type)" "sticky"] {
		$object _stickyset $value
	}
	Classy::todo $object redraw
}

#doc {Selector command get} cmd {
#pathname get 
#} descr {
#}
Classy::Selector method get {} {
	private $object var
	upvar #0 $var v
	catch {Classy::handletodo $object}
	return $v
}

Classy::Selector method _command {value} {
	private $object options
	if {"$options(-type)" == "sticky"} {
		$object _stickyset $value
	}
	if {"$options(-command)" != ""} {
		uplevel #0 $options(-command) [list $value]
	}
}

Classy::Selector method redraw {} {
	private $object options var
	upvar #0 $var v
	if ![winfo exists $object.value] {
		$object draw
	}
	set title $options(-label)
	set wide 0
	switch [lindex $options(-type) 0] {
		int {
			$object.value configure -label $title -labelwidth $options(-labelwidth) \
				-textvariable $var -command "$object _command" -orient $options(-orient) \
				-state $options(-state)
		}
		line {
			$object.value configure -label $title -labelwidth $options(-labelwidth) \
				-textvariable $var -command "$object _command" -orient $options(-orient) \
				-state $options(-state)
		}
		text {
			if ![info exists v] {set v ""}
			set title $options(-label)
			$object.change configure -text "$title" \
				-command [list $object _textset] \
				-state $options(-state)
			$object.edit configure -text "Edit" \
				-command [list $object _textedit] \
				-state $options(-state)
			$object.value configure -wrap none -width 5 -height 2 \
				-state $options(-state) \
				-changedcommand [list $object _textchanged]
			$object.value set $v
			$object.value textchanged 0
		}
		menu {
			if ![info exists v] {set v ""}
			set title $options(-label)
			$object.change configure -text "$title" \
				-command [list $object _textset] \
				-state $options(-state)
			$object.edit configure -text "Menu Editor" \
				-command [list $object _menuedit] \
				-state $options(-state)
			$object.value configure -wrap none -width 5 -height 2 \
				-state $options(-state) \
				-changedcommand [list $object _textchanged]
			$object.value set $v
			$object.value textchanged 0
		}
		color {
			$object.value configure -textvariable $var \
				-command [list invoke value "$object _command \$value ; $object.sample configure -bg \[Classy::realcolor \$value\]"] \
				-state $options(-state)
			$object.value configure -label $title \
				-state $options(-state)
			$object.select configure -text "Select color" -command "$object.value set \[Classy::getcolor -initialcolor \[$object.value get\]\]" \
				-state $options(-state)
			catch {$object.sample configure -bg [Classy::realcolor $v]}
		}
		font {
			$object.value configure -textvariable $var \
				-command [list invoke value "$object _command \$value ; $object.sample configure -font \[Classy::realfont \$value\]"] \
				-state $options(-state)
			$object.value configure -state $options(-state)
			$object.select configure -command "$object.value set \[Classy::getfont -font \[$object.value get\]\]" \
				-state $options(-state)
			catch {$object.sample configure -font [Classy::realfont $v]}
		}
		key {
			$object.value configure -label $title \
				-textvariable $var -command "$object _command" -orient $options(-orient) \
				-state $options(-state)
		}
		mouse {
			$object.value configure -label $title \
				-textvariable $var -command "$object _command" -orient $options(-orient) \
				-state $options(-state)
		}
		anchor {
			$object.value configure -textvariable $var \
				-command "$object _command" -label $title -orient vertical \
				-orient vertical \
				-state $options(-state)
			foreach {type} {nw n ne w center e sw s se} {
				$object.select.$type configure \
					-command "$object.value set $type" -value $type \
					-variable $var \
					-state $options(-state)
			}
			$object.select.center configure -text c
		}
		justify - bool - orient - relief {
			array set lists {
				justify {left justify_left center justify_center right justify_right}
				bool {1 true 0 false}
				orient {horizontal orient_horizontal vertical orient_vertical}
				relief {raised relief_raised sunken relief_sunken flat relief_flat ridge relief_ridge solid relief_solid groove relief_groove}
			}
			set list $lists($options(-type))
			$object.value configure -textvariable $var \
				-command "$object _command" -label $title -orient $options(-orient) \
				-state $options(-state)
			$object.value configure -label $title
			foreach {type icon} $list {
				$object.$type configure \
					-command  "$object.value set $type" -value $type \
					-variable $var \
					-state $options(-state)
			}
		}
		select {
			set list [lrange $options(-type) 1 end]
			$object.value configure -textvariable $var \
				-command "$object _command" -label $title -orient $options(-orient) \
				-state $options(-state)
			$object.value configure -label $title \
				-state $options(-state)
			foreach {type} $list {
				radiobutton $object.b$type \
					-command  "$object.value set $type" -value $type \
					-variable $var \
					-state $options(-state)
			}
		}
		sticky {
			$object.value configure -textvariable $var \
				-command "$object _command" \
				-state $options(-state)
			$object.select.n configure \
				-variable [privatevar $object sticky(n)] \
				-state $options(-state)
			$object.select.s configure \
				-variable [privatevar $object sticky(s)] \
				-state $options(-state)
			$object.select.e configure \
				-variable [privatevar $object sticky(e)] \
				-state $options(-state)
			$object.select.w configure \
				-variable [privatevar $object sticky(w)] \
				-state $options(-state)
			$object.select.all configure -state $options(-state)
			$object.select.none configure -state $options(-state)
			$object.select.we configure -state $options(-state)
			$object.select.ns configure -state $options(-state)
			$object _stickyset [$object.value get]
		}
	}
	Classy::canceltodo $object redraw
}

Classy::Selector method _stickyset {args} {
	private $object sticky
	if {"$args" == ""} {
		set value ""
		foreach dir {n s e w} {
			if $sticky($dir) {
				append value $dir
			}
		}
		$object.value set $value
	} else {
		set value [lindex $args 0]
		foreach dir {n s e w} {
			if {[string first $dir $value] != -1} {
				set sticky($dir) 1
			} else {
				set sticky($dir) 0
			}
		}
		$object.value nocmdset $value
	}
}

Classy::Selector method _textset {} {
	private $object options var
	set title $options(-label)
	upvar #0 $var v
	set v [string trimright [$object.value get]]
	$object.change configure -text $title
	$object.value textchanged 0
	$object _command $v
}

Classy::Selector method _textedit {} {
	private $object options var
	set title $options(-label)
	upvar #0 $var v
	set w [Classy::edit]
	wm title $w $title
	$w.editor configure -savecommand [list $object _texteditdone $w]
	$w.editor.edit set [$object.value get]
}

Classy::Selector method _texteditdone {w value} {
	catch {$w.editor editchanged 0}
	catch {$w changed 0}
	$object.value set $value
}

Classy::Selector method _textchanged {args} {
	private $object var
	upvar #0 $var var
	set var [$object.value get]
	set title [$object.change cget -text]
	if ![regexp { \*$} $title] {
		$object.change configure -text "$title *"
	}
}

Classy::Selector method _menuedit {} {
	private $object options var
	set title $options(-label)
	upvar #0 $var v
	catch {destroy $object.menueditor}
	Classy_menueditor $object.menueditor
	wm title $object.menueditor "Menu Editor: $title"
	$object.menueditor configure -savecommand [list $object _texteditdone $object.menueditor]
	set value [$object.value get]
	if ![llength $value] {
		set value {menu File {}}
	}
	$object.menueditor load $value
}

Classy::Selector method draw {} {
	private $object options var
	upvar #0 $var v
	eval destroy [winfo children $object]
	Classy::cleargrid $object
	set title $options(-label)
	set wide 0
	switch [lindex $options(-type) 0] {
		int {
			Classy::NumEntry $object.value -label $title -labelwidth $options(-labelwidth) \
				-textvariable $var -command "$object _command" -orient $options(-orient) \
				-state $options(-state)
			grid $object.value -row 0 -column 0 -sticky nwe
			grid columnconfigure $object 0 -weight 1
			grid rowconfigure $object 0 -weight 1
		}
		line {
			Classy::Entry $object.value -label $title -labelwidth $options(-labelwidth) \
				-textvariable $var -command "$object _command" -orient $options(-orient) \
				-state $options(-state)
			grid $object.value -row 0 -column 0 -sticky nwe
			grid columnconfigure $object 0 -weight 1
			grid rowconfigure $object 0 -weight 1
		}
		text {
			if ![info exists v] {set v ""}
			set title $options(-label)
			button $object.change -text "$title" \
				-command [list $object _textset] \
				-state $options(-state)
			button $object.edit -text "Edit" \
				-command [list $object _textedit] \
				-state $options(-state)
			Classy::ScrolledText $object.value -wrap none -width 5 -height 2 \
				-state $options(-state) \
				-changedcommand [list $object _textchanged]
			bind $object.value <<Save>> "$object _textset ; break"
			bind $object.value <<Empty>> "$object.value set {} ; break"
			grid $object.change -row 2 -column 0 -sticky we
			grid $object.edit -row 2 -column 1 -sticky we
			grid $object.value -row 3 -column 0 -sticky nswe -columnspan 2
			grid columnconfigure $object 0 -weight 1
			grid rowconfigure $object 3 -weight 1
			$object.value set $v
			$object.value textchanged 0
		}
		menu {
			if ![info exists v] {set v ""}
			set title $options(-label)
			button $object.change -text "$title" \
				-command [list $object _textset] \
				-state $options(-state)
			button $object.edit -text "Menu Editor" \
				-command [list $object _menuedit] \
				-state $options(-state)
			Classy::ScrolledText $object.value -wrap none -width 5 -height 2 \
				-state $options(-state) \
				-changedcommand [list $object _textchanged]
			bind $object.value <<Save>> "$object _textset ; break"
			bind $object.value <<Empty>> "$object.value set {} ; break"
			grid $object.change -row 2 -column 0 -sticky we
			grid $object.edit -row 2 -column 1 -sticky we
			grid $object.value -row 3 -column 0 -sticky nswe -columnspan 2
			grid columnconfigure $object 0 -weight 1
			grid rowconfigure $object 3 -weight 1
			$object.value set $v
			$object.value textchanged 0
		}
		color {
			set temp [Classy::optionget $object colorList ColorList]
			regsub -all "\n" $temp { } temp
			Classy::Entry $object.value -textvariable $var \
				-combo 10 \
				-combopreset [list echo [eval concat $temp]] \
				-command [list invoke value "$object _command \$value ; $object.sample configure -bg \[Classy::realcolor \$value\]"] \
				-state $options(-state)
			$object.value configure -label $title \
				-state $options(-state)
			label $object.sample -text sample
			button $object.select -text "Select color" -command "$object.value set \[Classy::getcolor -initialcolor \[$object.value get\]\]" \
				-state $options(-state)
			grid $object.value -row 2 -column 1 -sticky we
			grid $object.select -row 2 -column 0 -sticky nwe
			grid $object.sample -row 3 -column 0 -sticky nwe -columnspan 2
			grid columnconfigure $object 1 -weight 1
			grid rowconfigure $object 3 -weight 1
			catch {$object.sample configure -bg [Classy::realcolor $v]}
			bind $object.sample <<Drag>> {
				Classy::DragDrop start %X %Y [[winfo parent %W] get]
			}
		}
		font {
			Classy::Entry $object.value -textvariable $var \
				-command [list invoke value "$object _command \$value ; $object.sample configure -font \[Classy::realfont \$value\]"] \
				-state $options(-state)
			$object.value configure -label $title \
				-state $options(-state)
			label $object.sample -text "ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789"
			button $object.select -text "Select font" -command "$object.value set \[Classy::getfont -font \[$object.value get\]\]" \
				-state $options(-state)
			grid $object.value -row 2 -column 1 -sticky we
			grid $object.select -row 2 -column 0 -sticky nwe
			grid $object.sample -row 3 -column 0 -sticky nwe -columnspan 2
			grid columnconfigure $object 1 -weight 1
			grid rowconfigure $object 3 -weight 1
			catch {$object.sample configure -font [Classy::realfont $v]}
			bind $object.sample <<Drag>> {
				Classy::DragDrop start %X %Y [[winfo parent %W] get]
			}
		}
		key {
			Classy::Entry $object.value -label $title \
				-textvariable $var -command "$object _command" -orient $options(-orient) \
				-state $options(-state)
			grid $object.value -row 0 -column 0 -sticky nwe
			grid columnconfigure $object 0 -weight 1
			grid rowconfigure $object 0 -weight 1
		}
		mouse {
			Classy::Entry $object.value -label $title \
				-textvariable $var -command "$object _command" -orient $options(-orient) \
				-state $options(-state)
			grid $object.value -row 0 -column 0 -sticky nwe
			grid columnconfigure $object 0 -weight 1
			grid rowconfigure $object 0 -weight 1
		}
		anchor {
			Classy::Entry $object.value -textvariable $var \
				-command "$object _command" -label $title -orient vertical \
				-orient vertical \
				-state $options(-state)
			set row 0
			set column 0
			frame $object.select
			foreach {type icon} {nw anchor_nw n anchor_n ne anchor_ne w anchor_w center anchor_center e anchor_e sw anchor_sw s anchor_s se anchor_se} {
				radiobutton $object.select.$type -indicatoron 0 -text $type \
					-image [Classy::geticon $icon] \
					-command "$object.value set $type" -value $type \
					-variable $var \
					-state $options(-state)
				grid $object.select.$type -row $row -column $column -sticky we
				incr column
				if {$column == 3} {set column 0;incr row}
			}
			$object.select.center configure -text c
			grid $object.select -row 0 -column 0 -sticky nwe
			grid $object.value -row 0 -column 1 -sticky nwe
			grid columnconfigure $object 1 -weight 1
			grid rowconfigure $object 2 -weight 1
		}
		justify - bool - orient - relief {
			array set lists {
				justify {left justify_left center justify_center right justify_right}
				bool {1 true 0 false}
				orient {horizontal orient_horizontal vertical orient_vertical}
				relief {raised relief_raised sunken relief_sunken flat relief_flat ridge relief_ridge solid relief_solid groove relief_groove}
			}
			set list $lists($options(-type))
			Classy::Entry $object.value -textvariable $var \
				-command "$object _command" -label $title -orient $options(-orient) \
				-state $options(-state)
			$object.value configure -label $title
			set column 0
			foreach {type icon} $list {
				radiobutton $object.$type -indicatoron 0 -text $type \
					-image [Classy::geticon $icon] \
					-command  "$object.value set $type" -value $type \
					-variable $var \
					-state $options(-state)
				grid $object.$type -row 0 -column $column -sticky nwe
				incr column
			}
			if {"$options(-orient)" == "vertical"} {
				grid $object.value -row 1 -column 0 -columnspan [expr {$column+1}] -sticky nwe
				grid rowconfigure $object 1 -weight 1
			} else {
				grid $object.value -row 0 -column $column -sticky nwe
				grid rowconfigure $object 0 -weight 1
			}
			grid columnconfigure $object $column -weight 1
		}
		select {
			set list [lrange $options(-type) 1 end]
			Classy::Entry $object.value -textvariable $var \
				-command "$object _command" -label $title -orient $options(-orient) \
				-state $options(-state)
			$object.value configure -label $title \
				-state $options(-state)
			set column 0
			foreach {type} $list {
				radiobutton $object.b$type -indicatoron 0 -text $type \
					-command  "$object.value set $type" -value $type \
					-variable $var \
					-state $options(-state)
				grid $object.b$type -row 0 -column $column -sticky nwe
				incr column
			}
			if {"$options(-orient)" == "vertical"} {
				grid $object.value -row 1 -column 0 -columnspan [expr {$column+1}] -sticky nwe
				grid rowconfigure $object 1 -weight 1
			} else {
				grid $object.value -row 0 -column $column -sticky nwe
				grid rowconfigure $object 0 -weight 1
			}
			grid columnconfigure $object $column -weight 1
		}
		sticky {
			Classy::Entry $object.value -textvariable $var \
				-command "$object _command" -label $title -orient vertical \
				-orient vertical \
				-state $options(-state)
			frame $object.select
			grid $object.select -row 6 -column 0
			checkbutton $object.select.n -image [Classy::geticon Builder/sticky_n] -indicatoron 0 -anchor c \
				-variable [privatevar $object sticky(n)] \
				-command "$object _stickyset" \
				-state $options(-state)
			checkbutton $object.select.s -image [Classy::geticon Builder/sticky_s] -indicatoron 0 -anchor c \
				-variable [privatevar $object sticky(s)] \
				-command "$object _stickyset" \
				-state $options(-state)
			checkbutton $object.select.e -image [Classy::geticon Builder/sticky_e] -indicatoron 0 -anchor c \
				-variable [privatevar $object sticky(e)] \
				-command "$object _stickyset" \
				-state $options(-state)
			checkbutton $object.select.w -image [Classy::geticon Builder/sticky_w] -indicatoron 0 -anchor c \
				-variable [privatevar $object sticky(w)] \
				-command "$object _stickyset" \
				-state $options(-state)
			button $object.select.all -image [Classy::geticon Builder/sticky_all] -anchor c \
				-command "$object.value set nesw" \
				-state $options(-state)
			button $object.select.none -image [Classy::geticon Builder/sticky_none] -anchor c \
				-command "$object.value set {}" \
				-state $options(-state)
			button $object.select.we -image [Classy::geticon Builder/sticky_we] -anchor c \
				-command "$object.value set we" \
				-state $options(-state)
			button $object.select.ns -image [Classy::geticon Builder/sticky_ns] -anchor c \
				-command "$object.value set ns" \
				-state $options(-state)
			grid $object.select.none -row 7 -column 1 -sticky we
			grid $object.select.n -row 6 -column 1 -sticky we
			grid $object.select.s -row 8 -column 1 -sticky we
			grid $object.select.e -row 7 -column 2 -sticky we
			grid $object.select.w -row 7 -column 0 -sticky e
			grid $object.select.we -row 6 -column 3 -sticky e
			grid $object.select.ns -row 7 -column 3 -sticky e
			grid $object.select.all -row 8 -column 3 -sticky e
			grid $object.select -row 0 -column 0 -sticky nwe
			grid $object.value -row 0 -column 1 -sticky nwe
			grid columnconfigure $object 1 -weight 1
			grid rowconfigure $object 2 -weight 1
			$object _stickyset [$object.value get]
		}
	}
	Classy::canceltodo $object draw
}

