#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Table
# ----------------------------------------------------------------------
#doc Table title {
#Table
#} index {
# New widgets
#} shortdescr {
# a table ...
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# creates a table of entries or text fields. This acts much like a spreadsheet. It supports
# supports scrollbars using the normal methods. The table must have an associated getcommand 
# and setcommand. These are used to get the data to display in the table and te change data when it
# is edited in the table. The get and set commands 
# will be called with the following parameters:<br>
# <dl>
# <dt>getcommand object w row col
# <dd>the parameter object is the name of the table, the parameter w gives the window of the cell
# asCsociated with the row and column given in row and col.<br>
# The getcommand must return the value to be shown in the given cell. If the getcommand
# wishes to set the value itself (eg. in a text), it can return with a -code break, so
# that its return value will not be used.
# When the getcommand fails, the error message will be shown in the affected cell.
# <dt>setcommand object w row col value
# <dd>The setcommand takes one extra parameter: the new value of the cell.
# If the setcommand fails, the previous value will be restored.
# </dl>
#}
#doc {Table options} h2 {
#	Table specific options
#}
#doc {Table command} h2 {
#	Table specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Table {} {}
proc Table {} {}
}

option add *Classy::Table.base.Entry.highlightThickness 0 widgetDefault
option add *Classy::Table.base.Entry.borderWidth 1 widgetDefault
option add *Classy::Table.base.Text.highlightThickness 0 widgetDefault
option add *Classy::Table.base.Text.borderWidth 1 widgetDefault

option add *Classy::Table::xpane.width 1 widgetDefault
option add *Classy::Table::xpane.relief flat widgetDefault
option add *Classy::Table::xpane.cursor sb_h_double_arrow widgetDefault

option add *Classy::Table::ypane.height 1 widgetDefault
option add *Classy::Table::ypane.relief flat widgetDefault
option add *Classy::Table::ypane.cursor sb_v_double_arrow widgetDefault

proc Classy::Tableobject {w args} {
	eval [winfo parent [winfo parent $w]] $args
}

bind Classy::Table::xpane <<Action>> {Classy::Tableobject %W _startdrag x %W %X %Y}
bind Classy::Table::xpane <<Action-Motion>> {Classy::Tableobject %W _drag %W %X %Y}
bind Classy::Table::ypane <<Action>> {Classy::Tableobject %W _startdrag y %W %X %Y}
bind Classy::Table::ypane <<Action-Motion>> {Classy::Tableobject %W _drag %W %X %Y}

bind Classy::Table <Configure> {%W _redraw}

bind Classy::Table::all <FocusOut> {Classy::Tableobject %W _set %W;break}
bind Classy::Table::all <<TableUp>> {Classy::Tableobject %W movey %W -1;break}
bind Classy::Table::all <<TableDown>> {Classy::Tableobject %W movey %W 1;break}
bind Classy::Table::all <<TableLeft>> {Classy::Tableobject %W movex %W -1;break}
bind Classy::Table::all <<TableRight>> {Classy::Tableobject %W movex %W 1;break}
bind Classy::Table::all <<PasteSpecial>> {Classy::Tableobject %W paste;break}
bind Classy::Table::all <<PageUp>> {Classy::Tableobject %W yview scroll -1 page;break}
bind Classy::Table::all <<PageDown>> {Classy::Tableobject %W yview scroll 1 page;break}

bind Classy::Table::text <<SpecialFocusPrev>> {Classy::Tableobject %W movex %W -1;break}
bind Classy::Table::text <<SpecialFocusNext>> {Classy::Tableobject %W movex %W 1;break}
bind Classy::Table::text <FocusOut> {Classy::Tableobject %W _set %W;break}
bind Classy::Table::entry <<FocusPrev>> {Classy::Tableobject %W movex %W -1;break}
bind Classy::Table::entry <<FocusNext>> {Classy::Tableobject %W movex %W 1;break}
bind Classy::Table::entry <<Return>> {Classy::Tableobject %W _set %W ; Classy::Tableobject %W movey %W 1;break}
bind Classy::Table::entry <<Up>> {Classy::Tableobject %W movey %W -1;break}
bind Classy::Table::entry <<Down>> {Classy::Tableobject %W movey %W 1;break}
# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Table
Classy::export Table {}

