#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Table
# ----------------------------------------------------------------------
#doc Table title {
#Table
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
# associated with the row and column given in row and col.<br>
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
catch {Classy::Table destroy}

option add *Classy::Table.base.Entry.highlightThickness 0 widgetDefault
option add *Classy::Table.base.Entry.borderWidth 1 widgetDefault

proc Classy::Tableobject {w args} {
	eval [winfo parent [winfo parent $w]] $args
}

bind Classy::Table::text <FocusOut> {Classy::Tableobject %W _set %W}
bind Classy::Table::text <Control-Up> {Classy::Tableobject %W movey %W -1}
bind Classy::Table::text <Control-Down> {Classy::Tableobject %W movey %W 1}
bind Classy::Table::text <Control-Left> {Classy::Tableobject %W movex %W -1}
bind Classy::Table::text <Control-Right> {Classy::Tableobject %W movex %W 1}

bind Classy::Table::entry <<Return>> {Classy::Tableobject %W _set %W ; Classy::Tableobject %W movey %W 1}
bind Classy::Table::entry <FocusOut> {Classy::Tableobject %W _set %W}
bind Classy::Table::entry <<Up>> {Classy::Tableobject %W movey %W -1}
bind Classy::Table::entry <<Down>> {Classy::Tableobject %W movey %W 1}
bind Classy::Table::entry <Control-Up> {Classy::Tableobject %W movey %W -1}
bind Classy::Table::entry <Control-Down> {Classy::Tableobject %W movey %W 1}
bind Classy::Table::entry <Control-Left> {Classy::Tableobject %W movex %W -1}
bind Classy::Table::entry <Control-Right> {Classy::Tableobject %W movex %W 1}
bind Classy::Table <Configure> {%W _redraw}
# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Table
Classy::export Table {}

Classy::Table classmethod init {args} {
	# REM Create object
	# -----------------
	super
	$object configure -width 100 -height 100 -highlightthicknes 0 -bd 0
	frame $object.base -borderwidth 0
	grid $object.base -row 0 -column 0 -sticky nw
	entry $object.base.e0,0 -width 1 -textvariable [privatevar $object data](0,0)
	grid columnconfigure $object 1 -weight 1
	grid rowconfigure $object 1 -weight 1
	grid propagate $object 0


	# REM set variables
	# -----------------
	private $object drow dcol
	set drow(start) 0
	set dcol(start) 0

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

#doc {Table options -columns} option {-columns columns columns} descr {
# 
#}
Classy::Table addoption -columns {columns Columns 5} {
}
#doc {Table options -rows} option {-rows rows rows} descr {
# 
#}
Classy::Table addoption -rows {rows Rows 20} {
}
#doc {Table options -colsize} option {-colsize colsize colsize} descr {
# 
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
# 
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
# 
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
	destroy object.temp
	set dcol(num) 1
	set drow(num) 1
	eval destroy [winfo children $object.base]
	Classy::Table__create_elem $object $value 0 0
	Classy::todo $object _redraw
}
#doc {Table options -xscrollcommand} option {-xscrollcommand xscrollcommand xscrollcommand} descr {
# 
#}
Classy::Table addoption -xscrollcommand {xScrollCommand ScrollCommand {}} {}
#doc {Table options -yscrollcommand} option {-yscrollcommand yscrollcommand yscrollcommand} descr {
# 
#}
Classy::Table addoption -yscrollcommand {yScrollCommand ScrollCommand {}} {}
#doc {Table options -getcommand} option {-getcommand getcommand getcommand} descr {
# 
#}
Classy::Table addoption -getcommand {getCommand Command {}} {}
#doc {Table options -setcommand} option {-setcommand setcommand setcommand} descr {
# 
#}
Classy::Table addoption -setcommand {setCommand Command {}} {}
#doc {Table options -xlabels} option {-xlabels xLabels Labels} descr {
# 
#}
Classy::Table addoption -xlabels {xLabels Labels {}} {}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Table method movey {w step} {
	private $object options drow
	regexp {([0-9]+),([0-9]+)$} $w temp row col
	set rrow [expr $row+$drow(start)+1]
	if {($step > 0)&&($rrow >= $options(-rows))} return
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
}

Classy::Table method movex {w step} {
	private $object options dcol
	regexp {([0-9]+),([0-9]+)$} $w temp row col
	set rcol [expr $col+$dcol(start)+1]
	if {($step > 0)&&($rcol >= $options(-columns))} return
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

Classy::Table method _set {w} {
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
	if {($rrow >= $options(-rows))||($rcol >= $options(-columns))} {
		set res ""
	} elseif [catch {$options(-setcommand)	$object $object.base.e$row,$col $rrow $rcol $value} res] {
		$object _reset $row $col
		return ""
	}
	switch $options(-type) {
		entry {
			set data($row,$col) $res
		}
		text {
			$object.base.e$row,$col insert 1.0 $res
		}
	}
}

Classy::Table method _reset {row col} {
	private $object options drow dcol data
	set rcol [expr {$col+$dcol(start)}]
	set rrow [expr {$row+$drow(start)}]
	if {($rrow >= $options(-rows))||($rcol >= $options(-columns))} {
		set new ""
	} else {
		set code [catch {$options(-getcommand) $object $object.base.e$row,$col $rrow $rcol} new]
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
				$object.base.e$row,$col delete 1.0 end
				if {"$new" != ""} {$object.base.e$row,$col insert 1.0 $new}
			}
		}
	}
}

