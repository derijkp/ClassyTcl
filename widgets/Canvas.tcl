#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Canvas
# ----------------------------------------------------------------------
#doc Canvas title {
#Canvas
#} index {
# Tk improvements
#} shortdescr {
# Canvas with zoom, undo/redo, rotate,save and load, group
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# Classy::Canvas creates a canvas widget that supports undo and redo, 
# save and load, selection and grouping. Most options
# and commands are identical to those of the standard Tk canvas.<br>
# Classy::Canvas reserves tags starting with an underscore (_) for internal
# use (temporary tags, grouping etc.). You should not add or remove such tags, 
# except for the group names returned by the group method.
# they should be ignored
#}
#doc {Canvas command} h2 {
#	Canvas specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Canvas {} {}
proc Canvas {} {}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

catch {destroy .classy__.temp}
canvas .classy__.temp
if ![catch {.classy__.temp create line 10 10 10 10 -activefill red}] {
	set Classy::dashpatch 1
} else {
	set Classy::dashpatch 0
}

Widget subclass Classy::Canvas
Classy::export Canvas {}

Classy::Canvas classmethod init {args} {
	private $object data undo currentname w del
	setprivate $object data(w) [super init canvas]
	set w $data(w)
	set data(page) [$w create rectangle -10000 -10000 0 0 -fill white -outline white -tags _page]
	set del($data(page)) _page
	set data(sel) [$w create rectangle -10000 -10000 -10000 -10000 -outline red -tags {_selection _h _selbd}]
	set del($data(sel)) _sel
	set data(cur) [$w create rectangle -10000 -10000 -10000 -10000 -outline blue -tags {_cur _h _selbd}]
	set del($data(cur)) _sel
	set data(selector) [$w create rectangle -10000 -10000 -10000 -10000 -outline red -tags _selector]
	set del($data(selector)) _sel
	set data(ind) 0
	# REM Initialise options and variables
	# ------------------------------------
	set undo(prevact) ""
	if [info exists undo] {unset undo}
	set data(undo) 1
	set undo(undo) ""
	set undo(redo) ""
	set undo(steps) 200
	set currentname 1
	set data(zoom) 1
	set data(current) ""
	set data(group) 0
	# REM Create bindings
	# --------------------
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::Canvas chainoptions {$object}

#doc {Entry options -undosteps} option {-undosteps undoSteps UndoSteps} descr {
# gives the number of possible undo steps. Default is 200.
#}
Classy::Canvas	addoption -undosteps {undoSteps UndoSteps 200} {
	private $object undo
	set undo(redo) ""
	if {$value<1} {set value 1}
	if {[llength $undo(undo)]>$value} {
		set pos [expr {[llength $undo(undo)]-$value+1}]
		set undo(undo) [lrange $undo(undo) $pos end]
		set undo(redo) [lrange $undo(redo) $pos end]
	}
	set undo(steps) $value
}

#doc {Entry options -papersize} option {-papersize papeSize PaperSize} descr {
# determines the papersize
#}
Classy::Canvas	addoption -papersize {papeSize PaperSize {}} {
	private $object w data
	set len [llength $value]
	if {$len == 0} {
		$w coords _page -10000 -10000 0 0
		$object configure -scrollregion {}
		return
	} elseif {$len==1} {
		set orient p
		set p $value
		regexp {^(.+)(-l|-p)$} $value temp p orient
		set c [structlget [option get $object paperSizes PaperSizes] $p]
		if {"$orient" == "-l"} {
			set temp [list [lindex $c 1] [lindex $c 0]]
			set c $temp
		}
	} else {
		set c $value
	}
	eval $w coords _page 0 0 $c
	$w scale _page 0 0 $data(zoom) $data(zoom)
	$w configure -scrollregion [$w coords _page]
}

# ------------------------------------------------------------------
#  destroy
# ------------------------------------------------------------------

Classy::Canvas method destroy {} {
	private $object fonts
	foreach font [array names fonts] {
		font delete $fonts($font)
	}
	foreach img [image names] {
		if [string match $object:* $img] {
			image delete $img
		}
	}
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------
Classy::Canvas chainallmethods {$object} canvas

#doc {Canvas command undo} cmd {
#pathname undo ?action? ?args?
#} descr {
# Without arguments, this method will undo the previous action
# When action is provided, it can have the following values
#<dl>
#<dt>check<dd>insert a checkpoint
#<dt>clear<dd>clear undo buffer
#<dt>add<dd>add ?args? to undo buffer, they will be executed when undo is called
#<dt>off<dd>turn undo buffering of
#<dt>on<dd>turn undo buffering on
#<dt>status<dd>query state of undo
#</dl>
#}
Classy::Canvas method undo {{action {}} args} {
	private $object w data undo del
	switch $action {
		"" {
			$w delete _ind
			if ![info exists undo(pos)] {
				set undo(pos) [expr {[llength $undo(undo)]-1}]
			} else {
				incr undo(pos) -1
			}
			if {$undo(pos) == -1} {
				set undo(pos) 0
				return -code error "No more undo steps"
			}
			$object _undoone [lindex $undo(undo) $undo(pos)]
		}
		check {
			if {"$args" == "start"} {
				set undo(check) [llength $undo(undo)]
			} elseif {"$args" == "stop"} {
				if ![info exists undo(check)] {
					error "\"$object undo check start\" must be called first"
				}
				set list [lrange $undo(undo) $undo(check) end]
				if {"$list" == ""} return
				set undo(undo) [lrange $undo(undo) 0 [expr {$undo(check)-1}]]
				lappend undo(undo) [list check $list]
				set list [lrange $undo(redo) $undo(check) end]
				set undo(redo) [lrange $undo(redo) 0 [expr {$undo(check)-1}]]
				lappend undo(redo) [list check $list]
				unset undo(check)
			} else {
				error "invalid option \"$args\": must be start or stop"
			}
		}
		clear {
			private $object options
			foreach name [array names del] {
				if [inlist {_page _sel} $del($name)] continue
				$w delete $del($name)
				unset del($name)
			}
			if [info exists undo] {unset undo}
			set undo(undo) ""
			set undo(redo) ""
			set undo(steps) $options(-undosteps)
		}
		add {
			if ![info exists undo(pos)] {
				lappend undo(redo) [concat a [lindex $args 0]]
				lappend undo(undo) [concat a [lindex $args 1]]
			}
		}
		0 -
		off {
			$object undo clear
			set data(undo) 0
		}
		1 -
		on {
			set data(undo) 1
		}
		status {
			return $data(undo)
		}
	}
}

Classy::Canvas method _undoone {current} {
	private $object w data undo del
	set action [lshift current]
	switch $action {
		check {
			set list [lindex $current 0]
			set i [expr {[llength $list]-1}]
			for {} {$i>=0} {incr i -1} {
				set item [lindex $list $i]
				if {"[lindex $item 0]" == "check"} {error "checks nested: cannot be redone"}
				$object _undoone $item
			}
		}
		create {
			set item [lindex $current 0]
			set del($item) [$w gettags $item]
			$w itemconfigure $item -tags {_del _h}
			$w move $item -10000 -10000
			$w lower $item
		}
		delete {
			set items [lindex $current 0]
			set poss [lindex $current 1]
			set i [llength $items]
			incr i -1
			for {} {$i > -1} {incr i -1} {
				set item [lindex $items $i]
				$w itemconfigure $item -tags $del($item)
				$w move $item 10000 10000
				$w lower $item [lindex $poss $i]
				unset del($item)
			}
		}
		addtag {
			foreach {tag items} $current {
				foreach item $items {
					$w dtag $item $tag
				}
			}
		}
		dtag {
			foreach {items tag} $current {
				foreach item $items {
					set tags [$w gettags $item]
					lappend tags $tag
					$w itemconfigure $item -tags $tags
				}
			}
		}
		dchars {
			foreach {item pos text} [lindex $current 0] {
				$w insert $item $pos $text
			}
		}
		insert {
			set len [lindex $current 0]
			foreach {item pos} [lindex $current 1] {
				$w dchars $item $pos [expr {$pos+$len-1}]
			}
		}
		itemconfigure {
			private $object itemw
			foreach item [lindex $current 0] args [lindex $current 1] width [lindex $current 2] {
				eval $w itemconfigure $item $args
				if {"$width" != ""} {
					set itemw($item) $width
				} else {
					catch {unset itemw($item)}
				}
			}
		}
		coords {
			set templist ""
			foreach item [lindex $current 0] coords [lindex $current 1]  {
				eval $w coords $item $coords
			}
		}
		coord {
			set templist ""
			set pos [lindex $current 1]
			set pos1 [expr {2*$pos}]
			set pos2 [expr {$pos1+1}]
			foreach item [lindex $current 0] coords [lindex $current 2]  {
				set fcoords [$w coords $item]
				eval $w coords $item [lreplace $fcoords $pos1 $pos2 [lindex $coords 0] [lindex $coords 1]]
			}
		}
		move {
			foreach {tagOrId xAmount yAmount} $current {
				$w move $tagOrId [expr -$xAmount] [expr -$yAmount]
				if {"$tagOrId"=="_sel"} {
					$w move _selbd [expr -$xAmount] [expr -$yAmount]
				}
			}
		}
		scale {
			foreach {tagOrId xOrigin yOrigin xScale yScale} $current {
				set data(undo) 0
				$object scale $tagOrId $xOrigin $yOrigin [expr {1/$xScale}] [expr {1/$yScale}]
				set data(undo) 1
			}
		}
		zoom {
			set zoom [lindex $current 0]
			set data(undo) 0
			$object zoom $zoom
			set data(undo) 1
		}
		rotate {
			foreach {tagOrId x y a} $current {
				$w visitor rotate $tagOrId \
					-xcenter $x -ycenter $y -angle [expr -$a]
			}
		}
		lower {
			set items [lindex $current 0]
			set poss [lindex $current 1]
			set i [llength $items]
			incr i -1
			for {} {$i > -1} {incr i -1} {
				set pos [lindex $poss $i]
				if {"$pos" != ""} {
					$w lower [lindex $items $i] $pos
				} else {
					$w raise [lindex $items $i]
				}
			}
		}
		raise {
			set items [lindex $current 0]
			set poss [lindex $current 1]
			set i [llength $items]
			incr i -1
			for {} {$i > -1} {incr i -1} {
				set pos [lindex $poss $i]
				if {"$pos" != ""} {
					$w lower [lindex $items $i] $pos
				} else {
					$w raise [lindex $items $i]
				}
			}
		}
		a {
			set undo(busy) 1
			uplevel #0 [lindex $current 0]
			unset undo(busy)
		}
		selection {
			set data(undo) 0
			$object selection set [lindex $current 0]
			set data(undo) 1
			Classy::todo $object selection redraw
		}
		current {
			set data(undo) 0
			eval $object current [lindex $current 0]
			set data(undo) 1
		}
		xview {
			$w xview moveto [lindex [lindex $current 0] 0]
		}
		yview {
			$w yview moveto [lindex [lindex $current 0] 0]
		}
	}
}

#doc {Canvas command redo} cmd {
#pathname redo 
#} descr {
# redo undone actions
#}
Classy::Canvas method redo {} {
	private $object w data undo del
	if ![info exists undo(pos)] {
		return -code error "Nothing to redo"
	}
	$object _redoone [lindex $undo(redo) $undo(pos)]
	incr undo(pos)
	set len [llength $undo(redo)]
	if {$undo(pos) == $len} {
		unset undo(pos)
	}
}

Classy::Canvas method _redoone {current} {
	private $object w data undo del
	set action [lshift current]
	switch $action {
		check {
			foreach item [lindex $current 0] {
				$object _redoone $item
			}
		}
		create {
			set item [lindex $current 0]
			$w itemconfigure $item -tags $del($item)
			unset del($item)
			$w move $item 10000 10000
			$w raise $item
		}
		delete {
			set items [lindex $current 0]
			foreach item $items {
				set del($item) [$w gettags $item]
				$w itemconfigure $item -tags {_del _h}
				$w move $item -10000 -10000
			}
		}
		addtag {
			set data(undo) 0
			eval $object addtag [lindex $current 0] [lindex $current 1] [lindex $current 2]
			set data(undo) 1
		}
		dtag {
			set data(undo) 0
			eval $object dtag $current
			set data(undo) 1
		}
		dchars {
			set data(undo) 0
			eval $object dchars $current
			set data(undo) 1
		}
		insert {
			set data(undo) 0
			eval $object insert $current
			set data(undo) 1
		}
		itemconfigure {
			set data(undo) 0
			eval $object itemconfigure [lindex $current 0] [lindex $current 1]
			set data(undo) 1
		}
		coords {
			set data(undo) 0
			eval $object coords [lindex $current 0] [lindex $current 1]
			set data(undo) 1
		}
		coord {
			set data(undo) 0
			eval $object coord [lindex $current 0] [lindex $current 1] [lindex $current 2]
			set data(undo) 1
		}
		move {
			foreach {tagOrId xAmount yAmount} $current {
				$w move $tagOrId $xAmount $yAmount
				if {"$tagOrId"=="_sel"} {
					$w move _selbd $xAmount $yAmount
				}
			}
		}
		scale {
			foreach {tagOrId xOrigin yOrigin xScale yScale} $current {
				set data(undo) 0
				$object scale $tagOrId $xOrigin $yOrigin $xScale $yScale
				set data(undo) 1
			}
		}
		zoom {
			set zoom [lindex $current 0]
			set data(undo) 0
			$object zoom $zoom
			set data(undo) 1
		}
		rotate {
			foreach {tagOrId x y a} $current {
				$w visitor rotate $tagOrId -xcenter $x -ycenter $y -angle $a
			}
		}
		lower {
			set data(undo) 0
			$object lower [lindex $current 0] [lindex $current 1]
			set data(undo) 1
		}
		raise {
			set data(undo) 0
			$object raise [lindex $current 0] [lindex $current 1]
			set data(undo) 1
		}
		a {
			set undo(busy) 1
			uplevel #0 [lindex $current 1]
			unset undo(busy)
		}
		selection {
			set data(undo) 0
			$object selection set [lindex $current 0]
			set data(undo) 1
			Classy::todo $object selection redraw
		}
		current {
			set data(undo) 0
			eval $object current [lindex $current 0]
			set data(undo) 1
		}
		xview {
			eval $w yview [lindex $current 0]
		}
		yview {
			eval $w yview [lindex $current 0]
		}
	}
}

Classy::Canvas method addundo {redodata undodata} {
	private $object undo
	if [info exists undo(pos)] {
		set undo(redo) [lrange $undo(redo) 0 $undo(pos)]
		set undo(undo) [lrange $undo(undo) 0 $undo(pos)]
		unset undo(pos)
	}
	lappend undo(redo) $redodata
	lappend undo(undo) $undodata
	if [info exists undo(check)] return
	set len [llength $undo(undo)]
	if {$len>$undo(steps)} {
		set pos [expr {$len-$undo(steps)+1}]
		set undo(undo) [lrange $undo(undo) $pos end]
		set undo(redo) [lrange $undo(redo) $pos end]
	}
}

#doc {Canvas command noundo} cmd {
#pathname noundo ?args?
#} descr {
# execute command without storing in undo buffer
#}
Classy::Canvas method noundo {args} {
	private $object data
	set keep $data(undo)
	set data(undo) 0
	eval $object $args
	set data(undo) $keep
}

proc Classy::tag2items {object w tagOrId} {
	if [regexp {^[0-9]+$} $tagOrId] {
		return $tagOrId
	} elseif {"$tagOrId" == "all"} {
		private $object del
		set result [$w find withtag all]
		return [llremove $result [array names del]]
	} else {
		return [$w find withtag $tagOrId]
	}
}

proc Classy::zoomfont {font zoom} {
	set size [lindex $font 1]
	if {"$size" == ""} {return $font}
	set size [expr int(abs($size*$zoom))]
	if {$size==0} {set size 1}
	return [lreplace $font 1 1 $size]
}

Classy::Canvas method fastconfigure {items option value} {
	foreach item $items {
		$w itemconfigure $item $option $value
	}
}

Classy::Canvas method zoom {{factor {}}} {
	private $object w data fonts widths itemw
	if {"$factor" == ""} {
		return $data(zoom)
	}
	if {$factor < 0.02} {set factor 0.02}
	if {$factor > 100} {set factor 20}
	if $data(undo) {
		$object addundo [list zoom $factor] [list zoom $data(zoom)]
	}
	set rfactor [expr {double($factor)/$data(zoom)}]
	$w scale all 0 0 $rfactor $rfactor
	foreach font [array names fonts] {
		eval font configure {$fonts($font)} [font actual [::Classy::zoomfont $font $factor]]
	}
	foreach width [array names widths] {
		set widths($width) [expr {$width*$factor}]
	}
	foreach {item value} [array get itemw] {
		$w itemconfigure $item -width $widths($value)
	}
	set data(zoom) $factor
	if {"[$w configure -scrollregion]" != ""} {
		$w configure -scrollregion "0 0 [lrange [$w coords _page] 2 3]"
	}
}

Classy::Canvas method font {font} {
	private $object fonts rfonts data
	if ![info exists fonts($font)] {
		set fname [list $object font $font]
		eval font create {$fname} [font actual [::Classy::zoomfont $font $data(zoom)]]
		set fonts($font) $fname
		set rfonts($fname) $font
	}
	return $fonts($font)
}

Classy::Canvas method width {width} {
	private $object widths rwidths data
	if ![info exists widths($width)] {
		set widths($width) [expr $width*$data(zoom)]
		set rwidths($widths($width)) $width
	}
}

proc Classy::Canvas_create_text {object w arg extra} {
	private $object fonts
	set pos [lsearch -exact $arg -font]
	if {$pos == -1} {
		set font [option get $object font Font]
	} else {
		incr pos
		set font [lindex $arg $pos]
		if {"[lindex $font 0]" == "$object"} {
			set font [lindex $font 2]
		}
	}
	if ![info exists fonts($font)] {
		$object font $font
	}
	if {$pos == -1} {
		lappend arg -font $fonts($font)
	} else {
		set arg [lreplace $arg end end $fonts($font)]
	}
	return [leval $w create text $arg $extra]
}

invoke {} {
foreach type {line polygon rectangle oval arc} {
	set body {
	proc Classy::Canvas_create_@type@ {object w arg extra} {
		private $object widths itemw
		set pos [lsearch -exact $arg -width]
		if {$pos != -1} {
			incr pos
			set width [lindex $arg $pos]
			if ![info exists widths($width)] {
				$object width $width
			}
			set arg [lreplace $arg $pos $pos $widths($width)]
		} else {
			set width 1
		}
		set item [leval $w create @type@ $arg $extra]
		set itemw($item) $width
		return $item
	}
	}
	regsub -all @type@ $body $type temp
	uplevel #0 $temp
}
}

proc Classy::Canvas_create_bitmap {object w arg extra} {
	return [leval $w create bitmap $arg]
}

proc Classy::Canvas_create_image {object w arg extra} {
	return [leval $w create image $arg]
}

proc Classy::Canvas_create_window {object w arg extra} {
	return [leval $w create window $arg]
}

if $::Classy::dashpatch {

Classy::Canvas method create {type args} {
	private $object w data
	set item [Classy::Canvas_create_$type $object $w $args {-disabledfill red}]
	if $data(undo) {
		$object addundo [list create $item] [list create $item]
	}
	return $item
}

} else {

Classy::Canvas method create {type args} {
	private $object w data
	set item [Classy::Canvas_create_$type $object $w $args {}]
	if $data(undo) {
		$object addundo [list create $item] [list create $item]
	}
	return $item
}

}

Classy::Canvas method delete {args} {
	private $object w data del
	Classy::todo $object selection redraw
	if $data(undo) {
		private $object itemw
		foreach tagOrId $args {
			set items [Classy::tag2items $object $w $tagOrId]
			set poss ""
			foreach item $items {
				lappend poss [$w find above $item]
				set del($item) [$w gettags $item]
				$w itemconfigure $item -tags {_del _h}
				$w move $item -10000 -10000
			}
			$object addundo [list delete $items] [list delete $items $poss]
		}
		return ""
	} else {
		return [leval $w delete $args]
	}
}

Classy::Canvas method clear {} {
	private $object w data options del widths itemw fonts rfont
	foreach img [image names] {
		if [regexp "^$object:" $img] {
			destroy $img
		}
	}
	catch {unset del}
	catch {unset data}
	catch {unset widths}
	catch {unset itemw}
	foreach name [array names fonts] {
		font delete $fonts($name)
	}
	catch {unset fonts}
	catch {unset rfont}
	$w delete all
	set data(page) [$w create rectangle -10000 -10000 0 0 -fill white -outline white -tags _page]
	set del($data(page)) _page
	set data(sel) [$w create rectangle -10000 -10000 -10000 -10000 -outline red -tags {_selection _h _selbd}]
	set del($data(sel)) _sel
	set data(cur) [$w create rectangle -10000 -10000 -10000 -10000 -outline blue -tags {_cur _h _selbd}]
	set del($data(cur)) _sel
	set data(selector) [$w create rectangle -10000 -10000 -10000 -10000 -outline red -tags _selector]
	set del($data(selector)) _sel
	set data(ind) 0
	set undo(prevact) ""
	if [info exists undo] {unset undo}
	set data(undo) 1
	set undo(undo) ""
	set undo(redo) ""
	set undo(steps) 200
	set currentname 1
	set data(zoom) 1
	set data(current) ""
	set data(group) 0
	$object configure -papersize $options(-papersize)
}

Classy::Canvas method itemconfigure {tagOrId args} {
	private $object w data del
	set len [llength $args]
	if {$len == 0} {
		if [info exists del($tagOrId)] {
			return {}
		} else {
			return [$w itemconfigure $tagOrId]
		}
	} elseif {$len == 1} {
		if [info exists del($tagOrId)] {
			return {}
		} else {
			return [$w itemconfigure $tagOrId $args]
		}
	} else {
		set fpos [lsearch $args -font]
		set wpos [lsearch $args -width]
		set kargs $args
		if {$fpos != -1} {
			private $object fonts
			incr fpos
			set font [lindex $args $fpos]
			if ![info exists fonts($font)] {
				$object font $font
			}			
			set args [lreplace $args $fpos $fpos $fonts($font)]
		}
		if $data(undo) {
			set ws ""
			set optionslist ""
			set citems [Classy::tag2items $object $w $tagOrId]
			set options [lunmerge $args]
			if {$wpos != -1} {
				private $object widths itemw
				incr wpos
				set width [lindex $args $wpos]
				if ![info exists widths($width)] {
					$object width $width
				}			
				set args [lreplace $args $wpos $wpos $widths($width)]
				foreach item $citems {
					lappend ws $itemw($item)
					set itemw($item) $width
					set temp ""
					foreach option $options {
						catch {lappend temp $option [$w itemcget $item $option]}
					}
					lappend optionslist $temp
					catch {leval $w itemconfigure $item $args}
				}
			} else {
				foreach item $citems {
					set temp ""
					foreach option $options {
						catch {lappend temp $option [$w itemcget $item $option]}
					}
					lappend optionslist $temp
					catch {leval $w itemconfigure $item $args}
				}
			}
			$object addundo [list itemconfigure $tagOrId $kargs] [list itemconfigure $citems $optionslist $ws]
		} else {
			set citems [Classy::tag2items $object $w $tagOrId]
			set options [lunmerge $args]
			if {$wpos != -1} {
				private $object widths itemw
				incr wpos
				set width [lindex $args $wpos]
				if ![info exists widths($width)] {
					$object width $width
				}			
				set args [lreplace $args $wpos $wpos $widths($width)]
				set optionslist ""
				set ws ""
				foreach item $citems {
					set itemw($item) $width
					catch {leval $w itemconfigure $item $args}
				}
			} else {
				foreach item $citems {
					catch {leval $w itemconfigure $item $args}
				}
			}
		}
	}
	return {}
}

Classy::Canvas method mitemcget {tagOrId option} {
	private $object w data undo
	set citems [Classy::tag2items $object $w $tagOrId]
	set result ""
	foreach item $citems {
		lappend result [$w itemcget $item $option]
	}
	return $result
}

Classy::Canvas method coords {tagOrId args} {
	private $object w data del
	if {"$args"==""} {
		return [$w coords $tagOrId]
	} else {
		if $data(undo) {
			set items [Classy::tag2items $object $w $tagOrId]
			set coords ""
			foreach item $items {
				lappend coords [$w coords $item]
			}
			$object addundo [list coords $tagOrId $args] [list coords $items $coords]
		}
		return [eval $w coords $tagOrId $args]
	}
}

Classy::Canvas method coord {tagOrId pos args} {
	private $object w data del
	if {"$args"==""} {
		set pos [expr {2*$pos}]
		return [lrange [$w coords $tagOrId] $pos [expr {$pos+1}]]
	} else {
		set pos1 [expr {2*$pos}]
		set pos2 [expr {$pos1+1}]
		if $data(undo) {
			private $object undo
			set lastredo [lindex $undo(redo) end]
			if {[lrange $lastredo 0 2] != [list coord $tagOrId $pos]} {
				set do 1
			} else {
				set do 0
				set lastredo [lreplace $lastredo 3 3 $args]
				set undo(redo) [lreplace $undo(redo) end end $lastredo]
			}
		} else {
			set do 0
		}
		set items [Classy::tag2items $object $w $tagOrId]
		set coords ""
		set x [lindex $args 0]
		set y [lindex $args 1]
		foreach item $items {
			set fcoords [$w coords $item]
			eval $w coords $item [lreplace $fcoords $pos1 $pos2 $x $y]
			if $do {lappend coords [lrange $fcoords $pos1 $pos2]}
		}
		if $do {$object addundo [list coord $tagOrId $pos $args] [list coord $items $pos $coords]}
	}
}

Classy::Canvas method move {tagOrId xAmount yAmount} {
	private $object w data
	if $data(undo) {
		private $object undo
		set lastundo [lindex $undo(undo) end]
		if {("[lindex $lastundo 0]" != "move")||("[lindex $lastundo 1]" != "$tagOrId")} {
			$object addundo [list move $tagOrId $xAmount $yAmount] [list move $tagOrId $xAmount $yAmount]
		} else {
			lpop undo(undo)			
			lpop undo(redo)			
			set x [expr {[lindex $lastundo 2]+$xAmount}]
			set y [expr {[lindex $lastundo 3]+$yAmount}]
			$object addundo [list move $tagOrId $x $y] [list move $tagOrId $x $y]
			set undo(undo)
		}
	}
	if {"$tagOrId"=="_sel"} {
		$w move _selbd $xAmount $yAmount
	}
	return [$w move $tagOrId $xAmount $yAmount]
}

Classy::Canvas method scale {tagOrId xOrigin yOrigin xScale yScale} {
	private $object w data itemw fonts widths
	if $data(undo) {
		$object addundo [list scale $tagOrId $xOrigin $yOrigin $xScale $yScale] \
			[list scale $tagOrId $xOrigin $yOrigin $xScale $yScale]
	}
	foreach citem [$w find withtag $tagOrId] {
		set nf [catch {$w itemcget $citem -font} font]
		if !$nf {
			set font [lindex $font 2]
			set newfont [Classy::zoomfont $font $yScale]
			$w itemconfigure $citem -font [$object font $newfont]
		}
		if [info exists itemw($citem)] {
			set itemw($citem) [expr {abs($itemw($citem)*$yScale)}]
			if ![info exists widths($itemw($citem))] {
				set widths($itemw($citem)) [expr $itemw($citem)*$data(zoom)]
				set rwidths($widths($itemw($citem))) $itemw($citem)
			}
			$w itemconfigure $citem -width $widths($itemw($citem))
		}
	}
	set result [$w scale $tagOrId $xOrigin $yOrigin $xScale $yScale]
	if {"$tagOrId" == "_sel"} {Classy::todo $object selection redraw}
	return $result
}

if ![catch {package require Visrotate}] {
Classy::Canvas method rotate {tagOrId xcenter ycenter angle} {
	private $object w data
	if $data(undo) {
		$object addundo [list rotate $tagOrId $xcenter $ycenter $angle] \
			[list rotate $tagOrId $xcenter $ycenter $angle]
	}
	return [eval $w visitor rotate $tagOrId -xcenter $xcenter -ycenter $ycenter -angle $angle]
}
} else {
Classy::Canvas method rotate {tagOrId xcenter ycenter angle} {
	private $object w data
	if $data(undo) {
		$object addundo [list rotate $tagOrId $xcenter $ycenter $angle] \
			[list rotate $tagOrId $xcenter $ycenter $angle]
	}
	set a [expr {$angle*0.0174532925199}]
	set cs [expr {cos($a)}]
	set sn [expr {sin($a)}]
	foreach citem [$w find withtag $tagOrId] {
		set coords [$w coords $citem]
		set newcoords ""
		foreach {x y} $coords {
			set x [expr {$x - $xcenter}]
			set y [expr {$y - $ycenter}]
			lappend newcoords [expr {($x*$cs)+($y*$sn)+$xcenter}] [expr {-($x*$sn)+($y*$cs)+$ycenter}]
		}
		eval $w coords $citem $newcoords
	}
}
}

Classy::Canvas method lower {tagOrId {belowThis all}} {
	private $object w data
	if $data(undo) {
		if [regexp {^[0-9]+$} $tagOrId] {
			set items $tagOrId
		} elseif {"$tagOrId" == "all"} {
			return
		} else {
			set items [$w find withtag $tagOrId]
		}
		set poss ""
		foreach item $items {
			lappend poss [$w find above $item]
		}
		$object addundo [list lower $tagOrId $belowThis] [list lower $items $poss]
		return [$w lower $tagOrId $belowThis]
	} else {
		return [$w lower $tagOrId $belowThis]
	}
}

Classy::Canvas method raise {tagOrId {aboveThis all}} {
	private $object w data
	if $data(undo) {
		if [regexp {^[0-9]+$} $tagOrId] {
			set items $tagOrId
		} elseif {"$tagOrId" == "all"} {
			return
		} else {
			set items [$w find withtag $tagOrId]
		}
		set poss ""
		foreach item $items {
			lappend poss [$w find above $item]
		}
		$object addundo [list raise $tagOrId $aboveThis] [list raise $items $poss]
		return [$w raise $tagOrId $aboveThis]
	} else {
		return [$w raise $tagOrId $aboveThis]
	}
}

#doc {Canvas command addtag} cmd {
#pathname addtag tag searchCommand ?arg ...?
#} descr {
# This command is identical to that of the standard canvas widget, but supports
# some extra searchcommanda:
#<dl>
#<dt>items<dd> all given items
#<dt>tags<dd> all items with one of the given tags
#<dt>andtags<dd> all items with all of the given tags
# </dl>
#}
Classy::Canvas method addtag {tag searchcommand args} {
	private $object w data
	if $data(undo) {
		switch $searchcommand {
			items {
				set citems $args
			}
			tags {
				set citems [Classy::tag2items $object $w [lindex $args 0]]
				foreach temp [lrange $args 1 end] {
					set citems [lunion $citems [Classy::tag2items $object $w $temp]]
				}
			}
			andtags {
				set citems [Classy::tag2items $object $w [lindex $args 0]]
				foreach temp [lrange $args 1 end] {
					set citems [lcommon $citems [Classy::tag2items $object $w $temp]]
				}
			}
			withtag {
				set citems [Classy::tag2items $object $w [lindex $args 0]]
			}
			all {
				set citems [Classy::tag2items $object $w all]
			}
			above - below {
				set tagOrId [lindex $args 0]
				if [regexp {^[0-9]+$} $tagOrId] {
					set citems [$w find $searchcommand $tagOrId]
				} elseif {"$tagOrId" == "all"} {
					set citems ""
				} else {
					set citems [$w find $searchcommand $tagOrId]
				}
			}
			default {
				set citems [leval $w find $searchcommand $args]
			}
		}
		set items ""
		foreach citem $citems {
			set tags [$w gettags $citem]
			if {[lsearch $tags $tag] == -1} {
				lappend tags $tag
				$w itemconfigure $citem -tags $tags
				lappend items $citem
			}
		}
		if {"$items" != ""} {
			$object addundo [list addtag $tag $searchcommand $args] [list addtag $tag $items]
		}
	} else {
		switch $searchcommand {
			items {
				foreach item $args {
					$w addtag $tag withtag $item
				}
			}
			tags {
				set citems [Classy::tag2items $object $w [lindex $args 0]]
				foreach temp [lrange $args 1 end] {
					set citems [lunion $citems [Classy::tag2items $object $w $temp]]
				}
				foreach item $citems {
					$w addtag $tag withtag $item
				}
			}
			andtags {
				set citems [Classy::tag2items $object $w [lindex $args 0]]
				foreach temp [lrange $args 1 end] {
					set citems [lcommon $citems [Classy::tag2items $object $w $temp]]
				}
				foreach item $citems {
					$w addtag $tag withtag $item
				}
			}
			default {
				leval $w addtag $tag $searchcommand $args
			}
		}
	}
	return {}
}

#doc {Canvas command find} cmd {
#pathname find tag searchCommand ?arg ...?
#} descr {
# This command is identical to that of the standard canvas widget, but supports
# some extra searchcommanda:
#<dl>
#<dt>tags<dd> all items with one of the given tags
#<dt>andtags<dd> all items with all of the given tags
# </dl>
#}
Classy::Canvas method find {searchcommand args} {
	private $object w data del
	if $data(undo) {
		switch $searchcommand {
			tags {
				set citems [Classy::tag2items $object $w [lindex $args 0]]
				foreach tag [lrange $args 1 end] {
					set citems [lunion $citems [Classy::tag2items $object $w $tag]]
				}
				return $citems
			}
			andtags {
				set citems [Classy::tag2items $object $w [lindex $args 0]]
				foreach tag [lrange $args 1 end] {
					set citems [lcommon $citems [Classy::tag2items $object $w $tag]]
				}
				return $citems
			}
			withtag {
				return [Classy::tag2items $object $w [lindex $args 0]]
			}
			all {
				return [Classy::tag2items $object $w all]
			}
			above - below {
				set tagOrId [lindex $args 0]
				if [regexp {^[0-9]+$} $tagOrId] {
					return [$w find $searchcommand $tagOrId]
				} elseif {"$tagOrId" == "all"} {
					return ""
				} else {
					return [$w find $searchcommand $tagOrId]
				}
			}
			default {
				return [llremove [leval $w find $searchcommand $args] [array names del]]
			}
		}
	} else {
		switch $searchcommand {
			tags {
				set citems [Classy::tag2items $object $w [lindex $args 0]]
				foreach tag [lrange $args 1 end] {
					set citems [lunion $citems [Classy::tag2items $object $w $tag]]
				}
				return $citems
			}
			andtags {
				set citems [Classy::tag2items $object $w [lindex $args 0]]
				foreach tag [lrange $args 1 end] {
					set citems [lcommon $citems [Classy::tag2items $object $w $tag]]
				}
				return $citems
			}
			default {
				return [llremove leval $w find $searchcommand $args] [array names del]]
			}
		}
	}
}

Classy::Canvas method dtag {tagOrId {tagToDelete {}}} {
	private $object w data
	if {"$tagToDelete" == ""} {set tagToDelete $tagOrId}
	if $data(undo) {
		set citems [Classy::tag2items $object $w $tagOrId]
		set items ""
		foreach citem $citems {
			set tags [$w gettags $citem]
			set pos [lsearch $tags $tagToDelete]
			if {$pos != -1} {
				set tags [lreplace $tags $pos $pos]
				$w itemconfigure $citem -tags $tags
				lappend items $citem
			}
		}
		if {"$items" != ""} {
			$object addundo [list dtag $tagOrId $tagToDelete] [list dtag $items $tagToDelete]
		}
	} else {
		$w dtag $tagOrId $tagToDelete
	}
}

Classy::Canvas method dchars {tagOrId first {last {}}} {
	private $object w data
	if {"$last" == ""} {
		set last $first
	}
	if $data(undo) {
		set citems [Classy::tag2items $object $w $tagOrId]
		set list ""
		foreach citem $citems {
			set text [$w itemcget $citem -text]
			set first [$w index $citem $first]
			set last [$w index $citem $last]
			set text [string range $text $first $last]
			if {"$text" != ""} {
				lappend list $citem $first $text
				$w dchars $citem $first $last
			}
		}
		if {"$list" != ""} {
			$object addundo [list dchars $tagOrId $first $last] [list dchars $list]
		}
	} else {
		$w dchars $tagOrId $first $last
	}
}

Classy::Canvas method xview {args} {
	private $object w data undo
	if ![string length $args] {
		return [$w xview]
	}
	if $data(undo) {
		set lastundo [lindex $undo(undo) end]
		if {"[lindex $lastundo 0]" != "xview"} {
			$object addundo [list xview $args] [list xview [$w xview]]
		} else {
			lpop undo(redo)			
			lpop undo(undo)
			$object addundo [list xview $args] [list xview [lindex $lastundo 1]]
			set undo(undo)
		}
	}
	eval $w xview $args
}

Classy::Canvas method yview {args} {
	private $object w data undo
	if ![string length $args] {
		return [$w yview]
	}
	if $data(undo) {
		set lastundo [lindex $undo(undo) end]
		if {"[lindex $lastundo 0]" != "yview"} {
			$object addundo [list yview $args] [list yview [$w yview]]
		} else {
			lpop undo(redo)			
			lpop undo(undo)
			$object addundo [list yview $args] [list yview [lindex $lastundo 1]]
			set undo(undo)
		}
	}
	eval $w yview $args
}

Classy::Canvas method insert {tagOrId beforeThis string} {
	private $object w data
	if $data(undo) {
		set citems [Classy::tag2items $object $w $tagOrId]
		set list ""
		set len [string length $string]
		if {$len == 0} return
		foreach citem $citems {
			set pos [$w index $citem $beforeThis]
			if {"$pos"==""} continue
			lappend list $citem $pos
			$w insert $citem $pos $string
		}
		if {"$list" != ""} {
			$object addundo [list insert $tagOrId $beforeThis $string] [list insert $len $list]
		}
	} else {
		$w insert $tagOrId $beforeThis $string
	}
}

proc Classy::mtagadditems {object w var list} {
	upvar $var data
	foreach tagOrId $list {
		if [regexp {^[0-9]+$} $tagOrId] {
			set data($tagOrId) 1
		} elseif {"$tagOrId" == "all"} {
			private $object del
			foreach item [$w find withtag all] {
				if ![info exists del($item)] {set data($item) 1}
			}
		} else {
			foreach item [$w find withtag $tagOrId] {
				set data($item) 1
			}
		}
	}
}

proc Classy::mtagrmitems {object w var list} {
	upvar $var data
	foreach tagOrId $list {
		if [regexp {^[0-9]+$} $tagOrId] {
			catch {unset data($tagOrId) 1}
		} else {
			foreach item [$w find withtag $tagOrId] {
				catch {unset data($tagOrId) 1}
			}
		}
	}
}

Classy::Canvas method selection {action {list {}}} {
	private $object w data undo
	switch $action {
		set {
			if $data(undo) {set pre [$w find withtag _sel]}
			$w dtag _sel
			foreach tag $list {
				$w addtag _sel withtag $tag
			}
			Classy::todo $object selection redraw
			if {"$list" == ""} {
				catch {$w itemconfigure all -stipple {}}
				catch {$w itemconfigure all -outlinestipple {}}
			} else {
				catch {$w itemconfigure all -stipple gray50}
				catch {$w itemconfigure all -outlinestipple gray50}
				catch {$w itemconfigure _sel -stipple {}}
				catch {$w itemconfigure _sel -outlinestipple {}}
			}
			$w itemconfigure _page -stipple {}
			if $data(undo) {
				set post [$w find withtag _sel]
				if {"$pre" != "$post"} {
					$object addundo [list selection $post] [list selection $pre]
				}
			}
		}
		get {
			return [$w find withtag _sel]
		}
		add {
			if ![llength $list] return
			if $data(undo) {set pre [$w find withtag _sel]}
			foreach tag $list {
				$w addtag _sel withtag $tag
			}
			Classy::todo $object selection redraw
			catch {$w itemconfigure all -stipple gray50}
			catch {$w itemconfigure all -outlinestipple gray50}
			catch {$w itemconfigure _sel -stipple {}}
			catch {$w itemconfigure _sel -outlinestipple {}}
			$w itemconfigure _page -stipple {}
			if $data(undo) {
				set post [$w find withtag _sel]
				if {"$pre" != "$post"} {
					$object addundo [list selection $post] [list selection $pre]
				}
			}
		}
		clear {
			if $data(undo) {set pre [$w find withtag _sel]}
			catch {$w itemconfigure all -stipple {}}
			catch {$w itemconfigure all -outlinestipple {}}
			$w dtag _sel
			if $data(undo) {
				set post {}
				if {"$pre" != "$post"} {
					$object addundo [list selection $post] [list selection $pre]
				}
			}
		}
		remove {
			if $data(undo) {set pre [$w find withtag _sel]}
			foreach tag $list {
				catch {$w itemconfigure $tag -stipple gray50}
				catch {$w itemconfigure $tag -outlinestipple gray50}
				$w dtag $tag _sel
			}
			Classy::todo $object selection redraw
			if $data(undo) {
				set post [$w find withtag _sel]
				if {"$pre" != "$post"} {
					$object addundo [list selection $post] [list selection $pre]
				}
			}
		}
		redraw {
			set bbox [$w bbox $data(current)]
			if {"$bbox" != ""} {
				$w coords $data(cur) $bbox
				$w raise $data(cur)
			} else {
				$w coords $data(cur) -1000 -1000 -1000 -1000
			}
			if ![info exists data(nw)] {
				foreach name {nw n ne e se s sw w} {
					set data($name) [$w create bitmap -1000 -1000 \
						-bitmap [Classy::getbitmap canvas_select] \
						-foreground red \
						-tags [list _sb _sb_$name _selbd]]
				}
			}
			set bbox [$w bbox _sel]
			if {"$bbox" != ""} {
				set x1 [lindex $bbox 0]
				set y1 [lindex $bbox 1]
				set x2 [lindex $bbox 2]
				set y2 [lindex $bbox 3]
				if {$x2 < $x1} {set temp $x1;set x1 $x2;set x2 $temp}
				if {$y2 < $y1} {set temp $y1;set y1 $y2;set y2 $temp}
				$w coords $data(sel) $x1 $y1 $x2 $y2
				$w raise $data(sel)
				$w coords _nw -1000 -1000
				$w coords $data(nw) $x1 $y1
				$w coords $data(ne) $x2 $y1
				$w coords $data(se) $x2 $y2
				$w coords $data(sw) $x1 $y2
				$w coords $data(n) [expr {$x1+($x2-$x1)/2}] $y1
				$w coords $data(e) $x2 [expr {$y1+($y2-$y1)/2}]
				$w coords $data(s) [expr {$x1+($x2-$x1)/2}] $y2
				$w coords $data(w) $x1 [expr {$y1+($y2-$y1)/2}]
				$w raise _sb
			} else {
				foreach name {nw n ne e se s sw w} {
					$w coords $data($name) -1000 -1000
				}
				$w coords $data(sel) -1000 -1000 -1000 -1000
			}
			if $data(ind) {
				$w delete _ind
				set num 0
				foreach {x y} [$w coords $data(current)] {
					$w create bitmap $x $y \
						-bitmap [Classy::getbitmap canvas_current] \
						-foreground red \
						-tags [list _ind _ind_$num _selbd]
					incr num
				}
			}
		}
		draw {
			set x1 [lindex $list 0]
			set y1 [lindex $list 1]
			set x2 [lindex $list 2]
			set y2 [lindex $list 3]
			$w coords $data(sel) $x1 $y1 $x2 $y2
			$w raise $data(sel)
			$w coords _nw -1000 -1000
			$w coords $data(nw) $x1 $y1
			$w coords $data(ne) $x2 $y1
			$w coords $data(se) $x2 $y2
			$w coords $data(sw) $x1 $y2
			$w coords $data(n) [expr {$x1+($x2-$x1)/2}] $y1
			$w coords $data(e) $x2 [expr {$y1+($y2-$y1)/2}]
			$w coords $data(s) [expr {$x1+($x2-$x1)/2}] $y2
			$w coords $data(w) $x1 [expr {$y1+($y2-$y1)/2}]
			$w raise _sb
		}
		coords {
			return [$w coords $data(sel)]
		}
	}
}

#doc {Canvas command current} cmd {
#pathname current ?item?
#} descr {
# returns the current item. If current is given, it chabges the
# the current item to the item given.
#}
Classy::Canvas method current {args} {
	private $object w data
	if {"$args" == ""} {
		return $data(current)
	} else {
		$w delete _ind
		if $data(undo) {
			$object addundo [list current [lindex $args 0]] [list current $data(current)]
		}
		set data(current) [lindex $args 0]
	}
	if {[llength $args] == 2}  {
		set num 0
		foreach {x y} [$w coords $data(current)] {
			$w create bitmap $x $y \
				-bitmap [Classy::getbitmap canvas_current] \
				-foreground red \
				-tags [list _ind _ind_$num _selbd]
			incr num
		}
		set data(ind) 1
	} else {
		set data(ind) 0
	}
	set bbox [$w bbox $data(current)]
	if {"$bbox" != ""} {
		$w coords $data(cur) $bbox
		$w raise $data(cur)
	} else {
		$w coords $data(cur) -1000 -1000 -1000 -1000
	}
}

Classy::Canvas method selector {x1 y1 x2 y2} {
	private $object w
	$w coords _selector $x1 $y1 $x2 $y2
}

Classy::Canvas method images {{pattern *}} {
	set result ""
	foreach img [image names] {
		if [string match $object:$pattern $img] {lappend result $img}
	}
	return $result
}

proc ::Classy::Canvas_save_text {object w item} {
	lappend result [$w gettags $item]
	lappend result [$w coords $item]
	lappend result [lindex [$w itemcget $item -font] 2]
	foreach option {-anchor -fill -justify -stipple -text -width} {
		lappend result [$w itemcget $item $option]
	}
	return $result
}

proc ::Classy::Canvas_load_text {object w idata tags} {
	private $object fonts
	set coords [lindex $idata 1]
	set font [lindex $idata 2]
	if ![info exists fonts($font)] {
		$object font $font
	}
	set args [lmerge {-anchor -fill -justify -stipple -text -width} \
		[lrange $idata 3 8]]
	leval $w create text $coords $args -font [list $fonts($font) -tags $tags]
}

invoke {} {
foreach {type opts} {
	line {-arrow -arrowshape -capstyle -fill -joinstyle -smooth -splinesteps -stipple}
	polygon {-fill -outline -smooth -splinesteps -stipple}
	rectangle {-fill -outline -stipple}
	oval {-fill -outline -stipple}
	arc {-extent -fill -outline -outlinestipple -start -stipple -style}
} {
	set body {
	proc ::Classy::Canvas_save_@type@ {object w item} {
		private $object itemw
		lappend result [$w gettags $item]
		lappend result [$w coords $item]
		lappend result $itemw($item)
		foreach option {@opt@} {
			lappend result [$w itemcget $item $option]
		}
		return $result
	}
	}
	regsub @type@ $body $type body
	regsub @opt@ $body $opts body
	uplevel #0 $body
	set body {
	proc ::Classy::Canvas_load_@type@ {object w idata tags} {
		private $object widths itemw
		set coords [lindex $idata 1]
		set width [lindex $idata 2]
		if ![info exists widths($width)] {
			$object width $width
		}
		set args [lmerge {@opt@} \
			[lrange $idata 3 @end@]]
		set item [leval $w create @type@ $coords $args -width $widths($width) [list -tags $tags]]
		set itemw($item) $width
		return $item
	}
	}
	regsub -all @type@ $body $type body
	regsub @opt@ $body $opts body
	regsub @end@ $body [expr {[llength $opts]+2}] body
	uplevel #0 $body
}
}

proc ::Classy::Canvas_save_image {object w item} {
	private $object save
	lappend result [$w gettags $item]
	lappend result [$w coords $item]
	set name [$w itemcget $item -image]
	set type [image type $name]
	if ![info exists save(image,$name)] {
		set file [$name cget -file]
		if {"$file" == ""} {
			set from data
			set img [$name cget -data]
		} else {
			set from file
			set f [open $file]
			fconfigure $f -buffersize 100000 -translation binary
			set img [gets $f]
			close $f
		}
		set save(image,$name) 1
	} else {
		set from {}
		set img {}
	}
	lappend result $type $name $from $img
	foreach option {-anchor} {
		lappend result [$w itemcget $item $option]
	}
	return $result
}

proc ::Classy::Canvas_load_image {object w idata tags} {
	private $object fonts load
	set coords [lindex $idata 1]
	set type [lindex $idata 2]
	set name [lindex $idata 3]
	set from [lindex $idata 4]
	set img [lindex $idata 5]
	if {"$from" != ""} {
		set base $object:$name
		set num 1
		while {"[info commands $base$num]" != ""} {incr num}
		if {"$from" == "file"} {
			set tempf [tempfile get]
			set f [open $tempf "w"]
			fconfigure $f -buffersize 100000 -translation binary
			puts -nonewline $f $img
			close $f
			set load(image,$name) [image create $type $base$num -file $tempf]
			file delete $tempf
		} else {
			set load(image,$name) [image create $type $base$num -data $img]
		}
	}
	set args [lmerge {-anchor} \
		[lrange $idata 6 6]]
	leval $w create image $coords $args [list -tags $tags -image $load(image,$name)]
}

proc ::Classy::Canvas_save_bitmap {object w item} {
	private $object save
	lappend result [$w gettags $item]
	lappend result [$w coords $item]
	set name [$w itemcget $item -bitmap]
	set img {}
	if [regexp ^@ $name] {
		if ![info exists save(bitmap,$name)] {
			set file [string range $name 1 end]
			set img [readfile $file]
			set save(bitmap,$name) 1
		}
	}
	lappend result $name $img
	foreach option {-anchor -background -foreground} {
		lappend result [$w itemcget $item $option]
	}
	return $result
}

proc ::Classy::Canvas_load_bitmap {object w idata tags} {
	private $object fonts load data
	set coords [lindex $idata 1]
	set name [lindex $idata 2]
	set img [lindex $idata 3]
	if {"$img" != ""} {
		set tempf [tempfile get]
		writefile $tempf $img
		set load(bitmap,$name) "@$tempf"
		set name $load(bitmap,$name)
	} elseif [info exists load(bitmap,$name)] {
		set name $load(bitmap,$name)
	}
	set args [lmerge {-anchor -background -foreground} \
		[lrange $idata 4 6]]
	leval $w create bitmap $coords $args [list -tags $tags -bitmap $name]
}

proc ::Classy::Canvas_save_window {object w item} {
	return ""
}

proc ::Classy::Canvas_load_window {object w idata} {
	return ""
}

proc ::Classy::Canvas_load_order {object w idata tags} {
	set offset [lindex $idata 2]
	set first [lindex [lsort -integer [$w find withtag _new]] 0]
	set offset [expr {$first-$offset}]
	foreach item [lindex $idata 1] {
		$w raise [expr {$item+$offset}]
	}
}

#doc {Canvas command undo} cmd {
#pathname save ?tag?
#} descr {
# returns a list that can be used to restore the drawing in the canvas
# using a load command. This can be saved to a file for permanent storage.
# If tag is given, only items with tag $tag will be saved instead of all items.
#}
Classy::Canvas method save {{tag all}} {
	private $object w save
	$w dtag _new
	catch {unset save}
	lappend result header "Classy::Canvas-0.1"
	set list [Classy::tag2items $object $w $tag]
	lappend order {}
	lappend order $list
	set list [lsort -integer $list]
	lappend order [lindex $list 0]
	foreach item $list {
		set type [$w type $item]
		set idata [::Classy::Canvas_save_$type $object $w $item]
		if {"$idata" != ""} {
			lappend result $type $idata
		}
	}
	lappend result order $order
	return $result
}

#doc {Canvas command undo} cmd {
#pathname load ?tag?
#} descr {
# restores a previously saved drawing. Its argument is a list as returned by
# the save method.
#}
Classy::Canvas method load {c} {
	private $object w load data tag
	catch {unset load}
	$w dtag _new
	foreach {type idata} [lrange $c 0 end] {
		set tags [lindex $idata 0]
		foreach pos [lfind -glob $tags _g*] {
			set g [lindex $tags $pos]
			if ![info exists tag($g)] {
				incr data(group)
				set tag($g) _g$data(group)
			}
			set tags [lreplace $tags $pos $pos $tag($g)]
		}
		lappend tags _new
		catch {::Classy::Canvas_load_$type $object $w $idata $tags}
#		if {"[info commands ::Classy::Canvas_load_$type]" != ""} {
#			::Classy::Canvas_load_$type $object $w $idata $tags
#		}
	}
	return {}
}

#doc {Canvas command group} cmd {
#pathname group searchcommand ?arg? ...
#} descr {
# creates a new group, consisting of items found by the searchcommand. searchcommand
# has the same options as in the addtag method. The method returns the name of the
# group. The group name can be used as a tag, in order to perform actions on group 
# member. Adding the group name as a tag to an item will add the item to the group.
#}
Classy::Canvas method group {args} {
	private $object w data
	incr data(group)
	set name _g$data(group)
	leval $object addtag $name $args
	return $name
}

#doc {Canvas command findgroup} cmd {
#pathname findgroup tagOrId
#} descr {
# returns the main group of an item: This is the last one the item was added to.
# If tagOrId is a tag  that  refers  to more than one item, the first
# (lowest) such item is used.
#}
Classy::Canvas method findgroup {tagOrId} {
	private $object w data
	set tags [$w gettags $tagOrId]
	set poss [lfind -glob $tags _g*]
	if {"$poss" != ""} {
		return [lindex $tags [lindex $poss end]]
	} else {
		return {}
	}
}

#doc {Canvas command cut} cmd {
#pathname cut ?tagOrId?
#} descr {
# copies a description of the objects given by tagOrId to the clipboard
#}
Classy::Canvas method cut {{tagOrId _sel}} {
	clipboard clear -displayof $object			  
	catch {									
		clipboard append -displayof $object [$object save $tagOrId]
		$object delete $tagOrId
	}										  
}

#doc {Canvas command copy} cmd {
#pathname copy ?tagOrId?
#} descr {
# copies a description of the objects given by tagOrId to the clipboard
#}
Classy::Canvas method copy {{tagOrId _sel}} {
	clipboard clear -displayof $object			  
	catch {									
		clipboard append -displayof $object [$object save $tagOrId]
	}										  
}

#doc {Canvas command paste} cmd {
#pathname paste
#} descr {
# creates new objects from a description put on the clipboard by the copy or cut method
#}
Classy::Canvas method paste {} {
	$object selection set {}
	$object load [selection get -displayof $object -selection CLIPBOARD]
}

Classy::Canvas method _getprint {var} {
putsvars var
	private $object w data
	upvar #0 ::$var print
	if $print(portrait) {set rotate 0} else {set rotate 1}
	return [$w postscript \
		-rotate $rotate -colormode $print(colormode) \
		-width $print(pwidth) -height $print(pheight) \
		-pagewidth [expr {$print(scale)*$print(pwidth)/100.0}] \
		-x $print(xoffset) -y $print(yoffset) \
		-pageanchor nw -pagex 0 -pagey 0]
}

#doc {Canvas command print} cmd {
#pathname print
#} descr {
# pops up a print dialog
#}
Classy::Canvas method print {} {
	private $object w data
	set page [$w coords _page]
	Classy::printdialog -papersize [lrange $page 2 3] -getdata [list $object _getprint]
}