Classy::Table classmethod init {args} {
	# REM Create object
	# -----------------
	super init
	$object configure -width 100 -height 100 -highlightthicknes 0 -bd 0
	frame $object.base -borderwidth 0
	grid $object.base -row 0 -column 0 -sticky nw
	grid columnconfigure $object 1 -weight 1
	grid rowconfigure $object 1 -weight 1
	grid propagate $object 0


	# REM set variables
	# -----------------
	private $object drow dcol redrawing ylabelcommand
	set redrawing 0
	set drow(start) 0
	set dcol(start) 0
	set dcol(num) 0
	set drow(num) 0
	set ylabelcommand ""

	# REM Configure initial arguments
	# -------------------------------
	if {[lsearch [lunmerge $args] -type] == -1} {
		lappend args -type entry
	}
	if {"$args" != ""} {eval $object configure $args}
#	Classy::todo $object _redraw
}

Classy::Table component book {$object.book}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {Table options -cols} option {-cols cols cols} descr {
# gives the number of columns in the table
#}
Classy::Table addoption -cols {cols cols 5} {
	if {$value < 1} {return -code error "-cols must be larger than 1"}
	Classy::todo $object _redraw
}
#doc {Table options -rows} option {-rows rows rows} descr {
# gives the number of rows in the table
#}
Classy::Table addoption -rows {rows Rows 20} {
	if {$value < 1} {return -code error "-rows must be larger than 1"}
	Classy::todo $object _redraw
}
#doc {Table options -colsize} option {-colsize colsize colsize} descr {
# gives the default column size
#}
Classy::Table addoption -colsize {colSize ColSize {}} {
	private $object options dcol
	if {"$value" == ""} {
		catch {destroy $object.temp}
		$options(-type) $object.temp
		set dcol(s) [winfo reqwidth $object.temp]
		destroy object.temp
	} else {
		set dcol(s) $value
	}
	Classy::todo $object _redraw
}
#doc {Table options -rowsize} option {-rowsize rowsize rowsize} descr {
# gives the default row size
#}
Classy::Table addoption -rowsize {rowSize RowSize {}} {
	private $object options drow
	if {"$value" == ""} {
		catch {destroy $object.temp}
		$options(-type) $object.temp
		set drow(s) [winfo reqheight $object.temp]
		destroy object.temp
	} else {
		set drow(s) $value
	}
	Classy::todo $object _redraw
}
#doc {Table options -type} option {-type type type} descr {
# gives the type of widgets in the table, must be entry or text
#}
Classy::Table addoption -type {type Type entry} {
	private $object options drow dcol
	catch {destroy $object.temp}
	entry $object.temp
	if {"$options(-rowsize)" == ""} {
		set drow(s) [winfo reqheight $object.temp]
	}
	if {"$options(-colsize)" == ""} {
		set dcol(s) [winfo reqwidth $object.temp]
	}
	set dcol(ls) $dcol(s)
	set drow(ls) $drow(s)
	destroy object.temp
	eval destroy [winfo children $object.base]
	set dcol(num) 0
	set drow(num) 0
	Classy::todo $object _redraw
}
#doc {Table options -xscrollcommand} option {-xscrollcommand xscrollcommand xscrollcommand} descr {}
Classy::Table addoption -xscrollcommand {xScrollCommand ScrollCommand {}} {}
#doc {Table options -yscrollcommand} option {-yscrollcommand yscrollcommand yscrollcommand} descr {}
Classy::Table addoption -yscrollcommand {yScrollCommand ScrollCommand {}} {}
#doc {Table options -getcommand} option {-getcommand getcommand getcommand} descr {
# gives the command that will be called to obtain the value of a given cell. It must have the 
# following format:<br>
# getcommand object w row col<br>
# The parameters given to the command when obtaining a value are the table objects name, the window
# name of the currently associated cell, the row and the column.<br>
# The getcommand must return the value to be shown in the given cell. If the getcommand
# wishes to set the value itself (eg. in a text), it can return with a -code break, so
# that its return value will not be used.
#}
Classy::Table addoption -getcommand {getCommand Command {}} {}

#doc {Table options -setcommand} option {-setcommand setcommand setcommand} descr {
# gives the command that will be called to set a given cell to a new value. It must have the 
# following format:<br>
# setcommand object w row col value<br>
# The parameters given to the command are the table objects name, the window
# name of the currently associated cell, the row, the column and the new value.
# If the setcommand fails, the previous value will be restored.
#}
Classy::Table addoption -setcommand {setCommand Command {}} {}

#doc {Table options -xlabelcommand} option {-xlabelCommand xLabelCommand Command} descr {
# If this option is empty, no xlabels will be displayed.
# Othwerwise, it gives the command that will be called to obtain the value of a given xlabel. 
# It must have the following format:<br>
# xlabelcommand object w col<br>
# The parameters given to the command when obtaining a value are the table objects name, the window
# name of the currently associated cell and the column.<br>
# The command normally returns the value to be shown in the given label. If the command
# returns with a -code break, its return value will not be used to set the label.
#}
Classy::Table addoption -xlabelcommand {xLabelCommand Command {}} {
	private $object dcol drow
	eval destroy [winfo children $object.base]
	set dcol(num) 0
	set drow(num) 0
	Classy::todo $object _redraw
}
#doc {Table options -ylabelcommand} option {-ylabelCommand yLabelCommand Command} descr {
# If this option is empty, no ylabels will be displayed.
# Othwerwise, it gives the command that will be called to obtain the value of a given ylabel. 
# It must have the following format:<br>
# ylabelcommand object w row<br>
# The parameters given to the command when obtaining a value are the table objects name, the window
# name of the currently associated cell and the row.<br>
# The command normally returns the value to be shown in the given label. If the command
# returns with a -code break, its return value will not be used to set the label.
#}
Classy::Table addoption -ylabelcommand {yLabelCommand Command {}} {
	private $object dcol drow
	eval destroy [winfo children $object.base]
	set dcol(num) 0
	set drow(num) 0
	Classy::todo $object _redraw
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {Table command colsize} cmd {
#pathname colsize col args
#} descr {
# query or change the current width of the given column
#}
Classy::Table method colsize {col args} {
	private $object dcol
	if {"$col" == "label"} {
		if {"$args" == ""} {
			return $dcol(ls)
		} else {
			set dcol(ls) [lindex $args 0]
		}
	}
	if {"$args" == ""} {
		if [info exists dcol(s,$col)] {
			return $dcol(s,$col)
		} else {
			return $dcol(s)
		}
	} else {
		set size [lindex $args 0]
		if {"$size" == ""} {
			unset dcol(s,$col)
		} else {
			set dcol(s,$col) $size
		}
	}
	$object _scheduleredraw
}

Classy::Table method _scheduleredraw {} {
	private $object redrawing
	if $redrawing {
		set redrawing 0
	} else {
		update
		Classy::todo $object _redraw
	}
}

#doc {Table command rowsize} cmd {
#pathname rowsize row ?value?
#} descr {
# query or change the current height of the given row
#}
Classy::Table method rowsize {row args} {
	private $object drow
	if {"$row" == "label"} {
		if {"$args" == ""} {
			return $drow(ls)
		} else {
			set drow(ls) [lindex $args 0]
		}
	}
	if {"$args" == ""} {
		if [info exists drow(s,$row)] {
			return $drow(s,$row)
		} else {
			return $drow(s)
		}
	} else {
		set size [lindex $args 0]
		if {"$size" == ""} {
			unset drow(s,$row)
		} else {
			set drow(s,$row) $size
		}
	}
	$object _scheduleredraw
}

#doc {Table command set} cmd {
#pathname set rrow rcol value
#} descr {
# set the value of the cell at $rrow and $rcol to $value
#}
Classy::Table method set {rrow rcol value} {
	private $object options drow dcol data
	set col [expr {$rcol-$dcol(start)}]
	set row [expr {$rrow-$drow(start)}]
	set error [catch {uplevel #0 $options(-setcommand) $object $object.base.e$row,$col $rrow $rcol [list $value]} res]
	$object refreshcell $rrow $rcol
	if $error {error $res}
}

Classy::Table method _set {w args} {
	private $object options drow dcol data
	regexp {([0-9]+),([0-9]+)$} $w temp row col
	switch $options(-type) {
		text {
			set value [$w get 1.0 end]
		}
		default {
			set value [$w get]
		}
	}
	set rcol [expr {$col+$dcol(start)}]
	set rrow [expr {$row+$drow(start)}]
	set ::Classy::table(object) $object
	set ::Classy::table(rrow) $rrow
	set ::Classy::table(rcol) $rcol
	set ::Classy::table(w) $object.base.e$row,$col
	set ::Classy::table(value) $value
	set error [catch {uplevel #0 $options(-setcommand) $object $object.base.e$row,$col $rrow $rcol [list $value]} res]
	$object refreshcell $rrow $rcol
	if $error {error $res}
}

#doc {Table command paste} cmd {
#pathname paste ?column ...?
#} descr {
# paste data in the table. The data must be a list where each element is a list that contains the values
# for one column. If no arguments are given, the data in the clipboard is pasted.
#}
Classy::Table method paste {args} {
	private $object options drow dcol
	if {"$args" == ""} {
		set data [selection get -displayof $object -selection CLIPBOARD]
	} else {
		set data $args
	}
	set w [focus -lastfor $object]
	regexp {([0-9]+),([0-9]+)$} $w temp row col
	set rcol [expr {$col+$dcol(start)}]
	foreach column $data {
		set rrow [expr {$row+$drow(start)}]
		foreach value $column {
			$object set $rrow $rcol $value
			incr rrow
		}
		incr rcol
	}
}

Classy::Table method selection {option args} {
	private $object selection dcol drow
	switch $option {
		add {
			if {[llength $args] != 4} {
				error "wrong # args: must be: \"$object selection add startrow startcol endrow endcol\""
			}
			foreach val $args var {startrow startcol endrow endcol} {
				set $var $val
			}
			for {set rcol $startcol} {$rcol <= $endcol} {incr rcol} {
				for {set rrow $startrow} {$rrow <= $endrow} {incr rrow} {
					set name [list $rrow $rcol]
					set col [expr {$rcol-$dcol(start)}]
					set row [expr {$rrow-$drow(start)}]
					if ![info exists selection($name)] {
						set w $object.base.e$row,$col
						if [winfo exists $w] {
							set selection($name) [list [$w cget -bg] [$w cget -fg]]
							$w configure -bg [Classy::optionget $w selectBackground Foreground] \
										-fg [Classy::optionget $w selectForeground Background]
						} else {
							set selection($name) {}
						}
					}
				}
			}
		}
		clear {
			foreach name [array names selection] {
				if {"$selection($name)" != ""} {
					set rrow [lindex $name 0]
					set rcol [lindex $name 1]
					set row [expr {$rrow-$drow(start)}]
					set col [expr {$rcol-$dcol(start)}]
					set w $object.base.e$row,$col
					catch {$w configure -bg [lindex $selection($name) 0] -fg [lindex $selection($name) 1]}
				}
			}
			unset selection
		}
		current {
			catch {unset a}
			set result ""
			foreach name [array names selection] {
				lappend a([lindex $name 1]) $name
			}
			foreach col [lsort -integer [array names a]] {
				lappend result [lsort -integer -index 0 $a($col)]
			}
			return $result
		}
		default {
			error "unknown option \"$option\""
		}
	}
}

#doc {Table command movey} cmd {
#pathname movey w step ?sel?
#} descr {
#
#}
Classy::Table method movey {w step args} {
	private $object options drow dcol
	regexp {([0-9]+),([0-9]+)$} $w temp row col
	set temp [expr {$row+$drow(start)+1}]
	if {($step > 0)&&($temp >= $options(-rows))} return
	set newrow [expr {$row + $step	}]
	set end [expr {$drow(num)-2}]
	if {$newrow >= $end} {
		set left [expr {$newrow - $end}]
		$object yview scroll $left
		focus $object.base.e$end,$col
	} elseif {$newrow < 0} {
		$object yview scroll $newrow
		focus $object.base.e0,$col
	} else {
		focus $object.base.e$newrow,$col
	}
	if {"$args" != ""} {
		set rrow [expr {$row+$drow(start)}]
		set rcol [expr {$col+$dcol(start)}]
		incr temp -1
		$object selection add $temp $rcol $rrow $rcol
	}
}

#doc {Table command movex} cmd {
#pathname movex w step ?sel?
#} descr {
# 
#}
Classy::Table method movex {w step args} {
	private $object options dcol
	regexp {([0-9]+),([0-9]+)$} $w temp row col
	set rcol [expr $col+$dcol(start)+1]
	if {($step > 0)&&($rcol >= $options(-cols))} return
	set newcol [expr {$col + $step	}]
	set end [expr {$dcol(num)-2}]
	if {$newcol >= $end} {
		set left [expr {$newcol - $end}]
		$object xview scroll $left
		focus $object.base.e$row,$end
	} elseif {$newcol < 0} {
		$object xview scroll $newcol
		focus $object.base.e$row,0
	} else {
		focus $object.base.e$row,$newcol
	}
}

Classy::Table method refreshcell {rrow rcol} {
	private $object options drow dcol data selection
	set col [expr {$rcol-$dcol(start)}]
	set row [expr {$rrow-$drow(start)}]
	set w $object.base.e$row,$col
	if ![winfo exists $w] return
	set code [catch {uplevel #0 $options(-getcommand) $object $w $rrow $rcol} new]
	if {$code == 1} {
		set new "ERROR: $new"
	} elseif {$code != 0} {
		unset new
	}
	if [info exists new] {
		switch $options(-type) {
			entry {
				set data($row,$col) $new
			}
			text {
				$w delete 1.0 end
				if {"$new" != ""} {$w insert 1.0 $new}
			}
		}
	}
	if [info exists selection([list $rrow $rcol])] {
		$w configure -bg [Classy::optionget $w selectBackground Foreground] \
				-fg [Classy::optionget $w selectForeground Background]
	}
}

proc Classy::Table__create_elem {object type row col} {
	switch $type {
		entry {
			entry $object.base.e$row,$col -width 1 -textvariable [privatevar $object data]($row,$col)
			bindtags $object.base.e$row,$col [list Classy::Table::all Classy::Table::entry $object.base.e$row,$col Entry . all]
		}
		text {
			text $object.base.e$row,$col -width 1 -height 0
			bindtags $object.base.e$row,$col [list Classy::Table::all Classy::Table::text $object.base.e$row,$col Text . all]
		}
	}
	grid $object.base.e$row,$col -row [expr {2*$row+2}] -column [expr {2*$col+2}] -sticky nwse
}

Classy::Table method _sethbar {} {
	private $object options dcol
	set curlow $dcol(start)
	set curhigh [expr {$dcol(start) + $dcol(num)}]
	set min 0
	set max $options(-cols)

	if {$curlow < $min} {set curlow $min}
	if {$curhigh < $min} {set curhigh $min}
	if {$curlow > $max} {set curlow $max}
	if {$curhigh > $max} {set curhigh $max}
	set realw [expr {$max - $min}]
	if {"$options(-xscrollcommand)" != ""} {
		eval $options(-xscrollcommand) {[expr double($curlow)/$realw] [expr {double($curhigh)/$realw}]}
	}
}

Classy::Table method _setvbar {} {
	private $object options drow
	set curlow $drow(start)
	set curhigh [expr {$drow(start) + $drow(num)}]
	set min 0
	set max $options(-rows)

	if {$curlow < $min} {set curlow $min}
	if {$curhigh < $min} {set curhigh $min}
	if {$curlow > $max} {set curlow $max}
	if {$curhigh > $max} {set curhigh $max}
	set realw [expr {$max - $min}]
	if {"$options(-yscrollcommand)" != ""} {
		eval $options(-yscrollcommand) {[expr {double($curlow)/$realw}] [expr {double($curhigh)/$realw}]}
	}
}

Classy::Table method _startdrag {dir w x y} {
	private $object drag dcol drow
	set drag(dir) $dir
	set drag(x) $x
	set drag(y) $y
	regexp {.base.[xy]pane(.+)$} $w temp drag(pos)
	if {"$dir"=="x"} {
		if {"$drag(pos)" != "label"} {
			set drag(pos) [expr {$drag(pos)+$dcol(start)}]
		}
		set drag(s) [$object colsize $drag(pos)]
	} else {
		if {"$drag(pos)" != "label"} {
			set drag(pos) [expr {$drag(pos)+$drow(start)}]
		}
		set drag(s) [$object rowsize $drag(pos)]
	}
}

Classy::Table method _drag {w x y} {
	private $object drag dcol drow
	if {"$drag(dir)"=="x"} {
		$object colsize $drag(pos) [expr $drag(s)+$x-$drag(x)]
	} else {
		$object rowsize $drag(pos) [expr $drag(s)+$y-$drag(y)]
	}
}

#doc {Table command _redraw} cmd {
#pathname _redraw 
#} descr {
#}
Classy::Table method _redraw {} {
	private $object options drow dcol data
	set ::Classy::table(object) $object
	if ![winfo exists $object.base.ypanelabel] {
		frame $object.base.ypanelabel -class Classy::Table::ypane
	}
	if ![winfo exists $object.base.xpanelabel] {
		frame $object.base.xpanelabel -class Classy::Table::xpane
	}
	$object _sethbar
	$object _setvbar
	set width [winfo width $object]
	set prevcol $dcol(num)
	set dcol(num) 0
	set rcol $dcol(start)	
	set panew [$object.base.xpanelabel cget -width]
	if {"$options(-ylabelcommand)" != ""} {
		set cs $dcol(ls)
		incr cs $panew
	} else {		
		set cs 0
	}

	while 1 {
		if [info exists dcol(s,$rcol)] {
			set size $dcol(s,$rcol)
		} else {
			set size $dcol(s)
		}
		incr cs $size
		incr cs $panew
		incr rcol
		incr dcol(num)
		if {$rcol == $options(-cols)} break
		if {$cs > $width} break
	}
	set colnum [expr {$dcol(num)-$prevcol}]
	set height [winfo height $object]
	set prevrow $drow(num)
	set drow(num) 0
	set rrow $drow(start)	
	set paneh [$object.base.ypanelabel cget -height]
	if {"$options(-ylabelcommand)" != ""} {
		set cs $drow(ls)
		incr cs $paneh
	} else {		
		set cs 0
	}
	while 1 {
		if [info exists drow(s,$rrow)] {
			set size $drow(s,$rrow)
		} else {
			set size $drow(s)
		}
		incr cs $size
		incr cs $paneh
		incr rrow
		incr drow(num)
		if {$rrow == $options(-rows)} break
		if {$cs > $height} break
	}
	set rownum [expr {$drow(num)-$prevrow}]

	set to $drow(num)
	if {$prevrow < $to} {set to $prevrow}
	if {$colnum > 0} {
		for {set col $prevcol} {$col < $dcol(num)} {incr col} {
			for {set row 0} {$row < $to} {incr row} {
				Classy::Table__create_elem $object $options(-type) $row $col
			}
			frame $object.base.xpane$col -class Classy::Table::xpane
		}
	} elseif {$colnum < 0} {
		for {set col $dcol(num)} {$col < $prevcol} {incr col} {
			for {set row 0} {$row < $prevrow} {incr row} {
				destroy $object.base.e$row,$col
			}
			destroy $object.base.xpane$col
		}
	}

	if {$rownum > 0} {
		for {set row $prevrow} {$row < $drow(num)} {incr row} {
			for {set col 0} {$col < $dcol(num)} {incr col} {
				Classy::Table__create_elem $object $options(-type) $row $col
			}
			frame $object.base.ypane$row -class Classy::Table::ypane
		}
	} elseif {$rownum < 0} {
		for {set row $drow(num)} {$row < $prevrow} {incr row} {
			for {set col 0} {$col < $prevcol} {incr col} {
				destroy $object.base.e$row,$col
			}
			destroy $object.base.ypane$row
		}
	}

	for {set row 0} {$row < $drow(num)} {incr row} {
		set pos [expr {2*$row+3}]
		grid $object.base.ypane$row -row 0 -row $pos -columnspan [expr {2*$dcol(num)+2}] -sticky nwse
		raise $object.base.ypane$row
	}
	for {set col 0} {$col < $dcol(num)} {incr col} {
		set pos [expr {2*$col+3}]
		grid $object.base.xpane$col -row 0 -column $pos -rowspan [expr {2*$drow(num)+2}] -sticky nwse
		raise $object.base.xpane$col
	}

	# labels
	if {"$options(-ylabelcommand)" != ""} {
		grid $object.base.ypanelabel -row 1 -column 0 -columnspan $dcol(num) -sticky nwse
		if {$rownum > 0} {
			for {set row $prevrow} {$row < $drow(num)} {incr row} {
				switch $options(-type) {
					entry {
						entry $object.base.yl$row -width 1 -relief flat -textvariable [privatevar $object data](yl$row)
					}
					text {
						text $object.base.yl$row -width 1 -height 0 -relief flat
					}
				}
				grid $object.base.yl$row -row [expr {2*$row+2}] -column 0 -sticky nwse
			}
		} elseif {$rownum < 0} {
			for {set row $drow(num)} {$row < $prevrow} {incr row} {
				destroy $object.base.yl$row
			}
		}
	} else {
		grid columnconfigure $object.base 0 -minsize 0
		grid columnconfigure $object.base 1 -minsize 0
	}
	if {"$options(-xlabelcommand)" != ""} {
		grid $object.base.xpanelabel -row 0 -column 1 -rowspan $drow(num) -sticky nwse
		if {$colnum > 0} {
			for {set col $prevcol} {$col < $dcol(num)} {incr col} {
				switch $options(-type) {
					entry {
						entry $object.base.xl$col -width 1 -relief flat -textvariable [privatevar $object data](xl$col)
					}
					text {
						text $object.base.xl$col -width 1 -height 0 -relief flat
					}
				}
				grid $object.base.xl$col -row 0 -column [expr {2*$col+2}] -sticky nwse
			}
		} elseif {$colnum < 0} {
			for {set col $dcol(num)} {$col < $prevcol} {incr col} {
				destroy $object.base.xl$col
			}
		}
	} else {
		grid rowconfigure $object.base 0 -minsize 0
		grid rowconfigure $object.base 1 -minsize 0
	}
	foreach name [array names selection] {
		if {"$selection($name)" != ""} {
			set rrow [lindex $name 0]
			set rcol [lindex $name 1]
			set row [expr {$rrow-$drow(start)}]
			set col [expr {$rcol-$dcol(start)}]
			set w $object.base.e$row,$col
			catch {$w configure -bg [lindex $selection($name) 0] -fg [lindex $selection($name) 1]}
		}
	}

	# sizes
	set rcol $dcol(start)
	for {set col 0} {$col < $dcol(num)} {incr col} {
		if [info exists dcol(s,$rcol)] {
			grid columnconfigure $object.base [expr {2*$col+2}] -minsize $dcol(s,$rcol)
		} else {
			grid columnconfigure $object.base [expr {2*$col+2}] -minsize $dcol(s)
		}
		incr rcol
	}
	set rrow $drow(start)
	for {set row 0} {$row < $drow(num)} {incr row} {
		if [info exists drow(s,$rrow)] {
			grid rowconfigure $object.base [expr {2*$row+2}] -minsize $drow(s,$rrow)
		} else {
			grid rowconfigure $object.base [expr {2*$row+2}] -minsize $drow(s)
		}
		incr rrow
	}

	# labels
	if {"$options(-ylabelcommand)" != ""} {
		grid columnconfigure $object.base 0 -minsize $dcol(ls)
		set rrow $drow(start)
		for {set row 0} {$row < $drow(num)} {incr row} {
			set code [catch {uplevel #0 $options(-ylabelcommand) $object $object.base.xl$col $rrow} new]
			if {$code == 1} {
				set new $rrow
			} elseif {$code != 0} {
				unset new
			}
			if [info exists new] {
				switch $options(-type) {
					entry {
						set data(yl$row) $new
					}
					text {
						$object.base.yl$row delete 1.0 end
						if {"$new" != ""} {$object.base.yl$row insert 1.0 $new}
					}
				}
#				$object.base.yl$row configure -text $new
			}
			incr rrow
		}
	}
	if {"$options(-xlabelcommand)" != ""} {
		grid rowconfigure $object.base 0 -minsize $drow(ls)
		set rcol $dcol(start)
		for {set col 0} {$col < $dcol(num)} {incr col} {
			set code [catch {uplevel #0 $options(-xlabelcommand) $object $object.base.xl$col $rcol} new]
			if {$code == 1} {
				set new $rcol
			} elseif {$code != 0} {
				unset new
			}
			if [info exists new] {
				switch $options(-type) {
					entry {
						set data(xl$col) $new
					}
					text {
						$object.base.xl$col delete 1.0 end
						if {"$new" != ""} {$object.base.xl$col insert 1.0 $new}
					}
				}
#				$object.base.xl$col configure -text $new
			}
			incr rcol
		}
	}
	$object _refreshtable
}

Classy::Table method _refreshtable {} {
	private $object options drow dcol data selection redrawing
	set ::Classy::table(object) $object
	foreach var {w rrow rcol} {
		upvar ::Classy::table($var) $var
	}
	#values
	set redrawing 1
	set rrow $drow(start)
	for {set row 0} {$row < $drow(num)} {incr row} {
		set rcol $dcol(start)
		for {set col 0} {$col < $dcol(num)} {incr col} {
			set w $object.base.e$row,$col
			if {($rrow >= $options(-rows))||($rcol >= $options(-cols))} {
				set new ""
			} else {
				set code [catch {uplevel #0 $options(-getcommand) $object $w $rrow $rcol} new]
				if {$code == 1} {
					set new "ERROR: $new"
				} elseif {$code != 0} {
					unset new
				}
			}
			if [info exists new] {
				switch $options(-type) {
					entry {
						set data($row,$col) $new
					}
					text {
						$w delete 1.0 end
						if {"$new" != ""} {$w insert 1.0 $new}
					}
				}
			}
			incr rcol
		}
		incr rrow
		update
		if !$redrawing {
			update
			$object _redraw
			return
		}
	}
	set redrawing 0
	foreach name [array names selection] {
		$object refreshcell [lindex $name 0] [lindex $name 1]
	}
}

#doc {Table command xview} cmd {
#pathname xview args
#} descr {
#}
Classy::Table method xview {args} {
	private $object options dcol
	set pagesize $dcol(num)
	set pos $dcol(start)
	set size $dcol(num)
	set min 0
	set max [expr {$options(-cols)-1}]

	switch [lindex $args 0] {
		"" {
			set end [expr {double($pos + $size)/$max}]
			if {$end > 1} {set end 1}
			return [list [expr {double($pos)/$max}] $end]
		}
		moveto {
			set fraction [lindex $args 1]
			set pos [expr $fraction*$max]
		}
		scroll {
			set number [lindex $args 1]
			set what [lindex $args 2]
			if {"$what"=="pages"} {
				set pos [expr {$pos + $number*$pagesize}]
			} else {
				set pos [expr {$pos + $number}]
			}
		}
	}
	if {$pos > $max} {set pos $max}
	if {$pos < 0} {set pos 0}

	set dcol(start) [expr int($pos)]
	$object _sethbar
	$object _scheduleredraw
}

#doc {Table command yview} cmd {
#pathname yview args
#} descr {
#}
Classy::Table method yview {args} {
	private $object options drow redrawing
	set pagesize $drow(num)
	set pos $drow(start)
	set size $drow(num)
	set min 0
	set max [expr {$options(-rows)-1}]

	switch [lindex $args 0] {
		"" {
			set end [expr {double($pos + $size)/$max}]
			if {$end > 1} {set end 1}
			return [list [expr {double($pos)/$max}] $end]
		}
		moveto {
			set fraction [lindex $args 1]
			set pos [expr $fraction*$max]
		}
		scroll {
			set number [lindex $args 1]
			set what [lindex $args 2]
			if {"$what"=="pages"} {
				set pos [expr {$pos + $number*$pagesize}]
			} else {
				set pos [expr {$pos + $number}]
			}
		}
	}
	if {$pos > $max} {set pos $max}
	if {$pos < 0} {set pos 0}

	set drow(start) [expr int($pos)]
	$object _setvbar
	$object _scheduleredraw
}