Classy::Table method _refresh {} {
	private $object options drow dcol data
	set rcol $dcol(start)
	for {set col 0} {$col < $dcol(num)} {incr col} {
		if [info exists dcol(s,$rcol)] {
			eval grid columnconfigure $object.base $col -minsize $dcol(s,$rcol)
		} else {
			grid columnconfigure $object.base $col -minsize $dcol(s)
		}
		incr rcol
	}
	set rrow $drow(start)
	for {set row 0} {$row < $drow(num)} {incr row} {
		if [info exists drow(s,$rrow)] {
			eval grid rowconfigure $object.base $row -minsize $drow(s,$rrow)
		} else {
			grid rowconfigure $object.base $row -minsize $drow(s)
		}
		incr rrow
	}
	set rrow $drow(start)
	for {set row 0} {$row < $drow(num)} {incr row} {
		set rcol $dcol(start)
		for {set col 0} {$col < $dcol(num)} {incr col} {
			set w $object.base.e$row,$col
			if {($rrow >= $options(-rows))||($rcol >= $options(-columns))} {
				set new ""
			} else {
				set code [catch {$options(-getcommand) $object $w $rrow $rcol} new]
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
	}
	$object _sethbar
	$object _setvbar
}

proc Classy::Table__create_elem {object type row col} {
	switch $type {
		entry {
			entry $object.base.e$row,$col -width 1 -textvariable [privatevar $object data]($row,$col)
			bindtags $object.base.e$row,$col [list $object Classy::Table::entry $object.base.e$row,$col Entry . all]
		}
		text {
			text $object.base.e$row,$col -width 1 -height 0
			bindtags $object.base.e$row,$col [list $object Classy::Table::text $object.base.e$row,$col Text . all]
		}
	}
	grid $object.base.e$row,$col -row $row -column $col -sticky nwse
}

#doc {Table command _redraw} cmd {
#pathname _redraw 
#} descr {
#}
Classy::Table method _redraw {} {
	private $object options drow dcol data
	set width [winfo width $object]
	set prevcol $dcol(num)
	set cs 0
	set dcol(num) 0
	set rcol $dcol(start)	
	while 1 {
		if [info exists dcol(s,$rcol)] {
			set size $dcol(s,$rcol)
		} else {
			set size $dcol(s)
		}
		incr cs $size
		grid columnconfigure $object $dcol(num) -minsize $size -weight 0
		incr rcol
		incr dcol(num)
		if {$rcol == $options(-columns)} break
		if {$cs > $width} break
	}
	set colnum [expr {$dcol(num)-$prevcol}]

	set height [winfo height $object]
	set prevrow $drow(num)
	set drow(cs) 0
	set drow(num) 0
	set rrow $drow(start)	
	while 1 {
		if [info exists drow(s,$rrow)] {
			set size $drow(s,$rrow)
		} else {
			set size $drow(s)
		}
		incr drow(cs) $size
		grid rowconfigure $object $drow(num) -minsize $size -weight 0
		incr rrow
		incr drow(num)
		if {$rrow == $options(-rows)} break
		if {$drow(cs) > $height} break
	}
	set rownum [expr {$drow(num)-$prevrow}]

	set to $drow(num)
	if {$prevrow < $to} {set to $prevrow}
	if {$colnum > 0} {
		for {set col $prevcol} {$col < $dcol(num)} {incr col} {
			for {set row 0} {$row < $to} {incr row} {
				Classy::Table__create_elem $object $options(-type) $row $col
			}
		}
	} elseif {$colnum < 0} {
		for {set col $dcol(num)} {$col < $prevcol} {incr col} {
			for {set row 0} {$row < $prevrow} {incr row} {
				destroy $object.base.e$row,$col
			}
		}
	}

	if {$rownum > 0} {
		for {set row $prevrow} {$row < $drow(num)} {incr row} {
			for {set col 0} {$col < $dcol(num)} {incr col} {
				Classy::Table__create_elem $object $options(-type) $row $col
			}
		}
	} elseif {$rownum < 0} {
		for {set row $drow(num)} {$row < $prevrow} {incr row} {
			for {set col 0} {$col < $prevcol} {incr col} {
				destroy $object.base.e$row,$col
			}
		}
	}
	$object _refresh	
}

#doc {Table command xview} cmd {
#pathname yview args
#} descr {
#}
Classy::Table method xview {args} {
	private $object options dcol
	set pagesize $dcol(num)
	set pos $dcol(start)
	set size $dcol(num)
	set min 0
	set max [expr {$options(-columns)-1}]

	switch [lindex $args 0] {
		"" {
			set end [expr (double($pos + $size)/$max]
			if {$end > 1} {set end 1}
			return [list [expr double($pos)/$max] $end
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
	$object _redraw
}

#doc {Table command yview} cmd {
#pathname yview args
#} descr {
#}
Classy::Table method yview {args} {
	private $object options drow
	set pagesize $drow(num)
	set pos $drow(start)
	set size $drow(num)
	set min 0
	set max [expr {$options(-rows)-1}]

	switch [lindex $args 0] {
		"" {
			set end [expr (double($pos + $size)/$max]
			if {$end > 1} {set end 1}
			return [list [expr double($pos)/$max] $end
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
	$object _redraw
}

Classy::Table method _sethbar {} {
	private $object options dcol
	set curlow $dcol(start)
	set curhigh [expr {$dcol(start) + $dcol(num)}]
	set min 0
	set max $options(-columns)

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

