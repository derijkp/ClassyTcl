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
# These will be added to tclIndex by Classy::auto_mkindex
#auto_index Selector

catch {auto_load Classy::ScrolledText}
option add *Classy::Selector.highlightThickness 0 widgetDefault

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Selector
Classy::export Selector {}

Classy::Selector classmethod init {args} {
	super init
	
	# REM Initialise variables
	# ------------------------
	private $object var num
	set num 1
	set var {}
	
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {Selector options -variable} option {-variable variable Variable} descr {
#}
Classy::Selector addoption -variable {variable Variable {}} {
	Classy::todo $object redraw
}

#doc {Selector options -type} option {-type type Type} descr {
#}
Classy::Selector addoption -type {type Type {}} {
	set list {int line text color font key mouse anchor justify bool orient relief select sticky}
	if {[lsearch $list [lindex $value 0]] == -1} {return -code error "Unknown type \"$value\""}
	Classy::todo $object redraw
}

#doc {Selector options -orient} option {-orient orient Orient} descr {
#}
Classy::Selector addoption -orient {orient Orient horizontal} {
	Classy::todo $object redraw
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

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Selector method destroy {} {
	private $object ctrace
	catch {eval trace vdelete $ctrace}
}

#doc {Selector command set} cmd {
#pathname set item
#} descr {
#}
Classy::Selector method set {item} {
	private $object options
	catch {Classy::handletodo $object}
	if {"$options(-variable)" == ""} {
		set varname [privatevar $object var]
	} else {
		set varname $options(-variable)
	}
	uplevel #0 [list set $varname $item]
	if {"$options(-type)" == "sticky"} {
		$object _stickyset $item
	}
	Classy::todo $object redraw
}

#doc {Selector command get} cmd {
#pathname get 
#} descr {
#}
Classy::Selector method get {} {
	private $object options
	catch {Classy::handletodo $object}
	if {"$options(-variable)" == ""} {
		set varname [privatevar $object var]
	} else {
		set varname $options(-variable)
	}
	return [set ::$varname]
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

Classy::Selector method _trace {args} {
	private $object trace
	if {"$trace" != ""} {
		eval $trace
	}
}

Classy::Selector method redraw {} {
	private $object options trace ctrace
	if {"$options(-variable)" == ""} {
		set var [privatevar $object var]
	} else {
		set var ::$options(-variable)
	}
	catch {eval trace vdelete $ctrace}
	set ctrace [list $var w "$object _trace"]
	trace variable $var w "$object _trace"
	set trace ""
	eval destroy [winfo children $object]
	Classy::cleargrid $object
	set v $object
	set title $options(-label)
	set wide 0
	switch [lindex $options(-type) 0] {
		int {
			Classy::NumEntry $object.value -label $title -labelwidth $options(-labelwidth) \
				-textvariable $var -command "$object _command" -orient $options(-orient)
			grid $v.value -row 0 -column 0 -sticky nwe
			grid columnconfigure $v 0 -weight 1
			grid rowconfigure $object 0 -weight 1
		}
		line {
			Classy::Entry $object.value -label $title -labelwidth $options(-labelwidth) \
				-textvariable $var -command "$object _command" -orient $options(-orient)
			grid $v.value -row 0 -column 0 -sticky nwe
			grid columnconfigure $v 0 -weight 1
			grid rowconfigure $object 0 -weight 1
		}
		text {
			if ![info exists $var] {set $var ""}
			set title $options(-label)
			button $object.change -text "$title" -command [varsubst {object var title} {
				set $var [string trimright [$object.value get]]
				$object.change configure -text $title
				$object.value textchanged 0
				$object _command [set $var]
			}]
			button $object.edit -text "Edit" -command [varsubst {object title} {
				set w [edit]
				wm title $w $title
				$w.editor configure -savecommand [list invoke {object w} {
					$object.change invoke
					$w.editor textchanged 0
				} $object $w]
				$w.editor.edit link $object.value
			}]
			Classy::ScrolledText $object.value -wrap none -width 5 -height 2
			bind $object.value <<Save>> "$object.change invoke"
			bind $object.value <<Empty>> "$object.value set {}"
			grid $object.change -row 2 -column 0 -sticky we
			grid $object.edit -row 2 -column 1 -sticky we
			grid $object.value -row 3 -column 0 -sticky nswe -columnspan 2
			grid columnconfigure $object 0 -weight 1
			grid rowconfigure $object 3 -weight 1
			$object.value set [set $var]
			$object.value textchanged 0
			$object.value configure -changedcommand [varsubst {object title} {
				$object.change configure -text [concat Change $title *]
			}]
			set trace [varsubst {object var title} {
				$object.value set [set $var]
			}]
		}
		color {
			set temp [Classy::optionget $object colorList ColorList]
			regsub -all "\n" $temp { } temp
			Classy::Default set app selector_color [eval concat $temp]
			Classy::Entry $object.value -textvariable $var \
				-default selector_color \
				-command [list invoke value "$object _command \$value ; $v.sample configure -bg \[Classy::realcolor \$value\]"]
			$v.value configure -label $title
			label $v.sample -text sample
			button $v.select -text "Select color" -command "$v.value set \[Classy::getcolor -initialcolor \[$v.value get\]\]"
			grid $v.value -row 2 -column 1 -sticky we
			grid $v.select -row 2 -column 0 -sticky nwe
			grid $v.sample -row 3 -column 0 -sticky nwe -columnspan 2
			grid columnconfigure $v 1 -weight 1
			grid rowconfigure $v 3 -weight 1
			catch {$v.sample configure -bg [Classy::realcolor [set $var]]}
			bind $v.sample <<Drag>> {
				DragDrop start %X %Y [[winfo parent %W] get]
			}
		}
		font {
			Classy::Entry $object.value -textvariable $var \
				-command [list invoke value "$object _command \$value ; $v.sample configure -font \[Classy::realfont \$value\]"]
			$v.value configure -label $title
			label $v.sample -text "ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789"
			button $v.select -text "Select font" -command "$v.value set \[Classy::getfont -font \[$v.value get\]\]"
			grid $v.value -row 2 -column 1 -sticky we
			grid $v.select -row 2 -column 0 -sticky nwe
			grid $v.sample -row 3 -column 0 -sticky nwe -columnspan 2
			grid columnconfigure $v 1 -weight 1
			grid rowconfigure $v 3 -weight 1
			catch {$v.sample configure -font [Classy::realfont [set $var]]}
			bind $v.sample <<Drag>> {
				DragDrop start %X %Y [[winfo parent %W] get]
			}
		}
		key {
			Classy::Entry $object.value -label $title \
				-textvariable $var -command "$object _command" -orient $options(-orient)
			grid $v.value -row 0 -column 0 -sticky nwe
			grid columnconfigure $v 0 -weight 1
			grid rowconfigure $object 0 -weight 1
		}
		mouse {
			Classy::Entry $object.value -label $title \
				-textvariable $var -command "$object _command" -orient $options(-orient)
			grid $v.value -row 0 -column 0 -sticky nwe
			grid columnconfigure $v 0 -weight 1
			grid rowconfigure $object 0 -weight 1
		}
		anchor {
			Classy::Entry $object.value -textvariable $var \
				-command "$object _command" -label $title -orient vertical \
				-orient vertical
			set row 0
			set column 0
			frame $v.select
			foreach {type icon} {nw anchor_nw n anchor_n ne anchor_ne w anchor_w center anchor_center e anchor_e sw anchor_sw s anchor_s se anchor_se} {
				radiobutton $v.select.$type -indicatoron 0 -text $type \
					-image [Classy::geticon $icon] \
					-command "$v.value set $type" -value $type \
					-variable $var
				grid $v.select.$type -row $row -column $column -sticky we
				incr column
				if {$column == 3} {set column 0;incr row}
			}
			$v.select.center configure -text c
			grid $v.select -row 0 -column 0 -sticky nwe
			grid $v.value -row 0 -column 1 -sticky nwe
			grid columnconfigure $v 1 -weight 1
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
				-command "$object _command" -label $title -orient $options(-orient)
			$v.value configure -label $title
			set column 0
			foreach {type icon} $list {
				radiobutton $object.$type -indicatoron 0 -text $type \
					-image [Classy::geticon $icon] \
					-command  "$v.value set $type" -value $type \
					-variable $var
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
				-command "$object _command" -label $title -orient $options(-orient)
			$v.value configure -label $title
			set column 0
			foreach {type} $list {
				radiobutton $object.b$type -indicatoron 0 -text $type \
					-command  "$v.value set $type" -value $type \
					-variable $var
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
				-orient vertical
			frame $v.select
			grid $v.select -row 6 -column 0
			checkbutton $v.select.n -image [Classy::geticon Builder/sticky_n] -indicatoron 0 -anchor c \
				-variable [privatevar $object sticky(n)] \
				-command "$object _stickyset"
			checkbutton $v.select.s -image [Classy::geticon Builder/sticky_s] -indicatoron 0 -anchor c \
				-variable [privatevar $object sticky(s)] \
				-command "$object _stickyset"
			checkbutton $v.select.e -image [Classy::geticon Builder/sticky_e] -indicatoron 0 -anchor c \
				-variable [privatevar $object sticky(e)] \
				-command "$object _stickyset"
			checkbutton $v.select.w -image [Classy::geticon Builder/sticky_w] -indicatoron 0 -anchor c \
				-variable [privatevar $object sticky(w)] \
				-command "$object _stickyset"
			button $v.select.all -image [Classy::geticon Builder/sticky_all] -anchor c \
				 -command "$object.value set nesw"
			button $v.select.none -image [Classy::geticon Builder/sticky_none] -anchor c \
				 -command "$object.value set {}"
			button $v.select.we -image [Classy::geticon Builder/sticky_we] -anchor c \
				 -command "$object.value set we"
			button $v.select.ns -image [Classy::geticon Builder/sticky_ns] -anchor c \
				 -command "$object.value set ns"
			grid $v.select.none -row 7 -column 1 -sticky we
			grid $v.select.n -row 6 -column 1 -sticky we
			grid $v.select.s -row 8 -column 1 -sticky we
			grid $v.select.e -row 7 -column 2 -sticky we
			grid $v.select.w -row 7 -column 0 -sticky e
			grid $v.select.we -row 6 -column 3 -sticky e
			grid $v.select.ns -row 7 -column 3 -sticky e
			grid $v.select.all -row 8 -column 3 -sticky e
			grid $v.select -row 0 -column 0 -sticky nwe
			grid $v.value -row 0 -column 1 -sticky nwe
			grid columnconfigure $v 1 -weight 1
			grid rowconfigure $object 2 -weight 1
			$object _stickyset [$v.value get]
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

